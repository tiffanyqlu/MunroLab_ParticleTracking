function [ out ] = Kilfoil_to_uTrack_particles(features)
%Kilfoil_to_uTrack_particles Transforms a set of particle data produced by Kilfoil
%preTråck into format for tracking by uTrack.  Extracts a subset of data defined 
% by firstfarme and nrames.

%  Inputs
%
%   features:  A cell array of features found in each movie frame in Kilfoil format
%
%   Outputs
%
%   out:  An array of structures with length nFrames, where each structure
%   defines a list of particles with the following fields:
%
%   xCoord: An array of x coordinates, one for each particle
%   yCoord: An array of y coordinates, one for each particle
%   amp: An array of intensities, one for each particle

    nFrames = length(features);
    out(nFrames,1) = struct('xCoord',[],'yCoord',[],'amp',[]);
    for frm = 1:nFrames
        p = features{frm};
        if ~isempty(p)
            sz = size(p,1);
            out(frm,1).xCoord = [p(:,1) zeros(sz,1)];
            out(frm,1).yCoord = [p(:,2) zeros(sz,1)];
            out(frm,1).amp = [p(:,4) zeros(sz,1)];
        end
    end
end

