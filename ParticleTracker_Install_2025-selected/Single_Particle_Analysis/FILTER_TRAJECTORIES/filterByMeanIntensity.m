function [ subTracks ] = filterByMeanIntensity(tracks,minI,maxI)


% filterByMaxI returns the subset of particle tracks whose max intensities lie between 
% maxI and minI .

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


%   minI, maxI

%Output:

%   subTracks = subset of tracks statisfying min < mean(tracks.I) < max
        
    m = cellfun(@mean,{tracks.I});
    subTracks = tracks((m>=minI)&(m<=maxI));
 
end
