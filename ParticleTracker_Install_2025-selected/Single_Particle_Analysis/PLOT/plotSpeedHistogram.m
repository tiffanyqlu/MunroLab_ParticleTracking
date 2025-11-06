function  plotSpeedHistogram(axes,trks,info, sgWindowSize,plotMode)
% Compute msd vs tau for tau < maxTau

% Inputs:

%    axes  = the axes on which to plot

%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% movieInfo         =   a struct containing the following fields:
%     
%     baseName:       original datafile name minus the ".tif" ext
%     frameRate:      in #/sec
%     pixelSize:      in µm
%     firstFrame      first frame of movie segment 
%     lastFrame:      last frame of movie segment 
%
% plotMode = 'selected', 'all' or 'mean/pooled'

% minTrackLength = minimum length of particle track in frames to include in
% the analysis.


% sgWindowSize = width of the Savitzky-Golay smoothing window


    switch plotMode

        case 'selected'

            % compute speeds
            speeds = getSpeeds(trks,info,sgWindowSize);
            maxSpeed = max(speeds);

            % plot speeds
            binwidth = maxSpeed/30;
            histogram(axes,speeds,'BinWidth',binwidth,'Normalization','probability');
            xlim(axes,[0,maxSpeed]);
            ylim(axes,[0 0.3]);
            xlabel(axes, 'speed');
            ylabel(axes, 'frequency');
           
        case {'all','mean/pooled'}
            
            % determine number of samples and paramjeter values
            numSamples = size(trks,1);
            numParameters = size(trks,2);

            % allocate storage.
            speeds = cell(numSamples,numParameters);
        
            % compute speeds and max speeds
            maxSpeed = 0;
            for i = 1:numSamples                
                for  j = 1:numParameters 
                    speeds{i,j} = getSpeeds(trks{i,j},info,sgWindowSize);
                    maxSpeed = max(maxSpeed,max(speeds{i,j}));
                end
            end

            %binwidth = maxSpeed/30;
            binwidth = 0.1;
 
            if isequal(plotMode,'all')
                for i = 1:numSamples
                    for j = 1:numParameters     

                        % plot speeds                      
                        histogram(axes{i,j},speeds{i,j},'BinWidth',binwidth,'Normalization','probability');
                        xlim(axes{i,j},[0,maxSpeed]);
                        ylim(axes{i,j},[0 0.3]);
                        xlabel(axes{i,j}, 'speed');
                        ylabel(axes{i,j}, 'frequency');                        
                    end
                end
            else   % plot mean/pooled

                for j = 1:numParameters    

                    allSpeeds = [];
                    for i = 1:numSamples
                        allSpeeds = vertcat(allSpeeds,speeds{i,j});
                    end

                    % plot speeds                      
                    histogram(axes{j},allSpeeds,'BinWidth',binwidth,'Normalization','probability');
                    xlim(axes{j},[0,maxSpeed]);
                    ylim(axes{j},[0 0.3]);
                    xlabel(axes{j}, 'speed');
                    ylabel(axes{j}, 'frequency');                        
                end
            end
    end

end



