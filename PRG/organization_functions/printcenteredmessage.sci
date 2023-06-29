function printcenteredmessage(message)
    // printcenteredmessage : prints a centered message in the console
    //
    // Calling Sequence
    //  printcenteredmessage(message)
    //
    // Parameters
    //  message  : character string,  the message to print
    //
    // Description
    //  printcenteredmessage : prints a centered message in the console
    //
    // Authors
    //  Martin Le Guennec - Univ Montpellier - France
    //
    // Versions
    //  1.0.0 -- M. Le Guennec -- 2023-05-02
    //    First version
    
    width = 60; // The width of the console
    printf("%*s\n", (width + length(message)) / 2, message);
    
endfunction
