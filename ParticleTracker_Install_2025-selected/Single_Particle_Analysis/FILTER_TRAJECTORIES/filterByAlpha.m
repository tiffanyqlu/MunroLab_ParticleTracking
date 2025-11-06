function subtracks = filterByAlpha(tracks,maxTau,minAlpha, maxAlpha,movieInfo)
% Go through all input tracks, estimate short term (tau <= maxTau)
% diffusivities and exponent alpha, then return only those with alpha less than the specified threshold 

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


% maxTau            Estimate D and alpha from MSD vs tau for tau <= maxTau.
%                   
% minAlpha          Return all tracks with estimated alpha > minAlpha.
%                   
% maxAlpha          Return all tracks with estimated alpha < maxAlpha.

% movieInfo         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm
% 
% Output:

% subtracks          The sublist of tracks.

    numTracks = size(tracks,2);
    keep = logical(zeros(1,numTracks));    
    for i=1:numTracks
        if tracks(i).lifetime < maxTau + 1
            keep(i) = 0;
        else
            [D,alpha] = getDAlpha(tracks(i),maxTau,movieInfo);
            keep(i) = (alpha>minAlpha && alpha<maxAlpha)
        end
    end   
    subtracks = tracks(keep);
end

