function [ subTracks ] = filterByMSDAtTau(trks,tau, minMSD, maxMSD, movieInfo)


% filterByMSDAtTau returns the subset of particle tracks whose for whch MSD at time lag tau (measured in frames)
% is greater than minMSD and less than maxMSD .

%Inputs:

%   trks:   =   An array of particle trajectory structures in format
%   produced by uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.

    
% tau               =    time lag measured in frames.

% minMSD            =   min value of MSD .
%                   
% maxMSD            =    max value of MSD .
%                   
% movieInfo         =   a struct containing the following fields:

%Output:

%   subTracks = subset of tracks statisfying min < track length 

    numTracks = size(trks,2);
    msds = zeros(1,numTracks);
    for i = 1:numTracks
        msd = getmaxMSDatTAU(trks(i),tau,movieInfo);                       
        msds(i) = msd(tau);
    end
    subTracks = trks(msds >=minMSD && msds <=maxMSD);
end

