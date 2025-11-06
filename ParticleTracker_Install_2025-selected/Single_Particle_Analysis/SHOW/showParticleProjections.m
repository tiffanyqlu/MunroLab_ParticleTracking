function [ ] = showParticleProjections(tifname,trks, groupSize,lineWidth)
%   Draws tracked particles as colored circles onto the original image sequence from which the trajectories 
%   were derived. It is assumed that neither the image sequence, nor the trajectories
%   have been transformed in any way (e.g. rotated and translated).
% 
%   Inputs:  

%       in: the array of images that was used to compute the particle trajectories
%       trks:  An array of particle trajecotries in "simple" format
%       minI,maxI:  min and max intensity values used in mapping the 16 bit input image data to 8 bit output 
%       markerSize:  radius of circles
%
%   Output:
%
%   a directory called 'tmp' containing a sequence of individual tif frames -
%   frm0001.tif, 'frm0002.tif, ...

mkdir 'tmp';

nTrks = length(trks);
in = readMultiFrameTiff(tifname);
xaxis = size(in,1);
yaxis = size(in,2);
nFrames = size(in,3);

iMax = mean(max(max(in)));
iMin = mean(min(min(in)));


fig = figure;
fig.InnerPosition = [100 100 xaxis yaxis];
axes('Position',[0 0 1 1]);

for i = 1:nFrames
    %clf;
    imshow(in(:,:,i),[minI maxI]); 
    axis image;
    hold on;
    firstT = groupSize*(i-1) + 1;
    lastT = groupSize*i;
    for iTrk = 1:nTrks
        if (firstT >= trks(iTrk).first && firstT <= trks(iTrk).last) || (lastT >= trks(iTrk).first && lastT <= trks(iTrk).last) || ...
            (firstT <= trks(iTrk).first && lastT >= trks(iTrk).last)
            ft = max(firstT,trks(iTrk).first) - trks(iTrk).first + 1;
            lt = min(lastT,trks(iTrk).last) - trks(iTrk).first + 1;
            plot(trks(iTrk).x(ft:lt),trks(iTrk).y(ft:lt),'g','LineWidth',lineWidth); % split
        end
    end
    pause(0.01);
    f = getframe();
    %f.cdata = f.cdata(1:xaxis,1:yaxis,:);%
    [im,~] = frame2im(f);
    fs = sprintf('tmp/fov1_%04d.tif',i);
    imwrite(im,fs,'tif');
    hold off;
end

