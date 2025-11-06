function [MSDVsTau] = getMSDsVsTau(trks,info)
    % Given a cell array of particle tracks over embryos and parameter values, 
    % returns a cell array over same embryos and parameter values containing 
    % the MSD Vs Tau curves
    
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
 

        % determine number of samples and parameter values
        numSamples = size(trks,1);
        numParameters = size(trks,2);
    
        % compute MSD Vs Tau
        MSDVsTau = cell(numSamples,numParameters);

        for i = 1:numSamples
            for j = 1:numParameters
                numTracks = size(trks{i,j},2);
                MSDVsTau{i,j} = zeros(numTracks,1);
                for k=1:numTracks  
                    MSDVsTau{i,j}(k) = getMSDvsTAU(trks{i,j}(k),trks{i,j}(k).lifetime,info);
                end
            end
        end
end