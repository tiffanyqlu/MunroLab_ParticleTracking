function [fAll fMean fDen pDen MT] = measureKFParticlesInFrame(in,mask,minPeakIntensity,integratedIntensityThreshold, featureSize,haloSize,useMaskArea,showSpots)

% This function measures particle properties within a region defined by the input mask. Our slight variant 
% of the Kilfoil feature2D function  is used to detect particles within a single image and 
%   measure background-subtracted particle intensities as follows:

%   (1) For each particle, measure integrated intensity within a circular mask with radius = featureSize
%   and centered in the particle centroid.  
%   (2) Measure the average background intensity I_bck within an
%   annular region of radius Ihalo surrounding the mask.  
%   (3) Then compute background substracted intensity as I_bs = I - I_bck*A_mask.

%   The function returns measures of particle number, mean particle intensity, and mean intensity 
%   within the masked region
% .  
%
% INPUTS :
% in - the image

% mask -    an 8 bit mask in which pixels within the embryo = 255 and all
%           others are 0

% minPeakIntensity -    the minimum intensity for a pixel to be considered as a potential
%                       feature. Use GUI to determine

% integratedIntensityThreshold -    the minimum integrated intensity for a
%                                   feature to be counted. Use GUI to determine

% featuresize - The size of the feature you want to find.
%           intensity / Rg squared of feature)

% showSpots - (0 or 1)  If 1, then display a bandpass filtered version 
%               of the input image with the detected paeticles superimposed 
% useMaskArea - if 1, use the area of the mask to comute particle density;
%               otherwise use the area of the smallest [polygon that
%               encloses all detected particles
%
% haloSize - The radius of the annular region used to measure background



% OUTPUTS
%
% fMean - mean background-subtracted intensity per particle n
% fDen - The mean background-subtracted intensity per unit area   
% pDen - The number of particles per unit area 
% MT - particle data in reduced Kilfoil format:
%
% 	MT(:,1): the x centroid positions, in pixels.
% 	MT(:,2): the y centroid positions, in pixels. 
% 	MT(:,3): integrated brightness of the features. ("mass")
% 	MT(:,4): background-subtracted integrated brightness of the features
% 	MT(:,5): frame number

bw = imbinarize(mask,0.5);
b = in;
%b = bpass(in,1,featureSize);

M = findFeatures(in, featureSize,minPeakIntensity, haloSize);
M = M(~isnan(M(:,4)),:);

valid = bw(sub2ind(size(bw),floor(M(:,2)),floor(M(:,1))));
M = M(valid,:);
if not(isempty(M))   
    % Reject features with integrated intensity less than threshold
    M = M(M(:,3) > integratedIntensityThreshold,:);

nFeatures = size(M,1)

% find and plot the smallest polygon that contains all detected particles
[p,a] = boundary(M(:,1),M(:,2));

if useMaskArea
    pixelCnt = size(find(bw),1);
    pDen = nFeatures/pixelCnt;
else
    pDen = nFeatures/a;
end

fMean = mean(M(:,4));
fDen = fMean*pDen;
fAll = mean(in(find(bw)));

MT = zeros(nFeatures,4);
MT(:,1:4) = M(:,1:4);


if showSpots
    figure;
    imshow(b,[1 max(max(b))]); 
    axis image;
    hold on;

    pgon = polyshape(MT(p,1),MT(p,2));
    plot(pgon,'FaceColor','none','EdgeColor','c');

    % plot the detected features
    for i = 1:nFeatures
        plot(M(i,1),M(i,2),'co','MarkerSize',3*featureSize+1);
    end
end

end

