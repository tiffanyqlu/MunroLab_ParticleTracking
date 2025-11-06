function plotDvsT(axes,trks)
% Given an array of particle tracks, plots frame to frame displacements  vs time for each
% track with length > minTrackLength.  Plots either in postage stamp format or overlayed.

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
    maxTime = max([trks.lifetime]); 
        
    for i=1:numTracks
        dx = 0.1*(trks(i).x(2:trks(i).lifetime) - trks(i).x(1:trks(i).lifetime-1));
        dy = 0.1*(trks(i).y(2:trks(i).lifetime) - trks(i).y(1:trks(i).lifetime-1));
        tmp = (dx.*dx + dy.*dy).^0.5;
        plot(axes{i},tmp);
        xlim(axes{i},[1,maxTime]);
        ylim(axes{i},[0,0.2]);
        char=num2str(i);
        title(axes{i},char);
    end

end

