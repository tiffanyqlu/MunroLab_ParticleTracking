function plotIntensityVsTime(axes,trks)
% Given an array of particle tracks, plots Intensity values vs time for each
% track with length > minTrackLength.  Plots either in postage stamp format or overlayed.
% Note: Format is that same as for plotMSDVSTime for easy comparison.

% Inputs:

% axes  = the axes on which to plot

% tracks = a list of particle tracks which is assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.



    numTracks = size(trks,2);
    
    maxI = 0; minI = 0; maxT = 0; 

    for i = 1:numTracks   
        dum = max(trks(i).I);
        if dum>maxI
            maxI = dum;
        end
        dum = min(trks(i).I);
        if dum<minI
            minI = dum;
        end
        if trks(i).lifetime>maxT
            maxT = trks(i).lifetime;
        end
    end       
    for i=1:numTracks
        plot(axes{i},trks(i).I);
        xlim(axes{i},[1,maxT]);
        ylim(axes{i},[minI,maxI]);
        char=num2str(i);
        title(axes{i},char);
    end
end

