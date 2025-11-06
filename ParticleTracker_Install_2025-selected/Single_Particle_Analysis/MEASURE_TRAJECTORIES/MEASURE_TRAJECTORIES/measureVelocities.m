function [mn, stdv, sem, cnt] = measureVelocities(sTrks,mask,specifyNumBins,nP,angle, first, last)

% This functiuon computes velocities (i.e. frame-frame displacements over all particle trajectories in sTrks,
% which is a list of particle trajectories in "simple" format. It then
% bins/averages these along AP axis of embryo with respect to an outline of the embryos defined by input mask.


% INPUTS :
% sTrks -   trajectories in simple form

% mask -   an 8 bit mask in which pixels within the embryo = 255 and all
%           others are 0

% specifyNumBins - If equal to one, the value of nP specifies number of bins along AP axis.  
% Otherwise, nP specifies the bin length in number of pixels

% nP - The number of bins along the AP axis or the length of each bin in pixels, depending on the value 
% of specifyNumBins


% angle = angle through which to rotate the masked region. If you use a
% value of 0, the angle is automatically chosen to align the
% mask with respect to the horizontal axis. If you specify a
% non-zero value, the function will rotate the masked region clockwise about its
% centroid by the specified number of degrees (e.g. angle = 90 -> rotation by 90 degrees clockwise). 

% first - the first timepoint (in frames) to consider in the analysis

% last - the last timepoint (in frames) to consider in the analysis



% OUTPUTS
%
% out -  The rotated image
% v - The average velicities along x-axis binned vs AP position
% bpVal - The integrated intensity of bandpass-filtered particles per unit area binned vs AP position  
% cnt - The particle number per unit area binned vs AP position 
    
    sTrks = filterByFirstAndLast(sTrks,first,last);
    [bw,sTrks] = transformSimpleTrajectories(sTrks,mask,angle);

    [y,x] = find(bw);
    minX = min(x);
    maxX = max(x);

    if specifyNumBins == 1    % number of bins specified by user 
        nBins = nP;
    else    
        nPixels = nP;       % size of bins specified by user
        nBins = floor((maxX - minX)/nPixels);
    end

    mn = zeros(nBins,1);
    stdv = zeros(nBins,1);
    sem = zeros(nBins,1);
    cnt = zeros(nBins,1);
    nTracks = size(sTrks,2);

    for i=1:nTracks
        for j=2:sTrks(i).lifetime
            if sTrks(i).first+j>=first && sTrks(i).first+j<=last
                ind = ceil(nBins*(sTrks(i).x(j) - minX)/(maxX-minX));
                if ind >= 0 && ind < nBins
                    dv = sTrks(i).x(j) - sTrks(i).x(j-1);
                    mn(ind) = mn(ind) + dv;
                    cnt(ind) = cnt(ind) + 1;
                end
            end
        end
    end
    mn = mn./cnt;

    for i=1:nTracks
        for j=2:sTrks(i).lifetime
            if sTrks(i).first+j>=first && sTrks(i).first+j<=last
                ind = ceil(nBins*(sTrks(i).x(j) - minX)/(maxX-minX));
                if ind >= 0 && ind < nBins
                    dv = sTrks(i).x(j) - sTrks(i).x(j-1);
                    stdv(ind) = stdv(ind) + (dv - mn(ind))*(dv - mn(ind));
                end
            end
        end
    end
    stdv = stdv./(cnt-1);
    sem = stdv./sqrt(cnt);
end



