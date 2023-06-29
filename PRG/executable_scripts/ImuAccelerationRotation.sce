// Short description
//  Rotates the acceleration data of an IMU
// 
// Calling Sequence
//  exec("ImuAccelerationRotation.sce")
//
// Parameters
//  The data from the IMU, which contains 15 columns : 
//   - Time
//   - wxyz quaternions
//   - xyz acceleration raw data
//   - xyz gyroscope raw data
//   - xyz magnetometer raw data
//
// Description
//  ImuAccelerationRotation allows to convert and rotate the raw acceleration 
//  data from an IMU, therefore in the body frame, to have acceleration data 
//  in the earth frame

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
// I. Create variables for each measurement and convert them

write(%io(2), "--> Loading files")

// # 1. Search the data from the csv file //////////////////////////////////////

dataImu = csvRead(imuFullFile);

// Create variables from the good columns of the file
timeImu = dataImu(:, 1);
accImu = dataImu(:, 6:8);
gyroImu = dataImu(:, 9:11);

// Calculate the sampling frequency from the time vector
SAMP_FREQ_IMU = 1./mean(diff(timeImu));

// #2. Acceleration data ///////////////////////////////////////////////////////

write(%io(2), "--> Convert and filter the data")
write(%io(2), "    1. Acceleration data")

//// #2.1 - Convert the raw data

// Convert the acceleration data first in G, then in m/s2
accConv = (accImu - 32768) .* (8/32768);  // In G
accConv = accConv * 9.81; // In m/s2

//// #2.2 - Filter the converted data

// The acceleration data are noisy, we will filter them to avoid the noise 
// First, make a Fourier transform of the signal to see the cutoff frequency
// that we are going to apply
figure(4); clf;
fastfft(accConv(:, 2), 100, [1])
title('Fast Fourier transform of the acceleration data (IMU)');
f = get('current_figure');
f.name = "Fast Fourier transform of the raw acceleration signal"

saveFigure(f.name, newResFolder);  // save figure

// Most of the spectral informations seem to be contained in frequencies < 10 Hz
// We use a double Butterworth filter with 10 Hz cutoff
CUTOFF_FREQ = 10; // set the cutoff frequency

accConvFiltered = zeros(accConv);  // Create an empty matrix of the same size

for nAcc = 1:size(accConv, 2)
    accConvFiltered(:, nAcc) = lowpassbuttdouble (accConv(:, nAcc), SAMP_FREQ_IMU, CUTOFF_FREQ);
end

// Make a figure to verify that the signal il filtered but not modified to much
figure(5); clf;

subplot(2, 1, 1)
plot(timeImu, accConv(:, 1), "color", BLUE)
plot(timeImu, accConv(:, 2), "color", GREEN)
plot(timeImu, accConv(:, 3), "color", RED)
xtitle("Raw angular velocity data")
legend("x", "y", "z")
ylabel('$\mathrm{Acceleration\;(m.s^{-2})}$')
xlabel("Time (s)")

subplot(2, 1, 2)
plot(timeImu, accConvFiltered(:, 1), "color", BLUE)
plot(timeImu, accConvFiltered(:, 2), "color", GREEN)
plot(timeImu, accConvFiltered(:, 3), "color", RED)
xtitle("Low-pass filtered angular velocity data")
legend("x", "y", "z")
ylabel('$\mathrm{Acceleration\;(m.s^{-2})}$')
xlabel("Time (s)")

f = get('current_figure');
f.name = "Comparison of the raw acceleration data with the filtered one"

saveFigure(f.name, newResFolder);  // save figure

// #3. Gyroscope data //////////////////////////////////////////////////////////

write(%io(2), "    1. Angular velocity data")

//// #3.1 - Convert the raw angular velocity data /////////////////////////////

gyroConv = (gyroImu - 32768) * (2000 / 32768); // in °/s

//// #3.2 - Filter the signal before integration //////////////////////////////

// The gyroscope data are noisy, we must filter them before integrating them
// otherwise the angle data will be unuseable
// Let's make a Fourier transform of the signal to see the cutoff frequency
// that we are going to apply
//figure(5); 
//fastfft(gyroConv(:,2), SAMP_FREQ_IMU, 1), 
// Most of the spectral informations seem to be contained in frequencies < 10 Hz
// We use a double Butterworth filter with 10 Hz cutoff
CUTOFF_FREQ = 10; // set the cutoff frequency

gyroConvFiltered = zeros(gyroConv);  // Create an empty matrix of the same size

for nAngVel = 1:size(gyroConv, 2)
    gyroConvFiltered(:, nAngVel) = lowpassbuttdouble (gyroConv(:, nAngVel), SAMP_FREQ_IMU, CUTOFF_FREQ);
end

// Make a figure to verify that the signal il filtered but not modified to much
figure(6); clf;

subplot(2, 1, 1)
plot(timeImu, gyroConv(:, 1), "color", BLUE)
plot(timeImu, gyroConv(:, 2), "color", GREEN)
plot(timeImu, gyroConv(:, 3), "color", RED)
xtitle("Raw angular velocity data")
legend("x", "y", "z")
ylabel("$\mathrm{Angular \ velocity\;(°.s^{-1})}$")
xlabel("Time (s)")

subplot(2, 1, 2)
plot(timeImu, gyroConvFiltered(:, 1), "color", BLUE)
plot(timeImu, gyroConvFiltered(:, 2), "color", GREEN)
plot(timeImu, gyroConvFiltered(:, 3), "color", RED)
xtitle("Low-pass filtered angular velocity data")
legend("x", "y", "z")
ylabel('$\mathrm{Angular \ velocity\;(°.s^{-1})}$')
xlabel("Time (s)")

