function [] = plotKymographs(axes, im, trks,SGWindow,pathWidth)
% plotKymographs plots a set of kymographs, one for each trajectory as a 2D montage
%
%   Inputs:
%
%   axes  = the axes on which to plot

%   im      =           [height][width][nFrames] image stack to take the intensity
%
%   trks     =           an array of particle trajectories in simple format
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.
%
%   SGWindow:    size of the window used to smooth trajectory 
%
%   pathWidth:   width of path along trajectory in whiich to sample data 
%

    numTracks = size(trks,2);

    for i=1:numTracks
        kymogrqph = makeKymograph(im,trks(i), SGWindow,pathWidth);
        imshow(axes{i},kymograph,[1 5000]);
    end
end

