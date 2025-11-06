function [ ] = showParticles(movie,particles, markerSize)

%   Draws particles detected in a sequence of movie frames as colored circles onto the original image sequence. t is assumed that neither 
% the image sequence, nor the trajectories have been transformed in any way (e.g. rotated and translated).
% 
%   Inputs:  

%       movie: the image sequence

%       particles:  An array of particles in Kilfoil format

%       markerSize:  radius of circles
%
%   Output:
%
%   a quicktime movie called particles.mp4
%   in which particles are drawn as colored circles over the original data.

    xaxis = size(movie,1);
    yaxis = size(movie,2);
    nFrames = size(movie,3);

    iMax = mean(max(max(movie)));
    iMin = mean(min(min(movie)));

    fig = figure;
    fig.InnerPosition = [100 100 xaxis yaxis];
    axes('Position',[0 0 1 1]);

    % create the video writer with 30 fps
    writerObj = VideoWriter('particles','MPEG-4');
    writerObj.FrameRate = 30;
    open(writerObj);

    for frm = 1:nFrames
        p = particles(find(particles(:,5) == frm),:);

        % draw movie frame, overlay ROI and 
        imshow(movie(:,:,frm),[iMin iMax]); 
        axis image;
        hold on;
        
        % plot the detected features
        for i = 1:length(p)
            plot(p(i,1),p(i,2),'co','MarkerSize',markerSize);
        end
        pause(0.01);
        frame = getframe();
        writeVideo(writerObj, frame);
        hold off;
    end
    close(writerObj);
end