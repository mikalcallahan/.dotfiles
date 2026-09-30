"""Behavioral tests: python3 -B -m unittest discover -s scripts -p 'test_*.py'."""

import importlib.machinery
import importlib.util
import io
import json
from pathlib import Path
import shlex
import subprocess
import tempfile
import time
import unittest
from unittest.mock import Mock, patch

loader = importlib.machinery.SourceFileLoader('agent_notify', str(Path(__file__).with_name('agent-notify')))
spec = importlib.util.spec_from_loader(loader.name, loader)
notify = importlib.util.module_from_spec(spec)
loader.exec_module(notify)


class NotificationsTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.context = dict(socket='/tmp/tmux/socket', server_pid='123', pane='%7',
                            agent='opencode', cwd='/work/project', session_id='session-1',
                            bundle='com.mitchellh.ghostty', client='/dev/ttys001')
        self.delivery = Mock()
        self.delivery.remove.return_value = True
        self.patch('state_directory', return_value=self.directory)
        self.patch('make_context', return_value=self.context)
        self.patch('backend', return_value=self.delivery)
        self.viewed = self.patch('is_viewed', return_value=False)
        self.tmux = self.patch('tmux', return_value=subprocess.CompletedProcess([], 0, '', ''))

    def patch(self, name, **kwargs):
        patcher = patch.object(notify, name, **kwargs)
        self.addCleanup(patcher.stop)
        return patcher.start()

    def invoke(self, *args, payload=None):
        with patch('sys.argv', ['agent-notify', *args]), patch('sys.stdin', io.StringIO(json.dumps(payload))):
            notify.main()

    def test_same_session_replaces_and_different_sessions_are_independent(self):
        self.invoke('attention', 'Choose an environment')
        self.invoke('complete', 'Tests passed')
        records = [call.args[0] for call in self.delivery.send.call_args_list]
        self.assertEqual(records[0]['group'], records[1]['group'])
        self.context = {**self.context, 'session_id': 'session-2'}
        notify.make_context.return_value = self.context
        self.invoke('complete', 'Other result')
        self.assertNotEqual(records[0]['group'], self.delivery.send.call_args.args[0]['group'])
        self.assertEqual(len(list(self.directory.glob('agent-*.json'))), 2)

    def test_viewed_pane_clears_notifications_for_all_its_sessions(self):
        self.invoke('complete', 'Done')
        self.viewed.return_value = True
        self.invoke('viewed')
        self.delivery.remove.assert_called_once()
        self.assertFalse(list(self.directory.glob('agent-*.json')))

    def test_background_focus_hook_does_not_clear(self):
        self.invoke('attention', 'Permission required')
        self.invoke('viewed')
        self.delivery.remove.assert_not_called()
        self.assertEqual(len(list(self.directory.glob('agent-*.json'))), 1)

    def test_visible_completion_suppressed(self):
        self.viewed.return_value = True
        self.invoke('complete', 'Done')
        self.delivery.send.assert_not_called()

    def test_codex_and_claude_payload_previews(self):
        self.invoke('codex', json.dumps({'type': 'agent-turn-complete', 'thread-id': 'thread',
                                       'cwd': '/repo', 'last-assistant-message': '**Fixed** the [bug](https://example.com).'}))
        self.assertEqual(self.delivery.send.call_args.args[0]['message'], 'Fixed the bug.')
        args = notify.make_context.call_args.args[0]
        self.assertEqual((args.agent, args.session_id, args.cwd), ('codex', 'thread', '/repo'))
        self.invoke('claude', payload={'hook_event_name': 'Stop', 'session_id': 'claude-session',
                                      'last_assistant_message': 'All checks passed.'})
        self.assertEqual(self.delivery.send.call_args.args[0]['message'], 'All checks passed.')

    def test_outside_tmux_still_notifies(self):
        notify.make_context.return_value = {**self.context, 'pane': '', 'socket': ''}
        self.invoke('--json', payload={'event': 'complete', 'agent': 'custom', 'message': 'Done'})
        self.delivery.send.assert_called_once()
        self.tmux.assert_not_called()

    def test_message_starting_with_dashes_is_not_an_option(self):
        self.invoke('--agent', 'opencode', '--session-id', 'session-1', '--', 'complete', '--keep-existing')
        self.assertEqual(self.delivery.send.call_args.args[0]['message'], '--keep-existing')

    def test_callback_uses_current_pane_location_and_original_client(self):
        self.invoke('complete', 'Done')
        group = self.delivery.send.call_args.args[0]['group']
        self.patch('pane_info', return_value=['123', '$8', '@12', 'opencode', '/work/project'])
        self.patch('clients', return_value=[['/dev/ttys002', '42', 'attached', '%2', '200'],
                                          ['/dev/ttys001', '43', 'attached', '%7', '100']])
        self.patch('client_bundle', return_value='com.mitchellh.ghostty')
        run = self.patch('run')
        with patch('sys.platform', 'darwin'):
            notify.focus(group, self.directory, self.delivery)
        self.tmux.assert_any_call(self.context, 'switch-client', '-c', '/dev/ttys001', '-t', '$8')
        self.tmux.assert_any_call(self.context, 'select-window', '-t', '$8:@12')
        self.tmux.assert_any_call(self.context, 'select-pane', '-t', '%7')
        run.assert_called_with(['/usr/bin/open', '-b', 'com.mitchellh.ghostty'])

    def test_stale_server_does_not_navigate(self):
        self.invoke('complete', 'Done')
        group = self.delivery.send.call_args.args[0]['group']
        self.patch('pane_info', return_value=['999', '$0', '@0', 'zsh', '/'])
        self.tmux.reset_mock()
        notify.focus(group, self.directory, self.delivery)
        self.tmux.assert_not_called()
        self.delivery.remove.assert_called_once_with(group)

    def test_backend_quotes_callback_and_keeps_message_out_of_command(self):
        self.patch('executable', return_value='/opt/homebrew/bin/terminal-notifier')
        run = self.patch('run', return_value=subprocess.CompletedProcess([], 0, '', ''))
        record = dict(context=self.context, event='complete', group=notify.group_id(self.context),
                      message='[result] $(touch /tmp/never-execute)')
        self.assertTrue(notify.MacOSBackend().send(record))
        command = run.call_args.args[0]
        self.assertEqual(command[command.index('-message') + 1], '\\' + record['message'])
        callback = shlex.split(command[command.index('-execute') + 1])
        self.assertIn(record['group'], callback)
        self.assertNotIn(record['message'], callback)


