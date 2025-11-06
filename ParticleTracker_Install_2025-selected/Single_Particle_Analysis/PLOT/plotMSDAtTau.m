function plotMSDAtTau(axes,trks,tau,info,plotMode)

% Given an array of particle tracks, estimate the mean square displacement
% (MSD) vs timelag tau for tracks with length > minTrackLength and
% plot these in postage stamp format.  
% Note: Format is that same as for plotMSDTrajectories for easy comparison.


% Inputs:


%    axes  = the axes on which to plot

%    trks = a list of particle tracks which is assumed to be in the format 
%       output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% minTrackLength = minimum length of particle track in frames to include in
% the analysis.

% info         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm

% tau

% plotMode = 'selected', 'all' or 'mean/pooled'

    % compute an estimate of the RMSDs for molecules
    % undergoing random diffusion
    numSamples = 10000;

    % standard deviation of particle location error
    errSTD = 0.05;

    % diffusivity
    D = 0.1;

    rmsdSample = sampleRMSD(tau/info.frameRate, numSamples,D,errSTD);

    switch plotMode

        case 'selected'

            % compute msds
            MSDs = getMSDatTAU(trks,tau,info,plotMode); 
            maxRMSD = sqrt(max(MSDs));

            % plot rmsds and overlay the estimate
            binwidth = maxRMSD/30;
            hold(axes,'on');
            histogram(axes,sqrt(MSDs),'BinWidth',binwidth,'Normalization','probability');
            histogram(axes,rmsdSample,'DisplayStyle','stairs','BinWidth',binwidth,'Normalization','probability');
            xlim(axes,[0,maxRMSD]);
            ylim(axes,[0 0.3]);
            xlabel(axes, 'root mean square displacement')
            ylabel(axes, 'frequency')
           
        case {'all','mean/pooled'}
            
            % determine number of samples and parameter values
            numSamples = size(trks,1);
            numParameters = size(trks,2);

            % allocate storage for msds.
            MSDs = cell(numSamples,numParameters);
        
            % compute msds and max msds
            maxMSD = 0;
            for i = 1:numSamples                
                for  j = 1:numParameters 
                    MSDs{i,j} = getMSDatTAU(trks{i,j},tau,info);   
                    maxMSD = max(maxMSD,max(MSDs{i,j}));
                end
            end
            maxRMSD = sqrt(maxMSD);
            binwidth = maxRMSD/30;
 
            if isequal(plotMode,'all')
                for i = 1:numSamples
                    for j = 1:numParameters     

                        % plot rmsds and overlay the estimate                       
                        hold(axes{i,j},'on');
                        histogram(axes{i,j},sqrt(MSDs{i,j}),'BinWidth',binwidth,'Normalization','probability');
                        histogram(axes{i,j},rmsdSample,'DisplayStyle','stairs','BinWidth',binwidth,'Normalization','probability');
                        xlim(axes{i,j},[0,maxRMSD]);
                        ylim(axes{i,j},[0 0.3]);
                        xlabel(axes{i,j}, 'root mean square displacement')
                        ylabel(axes{i,j}, 'frequency')
                        
                    end
                end
            else   % plot mean/pooled
                for j = 1:numParameters    

                    allMSDs = [];

                    for i = 1:numSamples
                        allMSDs = [allMSDs MSDs{i,j}];
                    end

                    % plot rmsds and overlay the estimate                       
                    hold(axes{j},'on');
                    histogram(axes{j},sqrt(allMSDs),'BinWidth',binwidth,'Normalization','probability');
                    histogram(axes{j},rmsdSample,'DisplayStyle','stairs','BinWidth',binwidth,'Normalization','probability');
                    xlim(axes{j},[0,maxRMSD]);
                    ylim(axes{j},[0 0.3]);
                    xlabel(axes{j}, 'root mean square displacement')
                    ylabel(axes{j}, 'frequency')
                end
            end
    end
end



