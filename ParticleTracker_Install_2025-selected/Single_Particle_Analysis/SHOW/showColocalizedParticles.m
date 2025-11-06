function [ ] = showColocalizedParticles(in,trks1,trks2, colorMap,I_max_min, markerSize, labelParticles, textOffset,outputfilename)
%   Draws tracked particles as colored circles onto the original image sequence from which the trajectories 
%   were derived. It is assumed that neither the image sequence, nor the trajectories
%   have been transformed in any way (e.g. rotated and translated).
% 
%   Inputs:  

%       tifname: the pathname of the multiframe tif file (relative to the current working directory) 
%       from which the trajectories were extracted.  

%       trks:  An array of particle trajectories in "simple" format

%       markerSize:  radius of circles in pixels

%       labelParticles:  if 1, add text numbers next to each particle

%       textOffset = [xOffset yOffset] sets offset in pixels from feature
%       center to draw text. 

%       outputfilename:  the name of the outputfile (.avi will be appended)
%
%   Output:
%
%   an uncompressed AVI movie in which particles are drawn as colored circles 
%   over the original data. The color of the circle indicates the status of the trajectory:
%
%      blue = birth
%      yellow = death
%      red = continue
%      green = split
%      magenta = merge


    nfrms = size(in,3);
    fig = figure('Position',[10,10,100,100]);
    movieAxes = gca;
    imagesc(movieAxes,in(:,:,1),I_max_min); 
    colormap(colorMap);
    truesize(fig);
    
    % create the video writer with 30 fps
        
    writerObj = VideoWriter(outputfilename,'Uncompressed AVI');
    writerObj.FrameRate = 30;

    % open the video writer
    open(writerObj);


    for frm = 1:nfrms

        % draw the image
        imagesc(movieAxes,in(:,:,frm),I_max_min); 
        
        hold(movieAxes,'on');
        if ~isempty(trks1{frm})
            nTrks = size(trks1{frm},1);    
            for trk = 1:nTrks
                x = trks1{frm}(trk,1);
                y = trks1{frm}(trk,2);
                switch trks1{frm}(trk,4)
                    case 1  % birth
                        markerColor = 'y';
                    case 2  % death
                        markerColor = 'r';
                    case 3  % split
                        markerColor = 'm';
                    case 4  % merge
                        markerColor = 'g';
                    otherwise % continuation
                        markerColor = 'c';
                end
                plot(x,y,'Marker','o','MarkerEdgeColor', markerColor,'MarkerSize',markerSize);
                if labelParticles
                    text(movieAxes,x+textOffset(1),y+textOffset(2),num2str(trks1{frm}(trk,3)), 'Color', 'c');
                end       
            end
        end
        if ~isempty(trks2{frm})
            nTrks = size(trks2{frm},1);    
            for trk = 1:nTrks
                x = trks2{frm}(trk,1);
                y = trks2{frm}(trk,2);
                switch trks2{frm}(trk,4)
                    case 1  % birth
                        markerColor = 'y';
                    case 2  % death
                        markerColor = 'r';
                    case 3  % split
                        markerColor = 'm';
                    case 4  % merge
                        markerColor = 'g';
                    otherwise % continuation
                        markerColor = 'c';
                end
%                 plot(x,y,'Marker','o','MarkerEdgeColor', markerColor,'MarkerSize',markerSize);
                plot(movieAxes,x,y,'Marker','o','MarkerEdgeColor', 'c','MarkerSize',3);
                if labelParticles
                    text(movieAxes,x+textOffset(1),y+textOffset(2),num2str(trks2{frm}(trk,3)), 'Color', 'c');
                end       
            end
        end
        pause(0.001);
        frame = getframe(fig);
        writeVideo(writerObj, frame);
        hold(movieAxes,'off');
   end

   % close the writer object
   close(writerObj);
 

