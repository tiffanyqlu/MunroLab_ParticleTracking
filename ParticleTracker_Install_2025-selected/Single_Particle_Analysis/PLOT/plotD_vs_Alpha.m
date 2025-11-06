function plotD_vs_Alpha(axes, trks,maxTau, info,plotMode)
% Given a set of input tracks, estimates diffusivities and exponent alpha for 
% MSD vs time and plots their distributions.


% Inputs:

%    axes  = the axes on which to plot

%   tracks = a list of particle tracks which is assumed to be in the format 
%   output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% minTrackLength = minimum length of particle track in frames to include in
% the analysis.

% maxTau            Estimate D and alpha from MSD vs tau for tau <= maxTau.

% info         =   a struct containing the following fields:
%     
%     baseName:       original datafile name minus the ".tif" ext
%     frameRate:      in #/sec
%     pixelSize:      in µm
%     firstFrame      first frame of movie segment 
%     lastFrame:      last frame of movie segment 
%     APOrientation:  0 if anterior is to the left; 1 if it is to the right 
%
% plotMode = 'selected', 'all' or 'mean/pooled'



    switch plotMode

        case 'selected'

            trks = trks([trks.lifetime] > maxTau);
            [D Alpha] = getDAlpha(trks,maxTau,info);
            scatter(axes,Alpha,D);
            title(axes,'D vs alpha');
            ylabel(axes,'D');
            xlabel(axes,'alpha');
            xlim(axes,[0 2]);
            ylim(axes,[0 0.5]);

         case {'all','mean/pooled'}
            
            % determine number of samples and parameter values
            numSamples = size(trks,1);
            numParameters = size(trks,2);

            % compute D and Alpha
            D = cell(numSamples,numParameters);
            Alpha = cell(numSamples,numParameters);

            for i = 1:numSamples           
                for  j = 1:numParameters 
                    ltrks = trks{i,j};
                    ltrks = ltrks([ltrks.lifetime] > maxTau);
                    [D{i,j}, Alpha{i,j}] = getDAlpha(ltrks,maxTau,info);
                end
            end

            if isequal(plotMode,'all')

                % plot
                for i = 1:numSamples
                    for j = 1:numParameters
                        scatter(axes{i,j},Alpha{i,j},D{i,j});
                        ylabel(axes{i,j},'D');
                        xlabel(axes{i,j},'alpha');
                        xlim(axes{i,j},[0 2]);
                        ylim(axes{i,j},[0 0.5]);
                        titleString = ['sample ' num2str(i)];
                        if numParameters > 1
                            titleString = [titleString ', ' info.parameterToVary ' = ' num2str(info.parameterValues(j))];                            
                        end
                        title(axes{i,j},titleString);
                    end
                end
            else   % plot mean/pooled

                % plot
                for j = 1:numParameters                          
                    hold(axes{j},'on');
                    for i = 1:numSamples
                        scatter(axes{j},Alpha{i,j},D{i,j});
                    end
                    ylabel(axes{j},'D');
                    xlabel(axes{j},'alpha');
                    xlim(axes{j},[0 2]);
                    ylim(axes{j},[0 0.5]);
                    titleString = 'all samples';
                    if numParameters > 1
                        titleString = [titleString ', ' info.parameterToVary ' = ' num2str(info.parameterValues(j))];                            
                    end
                    title(axes{j},titleString);
                end
            end
    end
end

