function [ subTracks ] = filterByLifetime(tracks,minLength,maxLength)


% filterByLifetime returns the subset of particle tracks whose lengths lie within 
% the range defined by max_min_track_L.

%Inputs:

%   tracks:   =   An array of particle trajectory structures in format
%   produced by uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


%  minLength

%Output:

%   subTracks = subset of tracks statisfying min < track length

  
    subTracks = tracks([tracks.lifetime]>minLength);

    if nargin >= 3
        subTracks = subTracks([subTracks.lifetime]<=maxLength);
    end
    
end

