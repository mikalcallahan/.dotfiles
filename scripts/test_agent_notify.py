"""Behavioral tests: python3 -B -m unittest discover -s scripts -p 'test_*.py'."""

import importlib.machinery
import importlib.util
from contextlib import closing
import io
import json
import os
from pathlib import Path
import shlex
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import Mock, patch

loader = importlib.machinery.SourceFileLoader('agent_notify', str(Path(__file__).with_name('agent-notify')))
spec = importlib.util.spec_from_loader(loader.name, loader)
notify = importlib.util.module_from_spec(spec)
loader.exec_module(notify)
make_context = notify.make_context


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
        self.patch('codex_metadata', return_value=None)
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

    def codex(self, message='Tests passed.', **fields):
        notify.make_context.side_effect = make_context
        self.invoke('codex', json.dumps({'type': 'agent-turn-complete', 'thread-id': 'thread',
                                       'turn-id': 'turn', 'cwd': '/work/project',
                                       'last-assistant-message': message, **fields}))

    def test_internal_title_generation_does_not_notify(self):
        notify.codex_metadata.return_value = {}
        self.codex('{"title":"Fix notifications","description":"Improve status accuracy"}')
        self.delivery.send.assert_not_called()
        self.assertFalse(list(self.directory.glob('agent-*.json')))

    def test_real_chat_json_is_not_suppressed(self):
        notify.codex_metadata.return_value = {'name': 'Generate JSON', 'thread_source': 'user'}
        self.codex('{"title":"Title","description":"Description"}')
        self.delivery.send.assert_called_once()

    def test_metadata_unavailable_does_not_suppress_json(self):
        self.codex('{"title":"Title","description":"Description"}')
        self.delivery.send.assert_called_once()

    def test_internal_review_and_subagent_events_do_not_notify(self):
        for metadata in ({'thread_source': 'guardian_review'},
                         {'source': '{"subagent":{"other":"guardian"}}'},
                         {'thread_source': 'subagent'}):
            with self.subTest(metadata=metadata):
                notify.codex_metadata.return_value = metadata
                self.codex('Review complete.')
        self.delivery.send.assert_not_called()

    def test_real_reply_uses_chat_name_and_honest_status(self):
        notify.codex_metadata.return_value = {'name': 'Fix notifications', 'title': 'Original prompt',
                                             'originator': 'Codex Desktop', 'thread_source': 'user'}
        self.codex('Which environment should I use?')
        record = self.delivery.send.call_args.args[0]
        self.assertEqual(record['context']['title'], 'Fix notifications')
        self.assertEqual(record['message'], 'Which environment should I use?')
        self.patch('executable', return_value='/fake/terminal-notifier')
        run = self.patch('run', return_value=subprocess.CompletedProcess([], 0, '', ''))
        notify.MacOSBackend().send(record)
        command = run.call_args.args[0]
        self.assertEqual(command[command.index('-title') + 1], 'Codex response ready')
        self.assertEqual(command[command.index('-subtitle') + 1], 'Fix notifications · project')

    def test_unknown_thread_still_notifies_with_request_context(self):
        notify.codex_metadata.return_value = {}
        self.codex(**{'input-messages': ['<environment_context>metadata</environment_context>', 'Fix the login flow']})
        self.assertEqual(self.delivery.send.call_args.args[0]['context']['title'], 'Fix the login flow')

    def test_codex_groups_match_across_permission_and_completion_environments(self):
        first = {**self.context, 'agent': 'codex'}
        second = {**first, 'socket': '', 'pane': '', 'server_pid': '', 'cwd': '/other'}
        self.assertEqual(notify.group_id(first), notify.group_id(second))
        self.assertNotEqual(notify.group_id(first), notify.group_id({**first, 'session_id': 'other'}))

    def test_permission_hook_uses_session_and_reason_without_raw_command(self):
        payload = {'hook_event_name': 'PermissionRequest', 'session_id': 'thread', 'turn_id': 'turn',
                   'cwd': '/repo', 'tool_name': 'Bash',
                   'tool_input': {'description': 'Fetch the latest remote branch',
                                  'command': 'SECRET=do-not-display git fetch'}}
        self.patch('legacy_permission_payload', return_value=payload)
        notify.make_context.side_effect = make_context
        self.invoke('attention', 'Permission required')
        record = self.delivery.send.call_args.args[0]
        self.assertEqual(record['status_label'], 'approval requested')
        self.assertEqual(record['context']['agent'], 'codex')
        self.assertEqual(record['context']['session_id'], 'thread')
        self.assertEqual(record['context']['cwd'], '/repo')
        self.assertEqual(record['message'], 'Bash: Fetch the latest remote branch')
        self.assertNotIn('SECRET', json.dumps(record))
        group = record['group']
        self.codex('Branch fetched.')
        self.assertEqual(self.delivery.send.call_args.args[0]['group'], group)
        self.assertEqual(len(list(self.directory.glob('agent-*.json'))), 1)

    def test_permission_without_reason_uses_tool_name(self):
        self.patch('legacy_permission_payload', return_value={
            'hook_event_name': 'PermissionRequest', 'session_id': 'thread', 'turn_id': 'turn',
            'tool_name': 'apply_patch', 'tool_input': {'command': 'private file contents'}})
        notify.make_context.side_effect = make_context
        self.invoke('attention', 'Permission required')
        self.assertEqual(self.delivery.send.call_args.args[0]['message'], 'Approval requested for apply_patch')

    def test_duplicate_completion_is_suppressed_but_new_turn_is_not(self):
        self.codex()
        self.codex()
        self.assertEqual(self.delivery.send.call_count, 1)
        self.codex(**{'turn-id': 'next-turn'})
        self.assertEqual(self.delivery.send.call_count, 2)

    def test_failed_delivery_can_retry(self):
        self.delivery.send.return_value = False
        self.codex()
        self.delivery.send.return_value = True
        self.codex()
        self.assertEqual(self.delivery.send.call_count, 2)

    def test_replaces_legacy_group_for_same_chat_only(self):
        old_group = 'agent-' + '0' * 32
        other_group = 'agent-' + '1' * 32
        for group, session in ((old_group, 'thread'), (other_group, 'other')):
            notify.save(self.directory / (group + '.json'), {
                'group': group, 'context': {**self.context, 'agent': 'codex', 'session_id': session}})
        self.codex()
        self.delivery.remove.assert_called_once_with(old_group)
        self.assertFalse((self.directory / (old_group + '.json')).exists())
        self.assertTrue((self.directory / (other_group + '.json')).exists())

    def test_codex_completion_keeps_tmux_unread_marker(self):
        notify.make_context.return_value = {**self.context, 'agent': 'codex'}
        self.invoke('codex', json.dumps({'type': 'agent-turn-complete', 'thread-id': 'thread',
                                       'turn-id': 'turn', 'last-assistant-message': 'Ready.'}))
        unread_values = [call.args[-1] for call in self.tmux.call_args_list if '@ai_unread' in call.args]
        self.assertEqual(unread_values, ['1'])

    def test_missing_message_has_neutral_fallback(self):
        self.codex(None)
        self.assertEqual(self.delivery.send.call_args.args[0]['message'],
                         'A response is ready. Open the chat for details.')

    def test_desktop_click_opens_exact_chat(self):
        notify.codex_metadata.return_value = {'originator': 'Codex Desktop'}
        thread = '01a16901-8f6d-7683-80c2-b03c0651b04a'
        self.codex(**{'thread-id': thread})
        group = self.delivery.send.call_args.args[0]['group']
        run = self.patch('run', return_value=subprocess.CompletedProcess([], 0, '', ''))
        with patch('sys.platform', 'darwin'):
            notify.focus(group, self.directory, self.delivery)
        run.assert_called_once_with(['/usr/bin/open', 'codex://threads/' + thread])
        self.delivery.remove.assert_called_once_with(group)

    def test_failed_desktop_navigation_keeps_notification(self):
        notify.codex_metadata.return_value = {'originator': 'Codex Desktop'}
        self.codex(**{'thread-id': '01a16901-8f6d-7683-80c2-b03c0651b04a'})
        group = self.delivery.send.call_args.args[0]['group']
        self.patch('run', return_value=subprocess.CompletedProcess([], 1, '', 'failed'))
        with patch('sys.platform', 'darwin'):
            notify.focus(group, self.directory, self.delivery)
        self.delivery.remove.assert_not_called()


