function [uVecs, segLengths] = getDisplacements(trk)
%getDisplacements 

%   Takes as inputs a particle trajectory in simple format and computes and returns arrays containing the lengths in individual
%   segments and the unit vectors along those segments.


% inputs

% trk = a particle trajectory in simple format
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.

%   outputs

%  uVecs   2 x N array of unit vectors for the N segments
%  segLengths   1 x N array of lengths for the N segments

    tX = trk(1,:);
    tY = trk(2,:);
    
    maxT = size(trk,2);
    
    dx = tX(2:maxT) - tX(1:maxT-1);
    dy = tY(2:maxT) - tY(1:maxT-1);
    segLengths = sqrt(dx.*dx + dy.*dy);
    uVecs = vertcat(dx./segLengths,dy./segLengths);
   
end

