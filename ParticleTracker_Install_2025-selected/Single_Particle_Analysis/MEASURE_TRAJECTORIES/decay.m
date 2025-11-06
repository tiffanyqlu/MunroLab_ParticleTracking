function [ res ] = decay(trks,info,maxLifeTime)
%decay 

% Inputs:

% trks = an array of structs containing a list of particle tracks which is assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% minTrackLength = minimum length of particle track in frames to include in
% the analysis.

% info         =        a struct containing the following fields:
%     
%     baseName:       original datafile name minus the ".tif" ext
%     frameRate:      in #/sec
%     pixelSize:      in µm
%     firstFrame      first frame of movie segment 
%     lastFrame:      last frame of movie segment 
%     APOrientation:  0 if anterior is to the left; 1 if it is to the right 
%
%  maxLifeTime    =       The maximum trajectory lifetime in frames to consider
% 
%  
% 
% OUTPUT:

% res = an array containing the nmber of trjectories with lifetime > i for
% position i in the array.


    res = zeros(maxLifeTime,1);
    for frm = 1:maxLifeTime
        res(frm) = length(find([trks.lifetime] > frm));
    end
end
