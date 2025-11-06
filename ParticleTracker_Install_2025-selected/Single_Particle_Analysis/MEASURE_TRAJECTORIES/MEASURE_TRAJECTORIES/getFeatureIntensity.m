function res = getFeatureIntensity(im,xP,yP,featureSize)

%  getFeatureIntensity:  get the summed pixel intensities from a given
%  image stack within an ~circular ROI centered on the given point with
%  sub-pixel interpolation
%
%  Inputs

%   im      =           [height][width][nFrames] image stack to take the intensity
%   xP      =           x coordinate of the point in pixels
%   yP      =           y coordinate of the point in pixels 
%   featureSize     =   the radius of the ROI
%
%
%  Outputs
%
%   res      =           a vector of interpolated mean intensities, one for
%                       each frame in the image stack



%  get integer part 
iX = fix(xP);  
iY = fix(yP);

% get fractional part
fX = xP - iX;   
fY = yP - iY;


extent=2*featureSize+1;
xl = iX - fix(extent/2);
xh = xl + extent - 1;        
yl = iY - fix(extent/2);
yh = yl + extent - 1;           

% Create the mask
rsq = rsqd( extent,extent);
mask = le(rsq,(extent/2)^2);  

% set up four arrays for the iunterpolation
image   = double(im(yl:yh,xl:xh,:));
imageX  = double(im(yl:yh,xl+1:xh+1,:));
imageY  = double(im(yl+1:yh+1,xl:xh,:));
imageXY = double(im(yl+1:yh+1,xl+1:xh+1,:));

% compute and return the interpolated values
topI = (1-fX)*image + fX*imageX;
botI = (1-fX)*imageY + fX*imageXY;
subI = (1-fY)*topI + fY*botI;
res = sum(sum((subI.*mask )))/length(find(mask)); 
