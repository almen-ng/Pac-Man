%Display Intstruction


proc displayInstructionWindow

    cls
    var stream : int
    open : stream, "files/text/instructions.txt", get

    if stream > 0 then

	var Lines : string
	loop
	    exit when eof (stream)
	    get : stream, Lines : *
	    put Lines

	end loop
	close : stream
    else
	put "Unable to open file."

    end if

    var anyKey : string (1)

    put "\n\n   Enter any key to exit:  " ..
    getch (anyKey)

end displayInstructionWindow
