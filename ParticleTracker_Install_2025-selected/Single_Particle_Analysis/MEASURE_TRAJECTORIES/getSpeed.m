function speed = getSpeed(traj,movieInfo, sfac)

% Project points along a given trajectory to a smoothed version of that trajectory, compute the cumulative distance 
% vs time, and fit a line to get the slope of cumD vs time to estimate the speed



% Inputs:

% track = a single particle track which is assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.

% sfac = width of the gaussian smoiothing window to smooth the x and y
% data



% movieInfo         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm
% 
% Output:

%speed = estimated speed for this trajectory

    cumD = getCumDvsTAU(traj,movieInfo,sfac);  
    X = 1:size(cumD,2);
    frameInterval = 1/movieInfo.frameRate;
    X=X*frameInterval; 
    X = X.';
    f = fit(X,cumD.','poly1');
    speed = f.p1;
   
end



