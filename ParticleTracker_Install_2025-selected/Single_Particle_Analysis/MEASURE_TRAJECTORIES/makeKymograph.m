function  kymograph = makeKymograph(im,trk,golayWindow,pathWidth)
%makeKymograph Given a trajectory path through an image, straighten the
%path and compute the corresponding kymograph and display it

%   Inputs:
%
%   im      =           [height][width][nFrames] image stack to take the intensity
%
%   trk     =           a particle trajectory in simple format
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.
%
%   golayWindow:    size of the window used to smooth trajectory 
%
%   pathWidth:      width of path along trajectory in which to sample
%                   data 

    sx = smoothdata(trk.x,'sgolay',golayWindow);
    sy = smoothdata(trk.y,'sgolay',golayWindow);
    smoothedTraj = vertcat(sx,sy);
    
    pixelList = pixelizePath(smoothedTraj,pathWidth);
    kymograph = straightenPath(im(:,:,trk.first:trk.last),pixelList);   
end

