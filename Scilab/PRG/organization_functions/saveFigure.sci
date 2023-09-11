function saveFigure(fName, repositoryPath)
    // saveFigure : saves figure as png file
    //
    // Calling Sequence
    //  saveFigure(fName, repositoryPath)
    //
    // Parameters
    //  fName           :  character string,  the name of the figure
    //  repositoryPath  :  character string,  the path of the directory to store
    //                     the png file
    //
    // Description
    //  saveFigure : save a figure as a png file in the directory specified by
    //  the user
    //
    // Authors
    //  Martin Le Guennec - Univ Montpellier - France
    //
    // Versions
    //  Version 1.0.0 -- M. Le Guennec -- 2023-05-02
    //    First version
    
    // Create the full path to store the figure
    figureFileName = fullfile(repositoryPath, fName + ".png")
    
    // Save the figure
    xs2png(gcf(), figureFileName)
    
    // Inform the user
    write(%io(2), "      Figure saved")
    
endfunction
