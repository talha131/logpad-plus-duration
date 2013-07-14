This is a mirror of [Logpad at VimScripts](http://www.vim.org/scripts/script.php?script_id=2775).

Description
===========

logpad.vim emulates Windows Notepad's logging feature.

Create a new file, write .LOG as the first line and save it. Every time you reopen the file, a new line with the current timestamp is added, so you can easily maintain a chronologic log of your tasks.

Options
-------

By default, this plugin works the same way as the original Notepad. You can modify certain aspects of it by setting the following variables:

`let LogpadEnabled = 1`
* enables/disables logpad
* available values : [0, 1]
* default value: 1

`let LogpadInsert = 0`
* automatically enables insert mode when a new log entry is created
* available values : [0, 1]
* default value: 0

`let LogpadLineBreak = 0`
* adds an empty line before a new log entry
* available values : [0, 1]
* default value: 0 (Windows Notepad behavior)

`let LogpadIgnoreNotes = 0`
* allows adding notes before the first log entry
* available values : [0, 1]
* default value: 0

`let LogpadIgnoreReadOnly = 0`
* allows logpad to ignore a file's read-only flag
* available values : [0, 1]
* default value: 0

`let LogpadLogDuration = 1`
* adds the time elapsed since last timestamp under the new timestamp
* available values : [0 ,1]
* default value: 0
