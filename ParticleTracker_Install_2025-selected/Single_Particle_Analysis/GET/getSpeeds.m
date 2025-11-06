function [Speeds] = getSpeeds(trks,info,sgWindowSize)
    % Given a cell array of particle tracks over embryos and parameter values, 
    % returns a cell array over same embryos and parameter values contiaining 
    % the distributions of trajectory lifetimes
    
    % Inputs  
    
    %    axes  = the axes on which to plot
    
    %    trks:    a list of particle tracks which is assumed to be in the format 
    %           output by the function uTrackToSimpleTraj:
    %
    %   'first' =   the first movie frame in which this track appears
    %   'last' =    the last movie frame in which this track appears.
    %   'lifetime' = the length of the track in frames.
    %   'x' = an array containing the sequence of x positions.
    %   'y' = an array containing the sequence of y positions.
    %   'I' = an array containing the intensity values.
    %
    %   info:  struct containing at least the individual field info.frameRate 
    %
    % sgWindowSize = width of the Savitzky-Golay smoothing window

    
        % determine number of samples and paramjeter values
        numSamples = size(trks,1);
        numParameters = size(trks,2);
    
        Speeds = cell(numSamples,numParameters);
    
        for i = 1:numSamples
            for j = 1:numParameters
                Speeds{i,j} = getSpeeds(trks{i,j},info,sgWindowSize);
            end
        end
end