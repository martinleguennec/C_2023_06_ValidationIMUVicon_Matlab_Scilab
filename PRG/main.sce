// Short description
//  Initializes then executes the code
// 
// Calling Sequence
//  exec("main.sce")
//
// Parameters
//  none
//
// Description
//  main initializes the workspace by executing InitTRT, then create useful
//  variables and executes the scripts that allow to compare the Vicon data to
//  the one from the IMU

// Authors
//  Martin Le Guennec - Univ. Montpellier - France
//
// Versions
//  Version 1.0.0 -- M. Le Guennec -- 2023-05-01
//    First version

////////////////////////////////////////////////////////////////////////////////
// I. Initialize

clear;
clc;

PRG_PATH = get_absolute_file_path("main.sce");          
FullFileInitTRT = fullfile(PRG_PATH, "InitTRT.sce" );
exec(FullFileInitTRT); 


////////////////////////////////////////////////////////////////////////////////
// II. Create useful variables

// Create variable with RGB values for the colors that we will use in the plots
BLUE = [0 0 1];
GREEN = [0 0.5 0];
RED = [1 0 0];
BLACK = [0 0 0];
TURQUOISE = [0 0.75 0.75];

////////////////////////////////////////////////////////////////////////////////
// III. Execute the scripts


// Identify all the paths contained in the DAT repository
trials = listfiles(DAT_PATH)

// Loop through them
for nTrial = 1 : size(trials, "*")
    trial = trials(nTrial)
    trialPath = fullfile(DAT_PATH, trial)
    
    close(winsid());     // delete all graphic windows
    
    // We only want the repositories in the DAT repository
    if isdir(trialPath)
        
        // Inform the user
        write(%io(2), "")
        write(%io(2), "#######################################################################")
        printcenteredmessage("Treating repository " + trial)
        write(%io(2), "")
        
        
        // Prepare the full file path for the different csv files to read them afterwards
        imuFullFile = "DAT/" + trial + "/IMU_" + trial + "Squat.csv";
        viconFullFile = "DAT/" + trial + "/vicon_" + trial + "Squat.csv";
        synchroFullFile = "DAT/" + trial + "/synchro_" + trial + "Squat.csv";
        
        // Create a new folder for the figures of the trial
        newResFolder = fullfile(RES_PATH, trial)
        createdir(newResFolder)
        
        // Execute the scripts
        exec(fullfile(PRG_PATH, "executable_scripts/SolidPosition.sce"), 'errcatch', -1);
        exec(fullfile(PRG_PATH, "executable_scripts/ImuAccelerationRotation.sce"), 'errcatch', -1);
        exec(fullfile(PRG_PATH, "executable_scripts/ComparisonViconImu.sce"), 'errcatch', -1);
        
        // Inform the user
        write(%io(2), "All the scripts have been successfully executed !")
        write(%io(2), "")
        write(%io(2), "#######################################################################")
        write(%io(2), "")
    end
end

// Inform the user
write(%io(2), "All the directories have been treated !")
