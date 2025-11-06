function  plotTrajectories(axes,trks, plotMontage)
% Given an array pf particle tracks, plots raw trajectories (x,y) for each
% track with length > minTrackLength in postage stamp format.  
% Note: Format is that same as for plotMSDVSTime for easy comparison.

% Inputs:

% axes  = the axes on which to plot

% trks = a list of particle tracks which is assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


    numTracks = size(trks,2);

    if plotMontage

        maxX = max(cellfun(@max,{trks.x}) - cellfun(@mean,{trks.x}));
        minX = min(cellfun(@min,{trks.x}) - cellfun(@mean,{trks.x}));
        maxY = max(cellfun(@max,{trks.y}) - cellfun(@mean,{trks.y}))
        minY = min(cellfun(@min,{trks.y}) - cellfun(@mean,{trks.y}));

        for i=1:numTracks
            mx = trks(i).x-mean(trks(i).x);
            my = trks(i).y-mean(trks(i).y);
            plot(axes{i},mx,my);
            xlim(axes{i},[minX,maxX]);
            ylim(axes{i},[minY,maxY]);
            char=num2str(i);
            title(axes{i},char);
        end
    else         
        maxX = max(cellfun(@max,{trks.x}));
        minX = min(cellfun(@min,{trks.x}));
        maxY = max(cellfun(@max,{trks.y}));
        minY = min(cellfun(@min,{trks.y}));
        xlim(axes,[minX,maxX]);
        ylim(axes,[minY,maxY]);

        hold(axes,'on');
        for i=1:numTracks
            plot(axes,trks(i).x,trks(i).y);
        end
        char=num2str(i);
        title(axes,char);
    end
end

