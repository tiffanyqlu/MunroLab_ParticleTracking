function pixelList = pixelizePath(smoothedPath,pathWidth,initialPosition)
%pixelizePath:  Take a path representing a smoothed trajectory and produce
%an array of pixel positions within a region of interest centered on the
%smoothed path and extending orthogally by a fixed pixel width on either
%side

% Inputs:

% smoothedPath = a 2 x N array containing x and y positions at the N points
% along the smoothed path

% pathWidth         = the width of the path in pixels.  

% initialPosition   = inital position in arclength from the beginning of the smoothed path

% Outputs:
%
% pixelList = a 2 x pathWidth x pixelLength array of x and y pixel values,
%               where pixelLength is the legnth of the path in pixels.

% compute lengths and unit vectors along each segment
[uVecs,segLengths] =  getDisplacements(smoothedPath);
    
% compute normal vectors
nVecs = vertcat(uVecs(2,:),-uVecs(1,:));
nSegs = length(segLengths);
totalL = sum(segLengths);

% use inital position along first segment if specified, else set inital
% position halfway along first segment
if nargin == 3
    s = initialPosition;
else
    s = 0.5*segLengths(1); 
end

% compute total length in pixels
pixelLength = floor(totalL-s) + 1;

pixelList = zeros(2,pathWidth,pixelLength);
orthoDisplacements = -(pathWidth-1)/2:(pathWidth-1)/2;

px = 1;
for i = 1:nSegs
    spread = nVecs(:,i)*orthoDisplacements;
    while s < segLengths(i)
        pixels = smoothedPath(:,i) + uVecs(:,i)*s;
        pixels = pixels + spread;
        pixelList(:,:,px) = pixels;
        px = px+1;
        s = s+1;
    end
    s = s - segLengths(i);
end
    







  



