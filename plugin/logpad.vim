" ---------[ INFORMATION ]---------
"
" Vim plugin for emulating Windows Notepad's logging functionality.
" Maintainer:  Sven Knurr <der_tuxman@arcor.de>
" Version:     1.4
" Last Change: 2009 Dec 19
"
" --------[ HOW TO USE IT ]--------
"
" Create a new text file. Insert .LOG. Save it. Then reopen it.
" Now you have a timestamped log file. :-)
"
" --------[ CONFIGURATION ]--------
"
" Optional values to set in your .vimrc file:
"
" let LogpadEnabled = [ 0 / 1 ]
"   >> enables/disables logpad
"   >> default value: 1
"
" let LogpadInsert = [ 0 / 1 ]
"   >> automatically enables &insertmode when a new log entry is created
"   >> default value: 0
"
" let LogpadLineBreak = [ 0 / 1 ]
"   >> adds an empty line before a new log entry
"   >> default value: 0 (Windows Notepad behavior)
"
" let LogpadIgnoreNotes = [ 0 / 1 ]
"   >> allows adding notes before the first log entry
"   >> default value: 0
"
" let LogpadIgnoreReadOnly = [ 0 / 1 ]
"   >> allows logpad to ignore a file's read-only flag
"   >> default value: 0
"
" let LogpadLogDuration = [ 0 / 1 ]
"   >> adds the duration elapsed since last timestamp under the new timestamp
"   >> default value: 0
"
" -----------[ CHANGES ]-----------
"
" v1.4: added check and switch for read-only flag
" v1.3: added support for GetLatestVimScripts, removed initial cursor() call
" v1.2: fix: converted logpad.vim to UNIX format (was not working outside Windows)
" v1.1: fix: the LogpadLineBreak setting also affects the single empty line below ".LOG"
" v1.0: initial release.
"
" -----------[ CREDITS ]-----------
"
" This plugin was inspired by a German weblog posting, available at:
"    http://schwerdtfegr.wordpress.com/2009/08/27/eine-notepad-funkzjon-die-man-missen-lernt/
" Thanks to the guys in #vim (freenode.net) for basic help.
"
" ---------[ HERE WE GO! ]---------

function! s:TryToFigureThatTimestampRegex()
    " 3 letters for day name
    " space
    " 3 letter for month
    " space
    " an optional space that occurs if day is single digit
    " one or two digit for day
    " space
    " hour:min:seconds
    " space
    " year
    let s:timestampformat = '\(\a\{3}\s\)\{2}\s\{0,1}\d\{1,2}\s\(\d\{2}:\)\{2}\d\{2}\s\d\{4}'
endfunction


function! s:CalculateMonth(month)
   if (match(a:month, 'Jan\c') != -1) 
       return 0
   elseif (match(a:month, 'Feb\c') != -1)
       return 1
   elseif (match(a:month, 'Mar\c') != -1)
       return 2
   elseif (match(a:month, 'Apr\c') != -1)
       return 3
   elseif (match(a:month, 'May\c') != -1)
       return 4
   elseif (match(a:month, 'Jun\c') != -1)
       return 5
   elseif (match(a:month, 'Jul\c') != -1)
       return 6
   elseif (match(a:month, 'Aug\c') != -1)
       return 7
   elseif (match(a:month, 'Sep\c') != -1)
       return 8
   elseif (match(a:month, 'Oct\c') != -1)
       return 9
   elseif (match(a:month, 'Nov\c') != -1)
       return 10
   elseif (match(a:month, 'Dec\c') != -1)
       return 11
   endif

   return -1
endfunction


function! s:SplitStringTime(timeString)
    let splitedTime = split(a:timeString)
    let month = s:CalculateMonth(splitedTime[1])
    let day = splitedTime[2]
    let year = splitedTime[4]
    
    let time = split(splitedTime[3], ':')
    let hour = time[0]
    let min = time[1]
    let sec = time[2]

    return [year, month, day, hour, min, sec]
endfunction


function! s:ConvertTimeToSeconds(timestamp)
    " First calculate seconds for the years elapsed
    " A day consists of 86400 seconds
    let seconds = (a:timestamp[0] - 2010) * 365 * 86400
    let seconds += (a:timestamp[1] * 30 * 86400) + (a:timestamp[2] * 86400) + (a:timestamp[3] * 3600) + (a:timestamp[4] * 60) + (a:timestamp[5])
    return seconds
endfunction


function! s:ConvertSecondsToDate(seconds)
    let num_seconds = a:seconds

    let year = num_seconds / (365*60*60*24)
    let num_seconds -= year * (365*60*60*24)
    let month = num_seconds / (30*60*60*24)
    let num_seconds -= month * (30*60*60*24)
    let days = num_seconds / (60*60*24)
    let num_seconds -= days * (60*60*24)
    let hours = num_seconds / (60*60)
    let num_seconds -= hours * (60*60)
    let minutes = num_seconds / 60
    let num_seconds -= minutes * 60

    return [year, month, days, hours, minutes, num_seconds]
