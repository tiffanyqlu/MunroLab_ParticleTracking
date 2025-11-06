function slopes = plotSpeedHistogram(trks,movieInfo, minT,maxT)
% Compute msd vs tau for tau < maxTau

% Inputs:

% trks = an array of particle tracks in simple format
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% movieInfo         =   a struct containing the following fields:
%     
%     baseName:       original datafile name minus the ".tif" ext
%     frameRate:      in #/sec
%     pixelSize:      in µm
%     firstFrame      first frame of movie segment 
%     lastFrame:      last frame of movie segment 


% 
% Output

% slopes    array of slopes
    trks = trks([trks.lifetime]>maxT+1);
    maxTrackSize = max([trks.lifetime]);
    numTracks = size(trks,2)
    X = 1:maxTrackSize;
    frameInterval = 1/movieInfo.frameRate;
    X=X*frameInterval;    
    
    slopes = zeros(numTracks,1);


    for i=1:numTracks  
        msd = getMSDvsTAU(trks(i),maxT+1,movieInfo); 
        slopes(i) = (log(msd(maxT))-log(msd(minT)))/(log(X(maxT)) - log(X(minT)));
    end

    figure; hold;
    binwidth = max(slopes/30);
    histogram(slopes,'BinWidth',binwidth,'Normalization','probability');

end



