function plotLifetimeHistogram(axes,trks,info,logscale, plotMode)
% Given an array of particle tracks, plots the histogram
% of trajectory lengths

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
%   logscale:   if 1, plot on logscale, if 0, plot linear
%
%   plotMode = 'selected', 'all' or 'mean/pooled'


    switch plotMode

        case 'selected'

            maxLifetime = max([trks.lifetime])/info.frameRate;

            if logscale
                h = histogram(axes,log10([trks.lifetime]/info.frameRate),'Normalization','probability');
            else
                h = histogram(axes,[trks.lifetime]/info.frameRate,'Normalization','probability');
            end    
            xlabel(axes, 'Lifetime (sec)')
            ylabel(axes, 'Frequency')
            if logscale
                xlim(axes,[log10(1/info.frameRate) log10(maxLifetime)]);
            else
                xlim(axes,[0 maxLifetime]);
            end    

            ylim(axes,[0 1.2*max(h.Values)])
            

        case {'all','mean/pooled'}
            
            % determine number of samples and paramjeter values
            numSamples = size(trks,1);
            numParameters = size(trks,2);

            % determine max trajectory lifetime in physical units %
            maxLifetime = 1;
            for i = 1:numSamples
                for j = 1:numParameters
                    maxLifetime = max(maxLifetime, max([trks{i,j}.lifetime]));
                end
            end
            maxLifetime = maxLifetime/info.frameRate;            
            
            if isequal(plotMode,'all')
                for i = 1:numSamples
                    for j = 1:numParameters
                        if logscale
                            h = histogram(axes{i,j},log10([trks{i,j}.lifetime]/info.frameRate),'Normalization','probability');
                        else
                            h = histogram(axes{i,j},[trks{i,j}.lifetime]/info.frameRate,'Normalization','probability');
                        end    
                        xlabel(axes{i,j}, 'Lifetime (sec)')
                        ylabel(axes{i,j}, 'Frequency')
                        if logscale
                            xlim(axes{i,j},[log10(1/info.frameRate) log10(maxLifetime)]);
                         else
                           xlim(axes{i,j},[0 maxLifetime]);
                        end    
                        ylim(axes{i,j},[0 1.2*max(h.Values)])
                    end
                end
            else   % plot sample means
                for j = 1:numParameters    

                    alltrks = cell(1,numParameters);
                    hold(axes{j},'on');
                    for i = 1:numSamples
                        alltrks{j} = [alltrks{j} trks{i,j}];
                        if logscale
                            histogram(axes{j},log10([trks{i,j}.lifetime]/info.frameRate),'Normalization','probability','DisplayStyle','stairs');
                        else
                            histogram(axes{j},[trks{i,j}.lifetime]/info.frameRate,'Normalization','probability','DisplayStyle','stairs');
                        end    
                    end
                    if logscale
                        h = histogram(axes{j},log10([alltrks{j}.lifetime]/info.frameRate),'Normalization','probability','DisplayStyle','stairs','LineWidth',2);
                    else
                        h = histogram(axes{j},[alltrks{j}.lifetime]/info.frameRate,'Normalization','probability','DisplayStyle','stairs','LineWidth',2);
                    end    
                    xlabel(axes{j}, 'Lifetime (sec)')
                    ylabel(axes{j}, 'Frequency')
                    if logscale
                        xlim(axes{j},[log10(1/info.frameRate) log10(maxLifetime)]);
                    else
                        xlim(axes{j},[0 maxLifetime]);
                    end   
                    ylim(axes{j},[0 1.2*max(h.Values)])
                end
            end
    end

end

