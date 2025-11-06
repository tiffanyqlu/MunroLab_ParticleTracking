function speeds = getSpeeds(trks,info, sgWindowSize)

% Project points along a given trajectory to a smoothed version of that trajectory, compute the cumulative distance 
% vs time, and fit a line to get the slope of cumD vs time to estimate the speed



% Inputs:

% trks = a vector of particle trajectories  which are assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.

% sgWindowSize = width of the gaussian smoiothing window to smooth the x and y
% data



% info         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm
% 

% Output:

%speeds = estimated speed for this trajectory

    numTracks = size(trks,2);
    speeds = zeros(numTracks,1);
    for i=1:numTracks  
        speeds(i) = getSpeed(trks(i),info,sgWindowSize);
    end
   
end



