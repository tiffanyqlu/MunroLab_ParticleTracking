function out = filterParticlesByROI(particles, roi)
% This function transforms a list of particle tracks, returning only those that are contained within 
% the specified ROI.

%Inputs

% particles = a list of particle tracks which is assumed to be in the format 
% output by the function mPretrack



%roi: a 2D array such that roi(x,y) = non-zero inside the region of interest, zero outside.




    numParticles = size(particles,1);
    indices = zeros(1,numParticles);
    roi = transpose(roi);

    for i=1:numParticles
        x = uint8(particles(i,1));
        y = uint8(particles(i,2));
        ind = sub2ind(size(roi),x,y);
        mVal = roi(ind);
        if mVal > 0
            indices(i) = 1;
        end
    end    
    out = particles(logical(indices),:);  
end