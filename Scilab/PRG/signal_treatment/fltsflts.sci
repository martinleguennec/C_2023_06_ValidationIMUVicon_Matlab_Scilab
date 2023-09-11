function Sf = fltsflts(S, hz, Npad)
    // fltsflts : filters the signal S using the filter hz with dual pass
    //
    // Calling Sequence
    //   Sf = fltsflts(S, hz [, Npad])
    //
    // Parameters
    //  S    : vector, the input signal
    //  hz   : syslin, the transfer function (from iir or fir, or ...)
    //  Npad : integer, the number of padding points (default value = 60)
    //  Sf   : vector, the filtered signal (same size as input)
    //
    // Description
    // fltsflts filters the signal S using the filter hz to produce the filtered 
    //  signal Sf. The signal S is filterd twice, in chronological and anti-
    //  chronological directions. This method cancels the phase lag of the 
    //  causal filter and doubles the order of the filter. Padding points are 
    //  inserted at the beg and end of S, to consume statrting effects of hz.
    //
    // Examples
    //  T = linspace(0,10,1001);
    //  S = sin(2*%pi*T)+sin(20*%pi);
    //  hz = iir(2, 'lp', 'butt', [1/10, 0], [0,0]);
    //  Sf = fltsflts(S, hz, Npad);
    //  plot(T, S, '-k', T, Sf, '-b')
    //
    // Authors
    //  Denis Mottet - Univ Montpellier - France
    //
    // Versions
    //  D. Mottet, 2011-06-17, Version 2.0.0
    //    Added padding at beg and end of signal (reflexion)
    //    This takes into account the edges effects and initial conditions
    //  D. Mottet, 2018-03-23, Version 2.0.1
    //    Bug correction when input too short for padding (search #2.01)
    //    Documentation following
    //      https://wiki.scilab.org/Guidelines%20To%20Design%20a%20Module



    DataSize = size(S);      // size of the input
    
    ////////////////////////////////////////////////////////////////////////////
    DoDebug = %f; 
    NoFig = 10000;          // To turn visualisation on, and see what happens...
    ////////////////////////////////////////////////////////////////////////////
    
    // argument check...
    if min(DataSize) ~= 1 then
        error("S must be a vector")
    end

    // Improvement May 17, 2011
    // We need to add some data to consume the "end effects" of the filter
    // We do a reflection of the data at the edges (size = 5 * order of filter) => 50 data points
    // 2016-05-28 : trials with constant data indicates that 55 is a minimum
    if argn(2) < 3 then                   // Npad should be about 1 sec of recording
        Npad = 60;
    end
    if max(DataSize) < Npad then
        Npad = max(DataSize) ;            // we can padd only with existing data
        Npad = Npad - 2 ;                 // we shall use a data shift of 2...  -- Bug cor #2.01
        warning ("fltsflts:Input data is too short : potentially wrong results...");
    end

    // Prepare padding data (reflection)
    BgPad = 2*S(1)- S(2:Npad+1);      // we skip the edge data (S(1))
    EdPad = 2*S($)- S($-Npad : $-1);  // we skip the edge data (S($))
    BgPad = BgPad($:-1:1);    // reverse time for reflection
    EdPad = EdPad($:-1:1);


    // flts accepts only LINE vectors : we need to transpose if S is a column vector
    FlagTranspose = %f;        // guess...
    if size(S, 1) > 1 then
        S = S';
        BgPad = BgPad';
        EdPad = EdPad';
        FlagTranspose = %t;    // we recall to transpose
    end

    S = [BgPad , S , EdPad];    // reflection at both ends

    ////////////////////////////////////////////////////////////////////////////
    // main part here 
    S1 = flts(S, hz);        // first filter
    S1 = S1($:-1:1);         // reverse order (time)
    Sf = flts(S1, hz);       // filter again (anti-chronological)
    Sf = Sf($:-1:1);         // do not forget to go back to chronological order
    ////////////////////////////////////////////////////////////////////////////
    
    if DoDebug then
        T = cumsum(ones(S));
        figure(NoFig);
        title("Filtering : data + padding at edges")
        plot(T, S, "-k")
        plot(T, Sf, "-r")
        plot(T(Npad:$-Npad), S(Npad:$-Npad), "-b")
        plot(T(Npad:$-Npad), Sf(Npad:$-Npad), "-c")
        plot(T(Npad), Sf(Npad), "sqr")
        plot(T($-Npad), Sf($-Npad), "sqr")
        legend("reflected Input","refelected filtered", "Input", "Filtered ")
    end


    Sf = Sf(Npad + 1 : $-Npad); // undo reflection at both ends


    if FlagTranspose then
        Sf = Sf';
    end


endfunction
