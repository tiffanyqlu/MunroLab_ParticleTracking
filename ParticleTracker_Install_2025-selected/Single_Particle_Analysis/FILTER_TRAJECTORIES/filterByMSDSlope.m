function subtracks = filterByMSDSlope(trks,movieInfo,maxTau, minSlope, maxSlope)
% Go through all input tracks, for each compute MSD vs tau

% Inputs:

% tracks = a list of particle tracks which is assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.

% maxTau    

% minSlope  Return all tracks with slope greater than minSlope

% maxSlope  Return all tracks with slope less than maxSlope




% movieInfo         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm
% 
% Output:

% subtracks          The sublist of tracks.

    trks = trks([trks.lifetime]>maxTau+1);
    maxTrackSize = max([trks.lifetime]);
    numTracks = size(trks,2)
    X = 1:maxTrackSize;
    frameInterval = 1/movieInfo.frameRate;
    X=X*frameInterval;        
    slopes = zeros(numTracks,1);

    for i=1:numTracks  
        msd = getMSDvsTAU(trks(i),maxTau+1,movieInfo); 
        slopes(i) = (log(msd(maxTau))-log(msd(1)))/(log(X(maxTau)) - log(X(1)));
    end
    subtracks = trks((slopes<maxSlope)&(slopes>minSlope));

end

