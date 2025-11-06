function plotReleaseCurves(axes,trks,info,plotMode)
% Given an array of particle tracks, plots the histogram
% of trajectory lengths

% Inputs  

%      axes

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

%   plotMode

    switch plotMode

        case 'selected'

            % determine max lifetime %
            maxTrajectoryLength = max([trks.lifetime]);
            decayCurves = decay(trks,info,maxTrajectoryLength);
        
            plot(axes,(1:maxTrajectoryLength)/info.frameRate,log(decayCurves/decayCurves(1)));
            ylim(axes,[-log(length(trks)) 0]);
            xlim(axes,[0 maxTrajectoryLength/info.frameRate]);
            xlabel(axes, 'time')
            ylabel(axes, 'log #')

        case {'all','mean/pooled'}
            
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
            decayCurves = zeros(numSamples,numParameters,maxTrajectoryLength);
            for j = 1:numParameters        
                for  i = 1:numSamples                   
                    decayCurves(i,j,:) = decay(trks{i,j},info,maxTrajectoryLength);
                end
            end

            if isequal(plotMode,'all')

                % plot
                for i = 1:numSamples
                    for j = 1:numParameters
                        nmax = decayCurves(i,j,1);
                        plot(axes{i,j},(1:maxTrajectoryLength)/info.frameRate,log(squeeze(decayCurves(i,j,:))/nmax));
                        xlabel(axes{i,j},'time')
                        ylabel(axes{i,j},'log # tracks')
                        if numParameters > 1
                            title(axes{i,j},['sample ' num2str(i) ', ' info.parameterToVary ' = ' num2str(info.parameterValues(j))]);
                        end
                        ylim(axes{i,j},[-log(maxNumTrajectories) 0]);
                        xlim(axes{i,j},[0 maxTrajectoryLength/info.frameRate]);
                    end
                end
            else   % plot mean/pooled

                % compute mean decay curves over all embryos for different parameter values
                meanDecayCurves = squeeze(mean(squeeze(decayCurves),1));                  

                % plot
                for j = 1:numParameters                          
                    hold(axes{j},'on');
                    nmax = meanDecayCurves(j,1);
                    plot(axes{j},(1:maxTrajectoryLength)/info.frameRate,log(meanDecayCurves(j,1:maxTrajectoryLength)/nmax));   
                    for i = 1:numSamples
                        plot(axes{j},(1:maxTrajectoryLength)/info.frameRate,log(squeeze(decayCurves(i,j,:))/nmax));
                    end
                    xlabel(axes{j},'time')
                    ylabel(axes{j},'log # tracks')
                    if numParameters > 1
                        title(axes{j},[info.parameterToVary ' = ' num2str(info.parameterValues(j))]);
                    end
                    ylim(axes{j},[-log(maxNumTrajectories) 0]);
                    xlim(axes{j},[0 maxTrajectoryLength/info.frameRate]);
                end
            end
    end
end

