function exportReleaseCurves(trks,info)
% Given an array of particle tracks, plots the histogram
% of trajectory lengths

% Inputs  


%    trks:    a list of particle tracks which is assumed to be in the format 
%           output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.

%   info

    % determine number of samples and paramjeter values
    numSamples = size(trks,1);
    numParameters = size(trks,2);

    % determine max trajectory length and max number of trajectories (per embryo) %
    maxTrajectoryLength = 1;
    maxNumTrajectories = 1;
    for i = 1:numSamples
        for j = 1:numParameters
            maxTrajectoryLength = max(maxTrajectoryLength, max([trks{i,j}.lifetime]));
            maxNumTrajectories = max(maxNumTrajectories, length(trks{i,j}));
        end
    end

    % compute decay curves
    for j = 1:numParameters    
        decayCurves = zeros(maxTrajectoryLength,2*numSamples);
        for  i = 1:numSamples                   
            decayCurves(:,2*i-1) = (1:maxTrajectoryLength)/info.frameRate;
            decayCurves(:,2*i) = decay(trks{i,j},info,maxTrajectoryLength);
            writematrix(decayCurves,['M' num2str(j) '.txt'],'Delimiter','tab');
        end
    end
end

