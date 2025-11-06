function res = getIntensitiesAtFixedPos(im,trk,before,after,featureSize)
%getIntensitiesAtFixedPos.  Samples mean intensities at fixed positions along a particle trajectory at different times 
%                       relative to a reference time when the particle occupied that position

%  Inputs

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
%   before       =       number of frames to sample before reference time
%
%   after       =       number of frames to sample after reference time
%
%   featureSize     =   the radius of the sampling  ROI
%
%  Outputs
%
%   res      =          a [nPositions x windowSize] array of interpolated mean intensities, 
%                       where nPositions is the number of positions along the trajectory, and windowSize is the size of
%                       the time window in which to sample.


res = nan(trk.lifetime,before+after+1);

nFrms = size(im,3);

refFrm = trk.first:trk.last;
firstFrm = max(refFrm - before,1);
lastFrm = min(refFrm+after,nFrms);

firstI = firstFrm - (refFrm - before) + 1;
lastI = firstI + lastFrm - firstFrm;

for i = 1:trk.lifetime    
    res(i,firstI(i):lastI(i)) = getFeatureIntensity(im(:,:,firstFrm(i):lastFrm(i)),trk.x(i),trk.y(i),featureSize);
end