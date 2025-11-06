function t = getIntensityThreshold(img,fractionBelow)
%UNTITLED For the given image, find the intensity for which a given
%fraction of pixels are below that intensity 

%  inputs
%
%  img = an image   
%  fractionBelow = the fraction cutoff

% outputs
%
%  t = the threshold intensity
    [h,edges] = histcounts(img,2048);
    h=cumsum(h);
    h=h/max(h);
    ind = find(h>fractionBelow,1);
    t = edges(ind);
end