class CodexMetadataTest(unittest.TestCase):
    def test_read_only_lookup_with_optional_columns_and_versioned_databases(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {'CODEX_HOME': temporary}):
            root = Path(temporary)
            self.assertIsNone(notify.codex_metadata('thread'))
            self.assertFalse(list(root.iterdir()))
            for version in (5, 10):
                with closing(sqlite3.connect(root / f'state_{version}.sqlite')) as db, db:
                    db.execute('CREATE TABLE threads (id TEXT PRIMARY KEY, title TEXT)')
                    db.execute('INSERT INTO threads VALUES (?, ?)', ('thread', f'Chat {version}'))
            before = {p.name: p.read_bytes() for p in root.iterdir()}
            self.assertEqual(notify.codex_metadata('thread'), {'id': 'thread', 'title': 'Chat 10'})
            self.assertEqual(notify.codex_metadata('missing'), {})
            self.assertEqual(before, {p.name: p.read_bytes() for p in root.iterdir()})

    def test_unrecognized_schema_or_corrupt_database_is_optional(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {'CODEX_HOME': temporary}):
            path = Path(temporary) / 'state_5.sqlite'
            with closing(sqlite3.connect(path)) as db, db:
                db.execute('CREATE TABLE changed_schema (id TEXT)')
            self.assertIsNone(notify.codex_metadata('thread'))
            path.write_bytes(b'invalid database')
            self.assertIsNone(notify.codex_metadata('thread'))

    def test_preview_removes_rendering_directives_and_table_separators(self):
        self.assertEqual(notify.preview('**Fixed** the [bug](https://example.com).\n'
                                        '::created-thread{threadId="id"}\n'
                                        '| --- | ---: |\nDetails'), 'Fixed the bug. Details')

    def test_preview_preserves_identifiers_and_issue_numbers(self):
        self.assertEqual(notify.preview('## Fixed\n**RESOURCE_NOT_FOUND** in `apply_patch`; PR #123 is _ready_.'),
                         'Fixed RESOURCE_NOT_FOUND in apply_patch; PR #123 is ready.')


