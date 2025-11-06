function cumD = getCumDvsTAU(trk,movieInfo,sgWindowWidth)
% getCumDvsTAU   Takes a trajectory in simple format, and computes cumulative distances ion physical units (µm) along 
% smoothed version of that trajectory.

% Inputs:

% trk = a particle trajectory in simple format
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% movieInfo         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm

% sgWindowWidth      size of the smoothing window used by the SavitskyGolay filter
% 
% Output

% cumD    cumulative distance vs tau

    [~, ~, cumD] = projPointsToSmoothedCurve(trk.x,trk.y,sgWindowWidth);
    cumD = cumD*movieInfo.pixelSize;
end



