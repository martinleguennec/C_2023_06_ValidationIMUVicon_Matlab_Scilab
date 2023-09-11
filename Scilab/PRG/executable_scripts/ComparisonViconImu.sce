// Short description
//  Compares the acceleration data from Vicon and from Imu
// 
// Calling Sequence
//  exec("ComparisonViconImu.sce")
//
// Parameters
//  - The position data from the Vicon (n x 3) and the time vector
//  - The acceleration data in the earth frame from the IMU (n x 3) and his
//    time vector
//
// Description
//  ComparisonViconImu compares the acceleration data from the Vicon and
//  the rotated acceleration data (in the earth frame) from an IMU
//  To prepare the data necessary for this script, you can execute 
//  SolidPosition.sce and ImuAccelerationRotation.sce

////////////////////////////////////////////////////////////////////////////////
// Inform the user
write(%io(2), "=======================================================================")
write(%io(2), "Currently executing SolidPosition.sce")
write(%io(2), "")

////////////////////////////////////////////////////////////////////////////////
// I. Synchronise the signals

write(%io(2), "--> Loading files")

// The Vicon and the IMU were not set on at the same time
// The Vicon was set on before with a synchronization signal, then, when the IMU
// was set on, it sent a input to the synchronization signal
// Therefore, we need to cut the Vicon signal in order for the IMU and Vicon data
// to start at the same time

// 1. Load the synchronization signal //////////////////////////////////////////

dataSynchro = mgetl(synchroFullFile);
dataSynchro = dataSynchro(2:$);
dataSynchro = csvTextScan(dataSynchro, ",", ".")

// The input from the Vicon is contained on the 4th column and the time is 
// contained in the first one
timeSynchro = dataSynchro(:, 1);
signalSynchro = dataSynchro(:, 4);


// 2. Search the input from the IMU ////////////////////////////////////////////

write(%io(2), "--> Signal synchronization")

// First, we need to establish a baseline value then we define a threshold that
// we define as baseline + 1 % baseline
// The baseline isn't suppose to vary except when the synchro signal receives
// an input, therefore, we apply a threshold very close the the baseline to 
// detect the real onset of the signal
BASELINE = mean(signalSynchro(1:10));  // Calculate the baseline as mean of 10 first values
THRESHOLD = BASELINE + (5 ./ 100 .* BASELINE);  // Set the threshold at 5%

// The onset of the signal is the first value > threshold
onsetSignalSynchro = find(signalSynchro >= THRESHOLD, 1);
timeOnsetSynchro = timeSynchro(onsetSignalSynchro);

// Plot to verify if the onset is correctly determined

    // Prepare values to plot the threshold
    begThreshold = timeSynchro(1); endThreshold = timeSynchro($);
    xThreshold = [begThreshold endThreshold];  // Define x values as first and last time values
    yThreshold = [THRESHOLD THRESHOLD];  // y values correspond to the threshold value
    
    // Prepare values to plot vertical line at the moment of the onset
    xOnsetLine = [timeOnsetSynchro timeOnsetSynchro];  // x values correspond to the threshold value
    maxYOnsetLine = max(solidPositionFiltered); minYOnsetLine = min(solidPositionFiltered);
    yOnsetLine = [maxYOnsetLine minYOnsetLine];  // The y values of the line will correspond to max and min of position signals

figure(9); clf;
subplot(2, 1, 1)
plot(timeSynchro, signalSynchro)
plot(xThreshold, yThreshold, "--", "color", BLACK)  // This plots an horizontal line corresponding to the threshold
plot(timeSynchro(onsetSignalSynchro), signalSynchro(onsetSignalSynchro), "*r")  // This plots the onset of synchro
xtitle("Detection of the onset of the synchronization signal")
legend("Synchronization signal", "Threshold", "Onset")
ylabel("Signal amplitude (V)")
xlabel("Time(s)")

subplot(2, 1, 2)
plot(timeVicon, solidPositionFiltered(:, 1), "color", BLUE)
plot(timeVicon, solidPositionFiltered(:, 2), "color", GREEN)
plot(timeVicon, solidPositionFiltered(:, 3), "color", RED)
plot(xOnsetLine, yOnsetLine, "--", "color", TURQUOISE)  // This plots an vertical line corresponding to the onset of synchronization
xtitle("Position of the center of mass of the IMU")
legend("x", "y", "z", "Onset")
ylabel("Position (m)")
xlabel("Time (s)")

f = get('current_figure');
f.name = "Detection of the onset of the synchronization signal"

saveFigure(f.name, newResFolder);  // save figure

// 3. Cut the position signal //////////////////////////////////////////////////

// Cut the first values of the position signal, calculated from the Vicon data,
// to correspond to the onset of the IMU values 
begRealVicon = find(timeVicon > timeOnsetSynchro, 1);

timeViconSynchro = timeVicon(begRealVicon : $);
timeViconSynchro = timeViconSynchro - timeViconSynchro(1);
solidPositionFilteredSynchro = solidPositionFiltered(begRealVicon : $, :);



////////////////////////////////////////////////////////////////////////////////
// II. Compare the accelerations

write(%io(2), "--> Comparison of the accelerations")

accVicon = diff(solidPositionFilteredSynchro, 2, "r") ./ ((1 ./ SAMP_FREQ_VICON).^ 2);


// Plot comparison between vicon and IMU derived values
figure(10); clf;

plot(timeViconSynchro(1:$-2), accVicon(:, 3), "color", RED)
plot(timeImu, accConv(:, 3), "color", BLUE)
plot(timeImu, accSpecificEarthFrame(:, 3), "color", GREEN)
xtitle("Comparison of the z acceleration data from the Vicon, from the IMU, and rotated from the IMU")
legend("Vicon", "Raw IMU", "Rotated IMU")

f = get('current_figure');
f.name = "Comparison of the acceleration data from the Vicon, from the IMU, and rotated from the IMU"

saveFigure(f.name, newResFolder);  // save figure


write(%io(2), "=======================================================================")
write(%io(2), "")