f = get('current_figure');
f.name = "Comparison of the raw angular velocity data with the filtered one"

saveFigure(f.name, newResFolder);  // save figure

//// #3.3 - Integrate the angular velocity data ///////////////////////////////

write(%io(2), "--> Integration angular velocity data")

angleGyro = zeros(gyroConvFiltered);  // Create an empty matrix of the same size

for nAngVel = 1:size(gyroConvFiltered, 2)
    angleGyro(:, nAngVel) = cumsum(gyroConvFiltered(:, nAngVel)) .* (1 ./ SAMP_FREQ_IMU);
end

// Visualize the angle data
figure(7); clf;
plot(timeImu, angleGyro(:, 1), "color", BLUE)
plot(timeImu, angleGyro(:, 2), "color", GREEN)
plot(timeImu, angleGyro(:, 3), "color", RED)
title("Angular data calculated from the integration of angular velocity data")
legend("x", "y", "z")
ylabel("Angle (°)")
xlabel("Time (s)")

f = get('current_figure');
f.name = "Verification of the angular data"

saveFigure(f.name, newResFolder);  // save figure

////////////////////////////////////////////////////////////////////////////////
// II. Get acceleration data in the earth frame

write(%io(2), "--> Rotate the acceleration data with the angular data")

// 1. Rotate the acceleration data /////////////////////////////////////////////

// The acceleration data measured are in the "body frame", that means that the 
// xyz axis move with the IMU
// We want to compare these data to the one from the Vicon, where the xyz axis
// are fixed in the earth referential
// Therefore, we must rotate the acceleration data with the angle data to get
// the acceleration data from the imu in the "earth frame"

// To rotate the acceleration data from the "body frame" to the "world frame"
// we use the Euler matrix rotation, then we multiply the vector [x y z] by the
// rotation matrix R for each sample
// The rotation matrix R is calculated from the angle that we previously
// calculated (#3.3)

accEarthFrame = zeros(accConvFiltered);  // Create an empty matrix of the same size

for nAngle = 1:size(angleGyro, 1)
    
    ALPHA = angleGyro(nAngle, 1);
    BETA = angleGyro(nAngle, 2)
    GAMMA = angleGyro(nAngle, 3)
    
    // R is the matrix product of Rx, Ry and Rz, calculated as 
    Rx = [
        1 0 0;
        0 cosd(ALPHA) -sind(ALPHA); 
        0 sind(ALPHA) cosd(ALPHA)
        ];
    
    Ry = [
        cosd(BETA) 0 sind(BETA);
        0 1 0;
        -sind(BETA) 0 cosd(BETA)
        ]';
    
    Rz = [
        cosd(GAMMA) -sind(GAMMA) 0;
        sind(GAMMA) cosd(GAMMA) 0;
        0 0 1
        ]';
    
    R = Rz * Ry * Rx
    
    // The acceleration in the "earth frame" for the sample nAngle is calculated
    // as the matrix product between the xyz acceleration data and R
    accEarthFrame(nAngle, :) = accConvFiltered(nAngle, :) * R;
end


// 2. Supress the gravity //////////////////////////////////////////////////////

// We don't want to take the gravity into account
// Because it is constant, the gravity applied to the IMU will be constant and
// vertical at 9.81 m/s2
// The IMU was placed on the barbell such as it was the y axis that was aligned
// vertically
// However, since we couldn't verify if it was placed correctly, we consider
// that the gravity vector will be equal to the first values of acceleration
// of the accelerometer
// Since it is constant in the earth frame, we don't have to rotate it
G = accConvFiltered(1, :);

accSpecificEarthFrame = zeros(accEarthFrame);  // Create an empty matrix of the same size

// Now, we substract G from the rotated values to get the specific acceleration
for nAcc = 1: size(accEarthFrame, 1)
    accSpecificEarthFrame(nAcc, :) = accEarthFrame(nAcc, :) - G;
end

// Plot a comparison between the acceleration in the body frame,
// in the earth frame and without gravity
figure(8); clf;

subplot(3, 1, 1)
plot(timeImu, accConvFiltered(:, 1), "color", BLUE)
plot(timeImu, accConvFiltered(:, 2), "color", GREEN)
plot(timeImu, accConvFiltered(:, 3), "color", RED)
xtitle("Acceleration in the body frame")
legend("x", "y", "z")
ylabel('$\mathrm{Acceleration\;(m.s^{-2})}$')
xlabel("Time (s)")


subplot(3, 1, 2)
plot(timeImu, accEarthFrame(:, 1), "color", BLUE)
plot(timeImu, accEarthFrame(:, 2), "color", GREEN)
plot(timeImu, accEarthFrame(:, 3), "color", RED)
xtitle("Acceleration in the earth frame")
legend("x", "y", "z")
ylabel('$\mathrm{Acceleration\;(m.s^{-2})}$')
xlabel("Time (s)")

subplot(3, 1, 3)
plot(timeImu, accSpecificEarthFrame(:, 1), "color", BLUE)
plot(timeImu, accSpecificEarthFrame(:, 2), "color", GREEN)
plot(timeImu, accSpecificEarthFrame(:, 3), "color", RED)
xtitle("Acceleration in the earth frame without gravity (specific acceleration)")
legend("x", "y", "z")
ylabel('$\mathrm{Acceleration\;(m.s^{-2})}$')
xlabel("Time (s)")

f = get('current_figure');
f.name = "Comparison of acceleration data in the body frame, in the earth frame and without gravity"

saveFigure(f.name, newResFolder);  // save figure


write(%io(2), "=======================================================================")
write(%io(2), "")
