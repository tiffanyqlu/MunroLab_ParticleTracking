function subtracks = filterByD(tracks,maxTau,minD,maxD,movieInfo)
% Go through all input tracks and estimate short term 
% diffusivities and exponent alpha, then return only those with D less than the specified threshold 

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


% tau              Estimate D and alpha from MSD vs tau for tau <= maxTau.

% minD               keep all tracks with estimated D > minD 
%                   
% maxD               keep all tracks with estimated D < maxD 
%                   
% movieInfo           a struct containing the following fields:
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
            keep(i) = (D > minD && D < maxD);
        end
    end   
    subtracks = tracks(keep);
end