endfunction


function! s:CalculateTimeElapsed(oldTimestamp, newTimestamp)
    let [year, month, day, hour, min, sec] = s:SplitStringTime(a:oldTimestamp)
    let [Year, Month, Day, Hour, Min, Sec] = s:SplitStringTime(a:newTimestamp)

    let old_seconds = s:ConvertTimeToSeconds([year, month, day, hour, min, sec])
    let new_seconds = s:ConvertTimeToSeconds([Year, Month, Day, Hour, Min, Sec])

    let diff_seconds = abs(new_seconds - old_seconds)

    return s:ConvertSecondsToDate(diff_seconds)
endfunction


function! s:TimeElapsedStr(timeElapsed)
    let timeElapsedString = ""

    if (a:timeElapsed[0] > 0)
        let timeElapsedString = a:timeElapsed[0] . " year "
    endif

    if (a:timeElapsed[1] > 0)
        let timeElapsedString = timeElapsedString . a:timeElapsed[1] . " month "
    endif

    if (a:timeElapsed[2] > 0)
        let timeElapsedString = timeElapsedString . a:timeElapsed[2] . " day "
    endif

    if (a:timeElapsed[3] > 0)
        let timeElapsedString = timeElapsedString . a:timeElapsed[3] . " hour "
    endif

    if (a:timeElapsed[4] > 0)
        let timeElapsedString = timeElapsedString . a:timeElapsed[4] . " min "
    endif

    if (a:timeElapsed[5] > 0)
        let timeElapsedString = timeElapsedString . a:timeElapsed[5] . " sec "
    endif

    if (len(timeElapsedString) > 0)
        let timeElapsedString = "Time elapsed: " . timeElapsedString
    endif

    return timeElapsedString
endfunction


function! LogpadInit()
    " check the configuration, set it (and exit) if needed
    if !exists('g:LogpadEnabled')        | let g:LogpadEnabled        = 1 | endif
    if !exists('g:LogpadInsert')         | let g:LogpadInsert         = 0 | endif
    if !exists('g:LogpadLineBreak')      | let g:LogpadLineBreak      = 0 | endif
    if !exists('g:LogpadIgnoreNotes')    | let g:LogpadIgnoreNotes    = 0 | endif
    if !exists('g:LogpadIgnoreReadOnly') | let g:LogpadIgnoreReadOnly = 0 | endif
    if !exists('g:LogpadLogDuration')    | let g:LogpadLogDuration = 0 | endif

    if g:LogpadEnabled == 0                          | return             | endif
    if g:LogpadIgnoreReadOnly == 0 && &readonly == 1 | return             | endif


    " main part
    if getline(1) =~ '^\.LOG$'
        call s:TryToFigureThatTimestampRegex()

        if nextnonblank(2) > 0
            if getline(nextnonblank(2)) !~ s:timestampformat && g:LogpadIgnoreNotes == 0
                " there are following lines, but these aren't timestamps,
                " obviously the user doesn't want to create a log then...
                return
            endif
        endif

        " add a new entry
        let s:failvar = 0
        while s:failvar != 1
            if g:LogpadLineBreak == 1
                " add a single empty divider line if requested
                let s:failvar = append(line('$'), "")
            endif

            " if g:LogpadLogDuration is defined then
            " move the cursor to the end of file.
            " search for the pattern
            " if pattern is present read it
            " calculate duration
            " log duration
            "
            let latestTime = strftime('%c')
            let s:duration = ""

            if g:LogpadLogDuration == 1
                call cursor(line('$'), 0)
                let linenumber = search(s:timestampformat, 'b')
                if (linenumber != 0)
                    let lastTimestamp = getline(linenumber)
                    let s:duration = s:TimeElapsedStr(s:CalculateTimeElapsed(lastTimestamp, latestTime))
                endif
            endif

            let s:failvar = append(line('$'), latestTime)

            if (len(s:duration) > 0)
                let s:failvar = append(line('$'), s:duration)
            endif

            let s:failvar = append(line('$'), "")

            " go to the last line
            call cursor(line('$'), 0)

            " if we're here, everything worked so far; let's exit
            let s:failvar = 1
        endwhile

        " enter insert mode if enabled
        if g:LogpadInsert == 1
            execute  ":startinsert" 
        endif
    endif
endfunction

autocmd BufReadPost * call LogpadInit()

" -------[ COMPAT COMMENTS ]-------

" GetLatestVimScripts: 2775 1 :AutoInstall: logpad.vim
" vim:ft=vim:sw=4:sts=4:et
