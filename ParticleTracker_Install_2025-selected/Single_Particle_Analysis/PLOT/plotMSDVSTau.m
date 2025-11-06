function plotMSDVSTau(axes,trks,info,logscale, montage, plotMode)

% Given an array of particle tracks, estimate the mean square displacement
% (MSD) vs timelag tau for tracks with length > minTrackLength and
% plot these in postage stamp format.  
% Note: Format is that same as for plotMSDTrajectories for easy comparison.



% Inputs:

%    axes  = the axes on which to plot

%    tracks = a list of particle tracks which is assumed to be in the format 
%    output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% info         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm
%
% plotMode = 'selected', 'all' or 'mean/pooled'


    if montage 

        maxTrackLength = max([trks.lifetime]);
        numTracks = size(trks,2);
        X = 1:maxTrackLength;
        frameInterval = 1/info.frameRate;
        X=X*frameInterval;    

        if logscale
            for i=1:numTracks  
                loglog(axes{i},X,4*0.1*X,'color','b');        
                hold(axes{i},'on');
                loglog(axes{i},X,4*0.1*X.^2,'color','r');        
                msd = getMSDvsTAU(trks(i),trks(i).lifetime,info);
                loglog(axes{i},X(1:size(msd,2)),msd);
                char=num2str(i);
                title(axes{i},char);
                xlim(axes{i},[frameInterval,frameInterval*maxTrackLength]);
                ylim(axes{i},[0.001,10]);
            end
        else
            for i=1:numTracks  
                plot(axes{i},X,4*0.1*X,'color','b');        
                hold(axes{i},'on');
                plot(axes{i},X,4*0.1*X.^2,'color','r');        
                msd = getMSDvsTAU(trks(i),trks(i).lifetime,info);
                plot(axes{i},X(1:size(msd,2)),sqrt(msd));
                char=num2str(i);
                title(axes{i},char);
                xlim(axes{i},[frameInterval,frameInterval*maxTrackLength]);
                ylim([0,5]);
            end
        end 
    else  % plot overlayed curves

        switch plotMode

            case 'selected'

                maxLifetime = max([trks.lifetime]);
                numTracks = size(trks,2);
                X = 1:maxLifetime;
                frameInterval = 1/info.frameRate;
                X=X*frameInterval;    

                if logscale
                    loglog(axes,X,4*0.1*X,'color','b');        
                    hold(axes,'on');
                    loglog(axes,X,4*0.1*X.^2,'color','r');   
                    for i=1:numTracks  
                        msd = getMSDvsTAU(trks(i),trks(i).lifetime,info);
                        loglog(axes,X(1:size(msd,2)),msd);
                    end
                    xlim(axes,[frameInterval,frameInterval*maxLifetime]);
                    ylim(axes,[0.001,10]);
                else
                    plot(axes,X,4*0.1*X,'color','b');        
                    hold(axes,'on');
                    plot(axes,X,4*0.1*X.^2,'color','r');   
                    for i=1:numTracks  
                        msd = getMSDvsTAU(trks(i),trks(i).lifetime,info);
                        plot(axes,X(1:size(msd,2)),sqrt(msd));
                    end
                    xlim(axes,[frameInterval,frameInterval*maxLifetime]);
                    ylim(axes,[0,5]);
                end 
            
 
            case {'all','mean/pooled'}
                % determine number of samples and parameter values
                numSamples = size(trks,1);
                numParameters = size(trks,2);
    
                % determine max trajectory length  %
                maxLifetime = 1;
                for i = 1:numSamples
                    for j = 1:numParameters
                        maxLifetime = max(maxLifetime, max([trks{i,j}.lifetime]));
                    end
                end
                X = 1:maxLifetime;
                frameInterval = 1/info.frameRate;
                X=X*frameInterval;    

            if isequal(plotMode,'all')

                % plot
                for i = 1:numSamples
                    for j = 1:numParameters

                        numTracks = size(trks{i,j},2);
                        if logscale
                            loglog(axes{i,j},X,4*0.1*X,'color','b');        
                            hold(axes{i,j},'on');
                            loglog(axes{i,j},X,4*0.1*X.^2,'color','r');   
                            for k=1:numTracks  
                                msd = getMSDvsTAU(trks{i,j}(k),trks{i,j}(k).lifetime,info);
                                loglog(axes{i,j},X(1:size(msd,2)),msd);
                            end
                            xlim(axes{i,j},[frameInterval,frameInterval*maxLifetime]);
                            ylim(axes{i,j},[0.001,10]);
                        else
                            plot(axes{i,j},X,4*0.1*X,'color','b');        
                            hold(axes{i,j},'on');
                            plot(X,4*0.1*X.^2,'color','r');   
                            for i=1:numTracks  
                                msd = getMSDvsTAU(trks{i,j}(k),trks{i,j}(k).lifetime,info);
                                plot(axes{i,j},X(1:size(msd,2)),sqrt(msd));
                            end
                            xlim(axes,[frameInterval,frameInterval*maxLifetime]);
                            ylim(axes,[0,5]);
                        end     
                    end
                end
            else   % plot mean/pooled

                % plot
                for j = 1:numParameters                          
                    loglog(axes{j},X,4*0.1*X,'color','b');        
                    hold(axes{j},'on');
                    loglog(axes{j},X,4*0.1*X.^2,'color','r');   

                    for i = 1:numSamples
                        numTracks = size(trks{i,j},2);
                        MSDCurves = NaN(numTracks,maxLifetime);
                        if logscale
                            for k=1:numTracks  
                                msd = getMSDvsTAU(trks{i,j}(k),trks{i,j}(k).lifetime,info);
                                MSDCurves(k,1:1:size(msd,2)) = msd;
                                loglog(axes{j},X(1:size(msd,2)),msd);
                            end
                            loglog(axes{j},X,mean(MSDCurves,'omitnan'));
                            xlim(axes{j},[frameInterval,frameInterval*maxLifetime]);
                            ylim(axes{j},[0.001,10]);
                        else
                            plot(axes{j},X,4*0.1*X,'color','b');        
                            hold(axes{j},'on');
                            plot(X,4*0.1*X.^2,'color','r');   
                            for i=1:numTracks  
                                msd = getMSDvsTAU(trks{i,j}(k),trks{i,j}(k).lifetime,info);
                                MSDCurves(k,1:1:size(msd,2)) = msd;
                                plot(axes{j},X(1:size(msd,2)),msd);
                            end
                            plot(axes{j},X,mean(MSDCurves,'omitnan'));
                            xlim(axes,[frameInterval,frameInterval*maxLifetime]);
                            ylim(axes,[0,5]);
                        end     
                    end
                end
            end
        end
    end
end



