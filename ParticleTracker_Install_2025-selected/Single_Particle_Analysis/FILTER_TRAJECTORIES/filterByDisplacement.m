function subtracks = filterByDisplacement(trks,movieInfo,deltaT, minD, maxD)
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

% deltaT      compute displacements for deltaT measured in seconds    

% minD  Return all tracks with disaplcement greater than minD measured in microns

% maxD  Return all tracks with disaplcement less than maxD measured in microns

% movieInfo         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm
% 
% Output:

% subtracks          The filtered sublist of tracks.

    % convert deltaT to frames
    deltaF = fix(deltaT*movieInfo.frameRate);

    trks = trks([trks.lifetime]>deltaF+1);
    numTracks = size(trks,2);
    keep = logical(zeros(numTracks,1));

    for i=1:numTracks  
        maxF = trks(i).lifetime;
        dx = trks(i).x(deltaF+1:maxF) - trks(i).x(1:maxF-deltaF);
        dy = trks(i).y(deltaF+1:maxF) - trks(i).y(1:maxF-deltaF);
        D = sqrt(dx.*dx + dy.*dy)*movieInfo.pixelSize;
        D = max(D)
        keep(i) = (D >= minD & D <= maxD);
    end
    subtracks = trks(keep);
end

