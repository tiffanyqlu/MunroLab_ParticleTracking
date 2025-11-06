function [im] = readMultiFrameTiff(tifName)
%readMultiFrameTiff reads the contents of a multiframe tiff iunto an array
%of pixel data 
%   Detailed explanation goes here

if isfile(tifName)
     tifInfo = imfinfo(tifName)
     nFrames = length(tifInfo);
     if nFrames > 0
          w = tifInfo(1).Width;
          h = tifInfo(1).Height;
          im = zeros(h,w,nFrames,'uint16');
          for i = 1:nFrames 
              im(:,:,i) = imread(tifName,i);
          end
     end
else
    disp('choose a valid filename file.tif');
end
    

