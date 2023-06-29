# Scilab Project
 
This is a code that compares Vicon position data with acceleration data associated with angular velocity data from K-Invent's K-Move IMU.

All the scripts contained in this project were coded following the guidelines provided by Richard Johnson : https://www.ee.columbia.edu/~marios/matlab/MatlabStyle1p5.pdf

For this, we use the following folder architecture: 
- `WRK` : working directory for the data analysis
	- `DAT` : data used as input
	- `RES` : results of analyses
		- slow
		- average
		- fast
	- `PRG` : scripts and functions for the analysis

## DAT
In each sub-folder of `DAT` are the documents of a series of 8 squats performed at slow, average or fast speed. Each of these subfolders contains the following files (trialspeed corresponds to slow, average or fast): 
- IMU_trialspeedSquat.csv
	- A `n` lines × `15` columns file (n being the number of sample) where : 
		- The column 1 corresponds to the time
		- The columns 2 to 5 contain the quaternions (*not used*)
		- The columns 6 to 8 contain the acceleration data
		- The columns 9 to 11 contain the angular velocity data
		- The columns 12 to 14 contain the magnetometer data (*not used*)
- synchro_trialspeedSquat.csv
	- A `n + 1` lines × `5` columns file where 
		- The line 1 contains the column names
		- The column 1 corresponds to the time
		- The column 4 receives the synchro signal at the onset of the force plates
		- The columns 2, 3 and 5 don't have any input here (*not used*)
- vicon_trialspeedSquat.csv
	- A `n + 5` lines × `11` columns file where 
		- The lines 1 and 2 are useless
		- The line 3 contains the marker names
		- The line 4 contains the component (x, y or z) of the marker
		- The line 5 contains the unit of the marker
		- The column 1 contains the frame number
		- The column 2 is useless
		- The line 3 to 11 contain the `x`, `y` and `z` values of the markers `O`, `X` and `Y` disposed on the IMU to form a right angle
All those files columns are separated by `,` and the decimal are with `.`.

## PRG
The `PRG` file contains all the scripts necessary to run the analysis
- `main.sce` : the only script to run, it executes all the other scripts
- `InitTRT.sce` : compils all the function
- `SolidPosition.sce` : estimates the position xyz of a solid 
- `ImuAccelerationRotation.sce` : rotates the acceleration data of an IMU
- `ComparisonViconImu.sce` : compares the acceleration data from Vicon and from Imu

These functions are used in the scripts mentionned above, there are contained in the `PRG`repository too
- `printcenteredmessage.sci` : prints a centered message in the console
- `saveFigure.sci` : saves figure as png file
- signal_treatment
	- `fastfft.sci` : Create useful data from an FFT operation.
	- `fltsflts.sci` : filters the signal S using the filter hz with dual pass
	- `lowpassbuttdouble.sci` : low pass filter of a signal with dual pass Butterworh

# Usage 
- (Clone or) download the repository
- On your computer :
	- Open `main.sce` with scilab editor (SciNotes)
	- Run the script (press F5, or click the button with a triangle)

