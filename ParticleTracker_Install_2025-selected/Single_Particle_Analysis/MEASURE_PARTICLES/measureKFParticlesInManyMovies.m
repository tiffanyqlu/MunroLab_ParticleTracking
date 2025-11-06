function [fMean fDen pDen] = measureKFParticlesInManyMovies(minPeakIntensity,featureSize,haloSize)

% This function measures particle densities and intensities for multiple timelapse movies.  The movies must 
% exist in a single directory and must be named e1.tif, e2.tif,...   For each movie, there must be a 
% corresponding tiff file called mask1.tf, mask2.tif etc
% that defines a masked region in which to count/measure particles in the
% movie frames.  See docmuentation for measureManyParticleMeans for details
% of the mesurements.


%   The function returns an array of these measurements over all frames.
%  
%
% INPUTS :
% in - the image sequence

% mask -    an 8 bit mask in which pixels within the embryo = 255 and all
%           others are 0

% minPeakIntensity -    the minimum intensity for a pixel to be considered as a potential
%           feature.

% featuresize - The size of the feature you want to find.
%           intensity / Rg squared of feature)
%
% haloSize - The radius of the annular region used to measure background



% OUTPUTS
%
% fMean - mean background-subtracted intensity per particle n
% fDen - The mean background-subtracted intensity per unit area   
% pDen - The number of particles per unit area 


% Determine number of embryos

numMovies = 1; 
filename = ['e' num2str(numMovies) '.tif'];
maxFrames = 0;

while exist(filename,'file') == 2
    info = imfinfo(filename);
    if length(info) > maxFrames
        maxFrames = length(info);
    end
    numMovies = numMovies+1;
    filename = ['e' num2str(numMovies) '.tif'];
end
    
numMovies = numMovies-1;

maxFrames = floor(maxFrames/gap);
fMean = nan(numMovies,maxFrames);
fDen = nan(numMovies,maxFrames);
pDen = nan(numMovies,maxFrames);

for i = 1:numMovies    

    filename = ['e' num2str(i) '.tif'];
    info = imfinfo(filename);
    mask = imread(['mask' num2str(i) '.tif'],'tif');
    movie = uint16(zeros(info(1).Height,info(1).Width,length(info)));
    for j = 1:length(info)
        movie(:,:,j) = imread(filename,'tif',j);
    end
    [fM fD pD MT] = measureKFParticlesInMovie(movie,mask,minPeakIntensity,featureSize,haloSize);
    
    nfrms = length(info);
    fMean(i,1:nfrms) = fM;
    fDen(i,1:nfrms) = fD;
    pDen(i,1:nfrms) = pD;
    
end
    