function subtracks = filterByD_Alpha(tracks,maxTau,D_range,alpha_range,movieInfo)
% Go through all input tracks, estimate short term (tau <= maxTau)
% diffusivities and exponent alpha, then return only those with D and alpha less than the specified threshold 

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

% D_range              Return all tracks with estimated D_range(1) < D < D_range(2).
%                   
% alpha_range          Return all tracks with estimated alpha_range(1) < alpha < alpha_range(2).

% movieInfo         =   a struct containing the following fields:
%     
%     baseName:       original datafile name minus the ".tif" ext
%     frameRate:      in #/sec
%     pixelSize:      in µm
%     firstFrame      first frame of movie segment 
%     lastFrame:      last frame of movie segment 
%     APOrientation:  0 if anterior is to the left; 1 if it is to the right 
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
            keep(i) = (D>D_range(1))&(D<D_range(2))&(alpha>alpha_range(1))&(alpha<alpha_range(2));
        end
    end
    subtracks = tracks(keep);

end

