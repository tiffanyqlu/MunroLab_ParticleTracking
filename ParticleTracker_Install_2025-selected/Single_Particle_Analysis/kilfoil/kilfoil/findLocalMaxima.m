function r = findLocalMaxima(image,featureR,minIntensity)

% Inputs
%
%   image = the bandpass-filtered image
%   featureRadius = the radius of the desired features 
%   minIntensity  = min intensity of desired peaks


% if minIntensity == 0, set minIntensity at 30 percentile of intensity distribution
if minIntensity == 0
    minIntensity = getIntensityThreshold(a,0.3);
end

clear a h
a=image;

featureD = 2*featureR + 1;
s = makeRSQDMask(featureD,featureD);
mask = (s<=featureR^2);

% use image dilation to replace each pixel value with local intensity
% maximum over surrounding region defined by mask.
imd = imdilate(a,mask);

% identify local maxima above minIntensity
r = find(a==imd & a >= minIntensity);

% Discard maxima within range of the edge
sz = size(a);
nx = sz(2);
ny = sz(1);

y = mod(r,ny);
x = fix(r/ny+1);
x0 = double(x) - featureR;
x1 = double(x) + featureR;
y0 = double(y) - featureR;
y1 = double(y) + featureR;
good = find( (x0 >=1) & (x1<nx) & (y0>=1) & (y1<ny));

r = r(good);
x = x(good);
y = y(good);
x0 = x0(good);
x1 = x1(good);
y0 = y0(good);
y1 = y1(good);


% Find and clear spurious points arising from features which get 
% found twice or which have flat peaks and thus produce multiple hits.  
c=zeros(ny,nx);
c(r) = a(r);
center = featureD * featureR + featureR + 1; % position in mask pixel number of the center of the mask
for i = 1:length(r),
    b = c(y0(i):y1(i),x0(i):x1(i));
    b =  b.*mask;  % 	look only in circular region

    [Y,I] = sort(b,1);
    g1=I(length(I(:,1)),:); % array containing in which row was the biggest value for each column
    [yi,locx]=max(Y(length(Y(:,1)),:));  % yi is abs maximum within mask, locx is column #

    % *** come back to fix this, since will lose local maxima that are in the
    % center, if they are not larger than a fluctuation nearby (within the
    % radius) ***

    locy = g1(locx);  % row number corresponding to maximum
    [d1 d2]=size(b);
    location = (locx-1)*d1+locy;  % find location of remaining maximum in the mask
    if (location ~= center), %compare location of max to position of center of max
		c(y(i),x(i)) = 0;
    end
end

% What's left are valid maxima.
r = find( c ~= 0 );	
