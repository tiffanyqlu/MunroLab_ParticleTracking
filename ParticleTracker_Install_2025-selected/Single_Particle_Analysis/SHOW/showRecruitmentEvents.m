function [ ] = showRecruitmentEvents(trks, markerSize)
%   Draws tracked particles as colored circles onto the original image sequence from which the trajectories 
%   were derived. It is assumed that neither the image sequence, nor the trajectories
%   have been transformed in any way (e.g. rotated and translated).
% 
%   Inputs:  

%       im: imasge of the embryosd from which the particles were measured  

%       trks:  An array of particle trajectories in "simple" format

%       markerSize:  radius of circles in pixels

%       outputfilename:  the name of the outputfile (.avi will be appended)
%
%   Output:
%



    figure;
    hold;

    nTrks = length(trks); 
        
    for trk = 1:nTrks
        x = trks(trk).x(1);
        y = trks(trk).y(1);
        plot(x,y,'Marker','.','MarkerEdgeColor','m','MarkerSize',markerSize);
    end
end

