function [MSDs] = getMSDAtTau(trks,tau,info,which)
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
    %   tau:  time delay measured in frames
    %
    %   which:  optional argument determines which segments of the trajectory the msd
    %   is computed for:
    %   'first' - the first segment of length tau
    %   'last'  - the last segment of length tau
    %   'all'   - all segments


    
        % determine number of samples and parameter values
        numSamples = size(trks,1);
        numParameters = size(trks,2);
    
        MSDs = cell(numSamples,numParameters);
    
        for i = 1:numSamples
            for j = 1:numParameters
                switch which
                    case 'first'
                        MSDs{i,j} = getFirstMSDatTAU(trks{i,j},tau,info);   
                    case 'last'
                        MSDs{i,j} = getLastMSDatTAU(trks{i,j},tau,info);   
                    case 'all'
                        MSDs{i,j} = getMSDatTAU(trks{i,j},tau,info);
                    otherwise
                        MSDs{i,j} = getMSDatTAU(trks{i,j},tau,info);
                end
            end
        end
end