function plotIntensityHistogram(axes,trks,plotMode)
% Given an array of particle tracks, plots Intensity values vs time for each
% track with length > minTrackLength.  Plots either in postage stamp format or overlayed.
% Note: Format is that same as for plotMSDVSTime for easy comparison.

% Inputs:

%    axes  = the axes on which to plot

%   tracks = a list of particle tracks which is assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.
%
% plotMode = 'selected', 'all' or 'mean/pooled'

    switch plotMode

        case 'selected'

            maxIntensity = max([trks.I]);            
            numTracks = size(trks,2);          
            intensities = zeros(numTracks,1);
            for i=1:numTracks  
                intensities(i) = mean(trks(i).I);
            end

            h = histogram(axes,intensities,'BinWidth',max(intensities)/100,'Normalization','probability');
            xlabel(axes, 'track Intensity')
            ylabel(axes, 'frequency')
            xlim(axes,[0 maxIntensity]);
            ylim(axes,[0 1.2*max(h.Values)])

        case {'all','mean/pooled'}
            
            % determine number of samples and paramjeter values
            numSamples = size(trks,1);
            numParameters = size(trks,2);

            % determine max trajectory lifetime in physical units %
            maxIntensity = 0;
            for i = 1:numSamples
                for j = 1:numParameters
                    maxIntensity = max(maxIntensity, max([trks{i,j}.I]));
                end
            end

            if isequal(plotMode,'all')
                for i = 1:numSamples
                    for j = 1:numParameters     
                        subtrks = trks{i,j};
                        numTracks = size(subtrks,2);
                        intensities = zeros(numTracks,1);
                        for k=1:numTracks  
                            intensities(k) = mean(subtrks(k).I);
                        end
            
                        h = histogram(axes{i,j},intensities,'BinWidth',max(intensities)/100,'Normalization','probability');
                        xlabel(axes{i,j}, 'track Intensity')
                        ylabel(axes{i,j}, 'frequency')
                        xlim(axes{i,j},[0 maxIntensity]);
                        ylim(axes{i,j},[0 1.2*max(h.Values)])
                    end
                end
            else   % plot mean/pooled
                for j = 1:numParameters    

                    allIntensities = cell(1,numParameters);

                    hold(axes{j},'on');
                    for i = 1:numSamples
                        subtrks = trks{i,j};
                        numTracks = size(subtrks,2);
                        intensities = zeros(1,numTracks,1);
                        for k=1:numTracks  
                            intensities(k) = mean(subtrks(k).I);
                        end   
                        allIntensities{j} = [allIntensities{j} intensities];
                        histogram(axes{j},intensities,'BinWidth',max(intensities)/100,'Normalization','probability','DisplayStyle','stairs');
                    end

                    h = histogram(axes{j},allIntensities{j},'BinWidth',max(intensities)/100,'Normalization','probability','DisplayStyle','stairs','LineWidth',2);
                    xlabel(axes{j}, 'track Intensity')
                    ylabel(axes{j}, 'frequency')
                    xlim(axes{j},[0 maxIntensity]);
                    ylim(axes{j},[0 1.2*max(h.Values)])
                end
            end
    end


end

