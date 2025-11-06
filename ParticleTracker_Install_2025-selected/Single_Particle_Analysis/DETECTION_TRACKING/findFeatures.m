function r = findFeatures(rawImg,featureSize,minPeakIntensity,haloSize)
%  Adapted from the Kilfoil feature2D function. 
% 
%  Dependencies: Requires the Image processing toolbox due to a call to
%  imdilate in the localmax subfunction. 

%  Inputs
%
%   rawImg               =  a single movie frame 
%   featureSize          =  radius of the feature mask
%   minPeakIntensity     =  min intensity of detected peaks
%   haloSize             =  size of the annular halo arond fesatures to sample for background intensity
%
%   Outputs
%
% 		r(:,1):	the x centroid positions, in pixels.
% 		r(:,2): the y centroid positions, in pixels. 
% 		r(:,3): integrated brightness of the features. ("mass")
% 		r(:,4): background-subtracted integrated brightness of the features
% 		r(:,5): the square of the radius of gyration of the features.
% 		        (second moment of the "mass" distribution, where mass=intensity)
% 		f(:,6): eccentricity, which should be zero for circularly symmetric features and 
%                   order one for very elongated images.




lambda = 1;   % spatial scale for noise filter in pixels
if haloSize < 1
    haloSize = 1;
end

maskWidth = 2*featureSize + 1;

% filter out low and high frequencies
bpImage = bpass(rawImg,lambda,featureSize);

sz = size(bpImage);
nx = sz(2);
ny = sz(1);

% Find local maxima
loc= findLocalMaxima(bpImage,featureSize,minPeakIntensity);
nmax=length(loc); 
if (nmax == 0 || loc(1) == -1)
    r = [];
    return
end

% Pixel positions of the maxima
y = mod(loc,ny);
x = fix(loc/ny+1);  

        
% Setup some result arrays
m   = zeros(nmax,1);
bsm = zeros(nmax,1);
xc  = zeros(nmax,1);
yc  = zeros(nmax,1);
rg  = zeros(nmax,1);
e   = zeros(nmax,1);

xl = x - featureSize;
xh = x + featureSize;        
yl = y - featureSize;
yh = y + featureSize;           
cen = featureSize + 1;           

% Set up some masks
rsqd = makeRSQDMask(maskWidth,maskWidth);
mask = le(rsqd,(maskWidth/2)^2);  

mask2 = ones(1,maskWidth)'*[1:maskWidth];
mask2 = mask2.*mask;        
xmask = mask2;
ymask = mask2';

% sub-pixel mask
suba = zeros(maskWidth, maskWidth, nmax);

% mask for computing radius of gyration
rgMask = (rsqd.*mask) + (1/6);

% masks for computing eccentricity
theta = makeThetaMask(maskWidth);
cosMask = cos(2*theta).*mask;
sinMask = sin(2*theta).*mask;
cosMask(cen,cen) = 0.0;
sinMask(cen,cen) = 0.0;  

% masks to measure background-subtracted intensities from the raw image
twoIhalo = 2*haloSize;
avrsqd = makeRSQDMask(maskWidth+twoIhalo,maskWidth+twoIhalo);
avmask = le(avrsqd,(maskWidth/2+haloSize)^2);
halo_mask = avmask-padarray(mask,[haloSize haloSize]);
av = zeros(maskWidth+twoIhalo,maskWidth+twoIhalo,nmax);

% Estimate the mass	
for i=1:nmax 
    m(i) = sum(sum(double(bpImage(fix(yl(i)):fix(yh(i)),fix(xl(i)):fix(xh(i)))).*mask)); 
end

% Calculate feature centers
for i=1:nmax
	xc(i) = sum(sum(double(bpImage(fix(yl(i)):fix(yh(i)),fix(xl(i)):fix(xh(i)))).*xmask));  
	yc(i) = sum(sum(double(bpImage(fix(yl(i)):fix(yh(i)),fix(xl(i)):fix(xh(i)))).*ymask));
end

% Correct for the 'offset' of the centroid masks
xc = xc./m - cen;             
yc = yc./m - cen; 

% Update the positions
x2 = x + xc;
y2 = y + yc;


%	Construct the subarray and calculate the mass, squared radius of gyration, eccentricity
for i=1:nmax  

    % compute background-subtracted mass
    if fix(yl(i))>haloSize & fix(yh(i))<ny-haloSize & fix(xl(i))>haloSize & fix(xh(i))<nx-haloSize
        suba(:,:,i) = fracshift( double(rawImg(fix(yl(i)):fix(yh(i)),fix(xl(i)):fix(xh(i)))), -xc(i) , -yc(i) );
        bsm(i) = sum(sum(( suba(:,:,i).*mask )));         
        av(:,:,i) = fracshift(double(rawImg(fix(yl(i))-haloSize:fix(yh(i))+haloSize,fix(xl(i))-haloSize:fix(xh(i))+haloSize)),-xc(i),-yc(i));
        av2 = sum(sum(( av(:,:,i).*halo_mask)))/length(find(halo_mask));
        bsm(i) = bsm(i) - length(find(mask))*av2;
    else
        bsm(i) = nan;
    end

    % compute mass
    suba(:,:,i) = fracshift(double(bpImage(fix(yl(i)):fix(yh(i)),fix(xl(i)):fix(xh(i)))),-xc(i),-yc(i));
    m(i) = sum(sum((suba(:,:,i).*mask))); 

    % compute squared radius of gyration
    rg(i) = (sum(sum(suba(:,:,i).*rgMask)))/m(i);   

    % compute eccentricity
    tmp = sqrt(((sum(sum(suba(:,:,i).*cosMask)))^2) + ((sum(sum(suba(:,:,i).*sinMask )))^2)); 
    tmp2 = m(i) - suba(cen,cen,i) + 1e-6;
    e(i) = tmp/tmp2;                               
   
end

% Recalculate feature centers
for i=1:nmax
	xc(i) = sum(sum(double(suba(:,:,i)).*xmask));  
	yc(i) = sum(sum(double(suba(:,:,i)).*ymask));
end

% Correct for the 'offset' of the centroid masks
xc = xc./m - cen;             
yc = yc./m - cen;  

% Update the positions
x3 = x2 + xc;
y3 = y2 + yc;

b = find(~isnan(bsm));
r = [x3(b),y3(b),m(b),bsm(b),rg(b),e(b)];






