function [res] = findKFParticleThreshold(in,Imin, Imax,featureSize,haloSize)

%findKFParticleThreshold  This function uses the Kilfoil feature2D function to detect particles within a single image
%  It samples a range of detection thresholds in the interval [Imin, Imax] and returns
%  an array containing the number of particles detected for each threshold value.


% INPUTS 

% in - the image

% Imin -    the minimum intensity threshold to test.

% Imax -    the maximum intensity threshold to test.

% featuresize - The size of the feature you want to find.
%           intensity / Rg squared of feature)

% haloSize - The radius of the annular region used to measure background


% OUTPUTS
%
% res = array containing number of particles found for each threshold
% value.

vals = Imin:Imax;
res = zeros(1,length(vals));

for i = 1:length(vals)
    
    th = vals(1,i);
    M = feature2D(in,1,featureSize,th,th,2,haloSize);

    if M ~= -1
        res(1,i) = size(M,1);
    else
        res(1,i) = 0;
    end
end


