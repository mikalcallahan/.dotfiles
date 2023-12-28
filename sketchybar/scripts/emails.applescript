#!/usr/bin/osascript
on run
  tell application "Mail"
    return the unread count of inbox
  end tell
end run
