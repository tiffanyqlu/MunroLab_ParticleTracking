function subTracks = filterByFirstAndLast(tracks,first,last)


% filterByFirstAndLast returns the subset of particle trajectories that begin after
% timepoint specified by "first" and end before timepoint specified by
% "last"

%Inputs:

%   tracks:   =   An array of particle trajectory structures in format
%   produced by uTrackToSimpleTraj:
%
%       'first' =   the first movie frame in which this track appears
%       'last' =    the last movie frame in which this track appears.
%       'lifetime' = the length of the track in frames.
%       'x' = an array containing the sequence of x positions.
%       'y' = an array containing the sequence of y positions.
%       'I' = an array containing the intensity values.


%       first = first timepoint
%       last = last timepoint


%Output:

%   subTracks = subset of tracks satisfying track.first > min and track.last > max

    subTracks = tracks([tracks.first]>=first & [tracks.last]<=last);
 
end

