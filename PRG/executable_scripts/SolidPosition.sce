// Short description
//  Estimates the position xyz of a solid 
// 
// Calling Sequence
//  exec("SolidPosition.sce")
//
// Parameters
//  The values xyz of the 3 markers in a single matrix with 9 columns :
//   - xyz of the first marker
//   - xyz of the second marker
//   - xyz of the third marker
//
// Description
//  SolidPosition estimates the position xyz of the center of mass of a solid 
//  with the xyz values of 3 markers placed on the solid of interest
//  The 3 markers form an right angle, the marker O being the angle while the markers
//  A and B were placed in the corners of the solid

// Authors
//  Martin Le Guennec - Univ. Montpellier - France
//
// Versions
//  Version 1.0.0 -- M. Le Guennec -- 2023-04-29
//    First version

////////////////////////////////////////////////////////////////////////////////
// Inform the user
write(%io(2), "=======================================================================")
write(%io(2), "Currently executing SolidPosition.sce")
write(%io(2), "")

////////////////////////////////////////////////////////////////////////////////
// I. Load the files and create variables

write(%io(2), "--> Loading files")

// We cant read the data with csvRead of fscanfMat because its structure doesn't
// allow it
// We will load them with mgetl, delete the first lines that comprimise the 
// structure then split the array columns with csvTextScan
dataVicon = mgetl(viconFullFile);
dataVicon = dataVicon(6:$);
dataVicon = csvTextScan(dataVicon, ",", ".");

dataVicon = dataVicon(:, 3:$);  // The 2 first columns don't contain any data
dataVicon = dataVicon ./ 1000;  // The data are in mm, we convert them in m

// We create a time variable with the sampling frequency
SAMP_FREQ_VICON = 100;
timeVicon = 0 : 1 ./ SAMP_FREQ_VICON : (size(dataVicon, 1)- 1)./100; 
timeVicon = timeVicon';


////////////////////////////////////////////////////////////////////////////////
// II. Create 3 vectors x, y and z

// The center of mass of the solid can be calculated as the mean of the 
// coordinates of the markers A and B
// Given that they are placed on opposite corners, the mean of their coordinates
// should give us the coordinates of the center the solid

x = mean(dataVicon(:, [4, 7]), 2);
y = mean(dataVicon(:, [5, 8]), 2);
z = mean(dataVicon(:, [6, 9]), 2);

solidPosition = [x, y, z];

// Plot the solid's center of mass position as a function of time
figure(1); clf;
plot(timeVicon, x, "color", BLUE)
plot(timeVicon, y, "color", GREEN)
plot(timeVicon, z, "color", RED)
title("Estimation of the positon of the center of mass of the IMU (Vicon)")
legend("x", "y", "z")
ylabel("Position (m)")
xlabel("Time (s)")
f = get('current_figure');
f.name = "Estimation of the positon of the center of mass of the IMU"

saveFigure(f.name, newResFolder);  // save figure


////////////////////////////////////////////////////////////////////////////////
// III. Filter the signals

write(%io(2), "--> Filtering signals")

// The signal is noisy due to high frequency noise
// To get rid of this noise, we apply a Butterworth low pass filter
// Before applying a filter, we must determine its parameters

// Plot fast Fourier transform
figure(2); clf;
fastfft(z, 100, [1]);
title('Fast Fourier transform of the position signal (Vicon)');
f = get('current_figure');
f.name = "Fast Fourier transform of the raw position signal"

saveFigure(f.name, newResFolder);  // save figure



// As we can see from the Fourier Transform, most of the spectral information 
// of the signal is below 5 Hz
// We will use this value as our cutoff frequency
CUTOFF_FREQ = 5;

solidPositionFiltered = zeros(solidPosition);  // Create an empty matrix of the same size

for nCoordinates = 1:size(solidPosition, 2)
    solidPositionFiltered(:, nCoordinates) = lowpassbuttdouble (solidPosition(:, nCoordinates), SAMP_FREQ_VICON, CUTOFF_FREQ);
end

// Plot a comparison of raw and filtered signal of z values
figure(3); clf;
plot(timeVicon, solidPosition(:, 3), "color", RED)
plot(timeVicon, solidPositionFiltered(:, 3), "color", TURQUOISE)
title("Comparison of raw and low-pass filtered signal of position (Vicon)")
legend("Raw signal", "Filtered signal")
ylabel("Position (m)")
xlabel("Time (s)")
f = get('current_figure');
f.name = "Comparison of raw and low-pass filtered signal of position"

saveFigure(f.name, newResFolder);  // save figure


write(%io(2), "=======================================================================")
write(%io(2), "")