@unittest.skipUnless(sys.platform == 'darwin', 'macOS adapter integration')
class CodexHookIntegrationTest(unittest.TestCase):
    def test_existing_hook_and_notify_wrappers_share_context(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            scripts = root / '.config/scripts'
            scripts.mkdir(parents=True)
            for name in ('agent-notify', 'tmux-ai-status', 'codex-notify'):
                shutil.copy2(Path(__file__).with_name(name), scripts / name)
            binary = root / 'terminal-notifier'
            log = root / 'calls.jsonl'
            binary.write_text(f'#!{sys.executable}\nimport json, os, sys\n'
                              'with open(os.environ["NOTIFY_TEST_LOG"], "a") as f:\n'
                              '    f.write(json.dumps(sys.argv[1:]) + "\\n")\n')
            binary.chmod(0o755)
            environment = {**os.environ, 'HOME': str(root), 'CODEX_HOME': str(root),
                           'XDG_STATE_HOME': str(root / 'state'), 'NOTIFY_TEST_LOG': str(log),
                           'PATH': str(root) + os.pathsep + os.environ['PATH']}
            environment.pop('TMUX', None)
            environment.pop('TMUX_PANE', None)
            hook = {'hook_event_name': 'PermissionRequest', 'session_id': 'thread', 'turn_id': 'turn',
                    'cwd': '/repo', 'tool_name': 'Bash', 'tool_input': {'description': 'Run the checks'}}
            result = subprocess.run([str(scripts / 'tmux-ai-status'), 'attention', 'Permission required'],
                                    input=json.dumps(hook), text=True, capture_output=True,
                                    env=environment, timeout=10)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, '')  # Never makes an approval decision.
            event = {'type': 'agent-turn-complete', 'thread-id': 'thread', 'turn-id': 'turn',
                     'cwd': '/repo', 'last-assistant-message': 'Checks passed.'}
            result = subprocess.run([str(scripts / 'codex-notify'), json.dumps(event)],
                                    text=True, capture_output=True, env=environment, timeout=10)
            self.assertEqual(result.returncode, 0, result.stderr)
            calls = [json.loads(line) for line in log.read_text().splitlines()]
            self.assertEqual(len(calls), 2)
            self.assertEqual(calls[0][calls[0].index('-title') + 1], 'Codex approval requested')
            self.assertEqual(calls[0][calls[0].index('-message') + 1], 'Bash: Run the checks')
            self.assertEqual(calls[1][calls[1].index('-title') + 1], 'Codex response ready')
            self.assertEqual(calls[0][calls[0].index('-group') + 1], calls[1][calls[1].index('-group') + 1])


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
