function [vFrequency, vAmplitude] = fastfft(S, sampFreq, makePlot)
    // fastfft : Create useful data from an FFT operation
    //
    // Calling Sequence
    //  [vFrequency, vAmplitude] = fastfft(S, sampFreq, [plot])
    //
    // Parameters
    //  S           : vector,  the input signal
    //  sampFreq    : number,  sampling frequency in Hz
    //  makePlot    : number,  make a plot if the input is 1 and doesn't make it 
    //                         if the input is 0
    //
    // Outputs
    //  vFrequency  : vector,  frequency scale
    //  vAmplitude  : vector,  amplitude of the frequency scale calculated from 
    //                         fft
    //
    // Description
    //  fastfft :
    //     1: Removes the DC offset of the data
    //     2: Puts the data through a hanning window
    //     3: Calculates the Fast Fourier Transform (FFT)
    //     4: Calculates the amplitude from the FFT
    //     5: Calculates the frequency scale
    //     6: Optionally creates a Bode plot
    //
    // Authors
    //  Rick Auch (Creator)
    //  Martin Le Guennec - Univ Montpellier - France
    //
    // Versions
    //  Version 1.0.0 -- R. Auch -- 2003-22-07
    //    First version for matlab use
    //    Rick Auch (2023). FastFFT Function (https://www.mathworks.com/matlabcentral/fileexchange/3770-fastfft-function), MATLAB Central File Exchange. Retrieved May 2, 2023.
    //  Version 1.0.1 -- M. Le Guennec -- 2023-05-02
    //    Adaptation of the function for scilab use
    
    //Make S a row vector
    if size(S,2)==1
        S = S';
    end
    
    //Calculate number of data points in data
    n = length(S);
    
    //Remove DC Offset
    S = S - mean(S);
    
    //Put data through hanning window using hanning subfunction
    S = hanning(S);
    
    //Calculate FFT
    S = fft(S);
    
    //Calculate amplitude from FFT (multply by sqrt(8/3) because of effects of hanning window)
    vAmplitude = abs(S)*sqrt(8/3);
    
    //Calculate frequency scale
    vFrequency = linspace(0,n-1,n)*(sampFreq/n);
    
    //Limit both output vectors due to Nyquist criterion
    DataLimit = ceil(n/2);
    vAmplitude = vAmplitude(1:DataLimit);
    vFrequency = vFrequency(1:DataLimit);
    
    if makePlot == 1 then
        plot(vFrequency, vAmplitude);
        title('Fast Fourier transform of the signal');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');
    end

endfunction

//------------------------------------------------------------------------------------------
//Hanning Subfunction
function vOutput = hanning(vInput)
    // hanning : Takes a vector input and outputs the same vector, multiplied by
    //           the hanning window function
    //
    // Calling Sequence
    //  vOutput = hanning(vInput)
    //
    // Parameters
    //  vInput  : vector,  the input vector
    //
    // Output
    //  vOutput  :
    //  S         : vector,  the input signal
    //  sampFreq  : number,  sampling frequency in Hz
    //  makePlot  : number,  make a plot if the input is 1 and don't make it if 
    //                       the input is 0
    //
    // Description
    //  fastfft :
    //     1: Removes the DC offset of the data
    //     2: Puts the data through a hanning window
    //     3: Calculates the Fast Fourier Transform (FFT)
    //     4: Calculates the amplitude from the FFT
    //     5: Calculates the frequency scale
    //     6: Optionally creates a Bode plot
    
    // This function takes a vector input and outputs the same vector,
    // multiplied by the hanning window function
    //Determine the number of input data points
    n = length(vInput);
    //Initialize the vector
    vHanningFunc = linspace(0,n-1,n);
    //Calculate the hanning funtion
    vHanningFunc = .5*(1-cos(2*%pi*vHanningFunc/(n-1)));
    //Output the result
    vOutput = vInput.*vHanningFunc;
endfunction

