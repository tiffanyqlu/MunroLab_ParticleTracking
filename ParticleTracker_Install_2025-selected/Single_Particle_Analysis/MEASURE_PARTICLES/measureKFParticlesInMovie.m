function [fAll fMean fDen pDen MT] = measureKFParticlesInMovie(movie,mask,minPeakIntensity,integratedIntensityThreshold, featureSize,haloSize,useMaskArea)

% This function measures particle properties within a region defined by the input mask for each of a sequence of frames. 
% A slight variant of the Kilfoil feature2D function (edsFeature2D) is used to detect particles within a single frame and 
%   measure background-subtracted particle intensities as follows:

%   (1) For each particle, measure integrated intensity within a circular mask with radius = featureSize
%   and centered in the particle centroid.  
%   (2) Measure the average background intensity I_bck within an
%   annular region of radius Ihalo surrounding the mask.  
%   (3) Then compute background substracted intensity as I_bs = I - I_bck*A_mask.

%   The function returns measures of particle number, mean particle intensity, and mean intensity 
%   within the masked region

%   The function returns an array of these measurements over all frames.
% .  
%
% INPUTS :
% movie - the image sequence

% mask -    an 8 bit mask in which pixels within the embryo = 255 and all
%           others are 0

% minPeakIntensity -    the minimum intensity for a pixel to be considered as a potential
%                       feature.

% integratedIntensityThreshold -    the minimum integrated intensity for a
%                                   feature to be counted. Use GUI to determine

% featuresize - The size of the feature you want to find.
%           intensity / Rg squared of feature)
%
% useMaskArea - if 1, use the area of the mask to compute particle density;
%               otherwise use the area of the smallest polygon that
%               encloses all detected particles
%
%
% haloSize - The radius of the annular region used to measure background


% OUTPUTS
%
% fMean - mean background-subtracted intensity per particle n
% fDen - The mean background-subtracted intensity per unit area   
% pDen - The number of particles per unit area 
% MT - particle data in Kilfoil format

    nCnt = floor(size(movie,3));
    fAll = zeros(1,nCnt);
    fMean = zeros(1,nCnt);
    fDen = zeros(1,nCnt);
    pDen = zeros(1,nCnt);
    MT = [];
    
    for frm = 1:nCnt    
        frm
        [fA fM fD pD m] = measureKFParticlesInFrame(movie(:,:,frm), mask, minPeakIntensity,integratedIntensityThreshold,featureSize,haloSize,useMaskArea,0);
        fAll(frm) = fA;
        fMean(frm) = fM;
        fDen(frm) = fD;
        pDen(frm) = pD;
        m = [m frm*ones(size(m,1),1)];
        MT = vertcat(MT,m);
    end
end