class VisibilityTest(unittest.TestCase):
    def test_requires_source_pane_and_focused_frontmost_client(self):
        context = {'pane': '%7'}
        with patch.object(notify, 'frontmost_bundle', return_value='terminal'), \
             patch.object(notify, 'client_bundle', return_value='terminal'), \
             patch.object(notify, 'clients') as clients:
            clients.return_value = [['tty', '1', 'attached,focused', '%2', '1']]
            self.assertFalse(notify.is_viewed(context))
            clients.return_value = [['tty', '1', 'attached', '%7', '1']]
            self.assertFalse(notify.is_viewed(context))
            clients.return_value = [['tty', '1', 'attached,focused', '%7', '1']]
            self.assertTrue(notify.is_viewed(context))


@unittest.skipUnless(notify.executable('tmux'), 'tmux is not installed')
class TmuxNavigationTest(unittest.TestCase):
    def test_focus_moves_real_client_to_source_pane(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            context = dict(socket=str(directory / 'tmux.sock'), agent='opencode',
                           cwd='/work', session_id='integration', bundle='')
            def command(*args):
                result = notify.tmux(context, *args)
                self.assertEqual(result.returncode, 0, result.stderr)
                return result.stdout.strip()

            command('-f', '/dev/null', 'new-session', '-d', '-s', 'first')
            client = None
            try:
                context['pane'] = command('new-session', '-d', '-s', 'target', '-P', '-F', '#{pane_id}')
                command('split-window', '-d', '-t', context['pane'])
                info = notify.pane_info(context)
                context['server_pid'] = info[0]
                # A control-mode client gives us real client routing without
                # moving any of the user's terminal windows or sessions.
                client = subprocess.Popen([notify.executable('tmux'), '-S', context['socket'],
                                           '-C', 'attach-session', '-t', 'first'],
                                          stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                for _ in range(50):
                    attached = notify.clients(context)
                    if attached:
                        break
                    time.sleep(0.02)
                self.assertTrue(attached)
                context['client'] = attached[0][0]
                group = notify.group_id(context)
                notify.save(directory / (group + '.json'), {'context': context, 'group': group})
                delivery = Mock()
                with patch.object(notify, 'state_directory', return_value=directory), \
                     patch.object(notify, 'client_bundle', return_value=''):
                    notify.focus(group, directory, delivery)
                self.assertEqual(notify.clients(context)[0][3], context['pane'])
                self.assertFalse((directory / (group + '.json')).exists())
            finally:
                notify.tmux(context, 'kill-server')
                if client:
                    client.communicate(timeout=5)


if __name__ == '__main__':
    unittest.main()
