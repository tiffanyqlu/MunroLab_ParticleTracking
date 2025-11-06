function  relativeIntensities = getRelativeIntensityAlongTrajectories(im,trks,sgWindowWidth,pathWidth)
%getRelativeIntensityAlongTrajectories Compute the intensity of a signal along the path associated 
% with a particle trajectory as a function of distance from the moving front of the trajectory
% 
% Details:  Takes as input a list of trajectories, and an image stack representing either the original data from which the
% trajectories were made, or a second channel from the same multicolor image stack.  For each trajectory, computes a smoothed 
% path with the given pathWidth.  For each timepoint along the trajectory (and position along the path), calculates the 
% intensity of the signal at different distances along the path relative to particle position at that timepoint. 
% For each trajectory, the function computes the mean intensity at a relative distance over all particle
% positions.  The function then returns a 2D array in which the rows are
% the intensities vs relative distance for one trajectory.
%


%  Inputs

%   im      =           [height][width][nFrames] image stack from which to take the intensity
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
%   sgWindowWidth:      size of the window used to smooth trajectory 
%
%   pathWidth:          width of path along trajectory in whiich to sample
%                       data 
%
%  Output:  
%
%   relativeIntensities  = An array of dimensions [numTracks, maxTrackLifetime].
%                       Each row contains average intensity values along one trajectory path relative to 
%                       the moving particles position.

    nTrks = length(trks);
    maxTrackLength = max([trks.lifetime]);
    relativeIntensities = nan(nTrks,maxTrackLength);

    for i = 1:nTrks
        relInt = getRelativeIntensityAlongTrajectory(im,trks(i),sgWindowWidth,pathWidth);
        meanRelInt = mean(relInt,1,'omitnan');
        relativeIntensities(i,1:length(meanRelInt)) = meanRelInt;
    end
end

