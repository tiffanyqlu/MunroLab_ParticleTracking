function [coloc, not_coloc] = findColocalizedFeatures(im,trks1,trks2, rColoc)
% findColocalizedSpots:  Given two sets of trajectories trks1 and trks2 obtained from the
% same embryo by two-color imaging, find the positions within trks2 that
% colocalize with features found within trks1.  findColocalizedSpots adds a
% new field called mates to each trajectory in trks2 which lists by frame the
% index in trks1 of colocalized features 
% 
%  
%   Inputs:  

%       im: the image sequence from which trks1 (or trks2) were found  

%       trks1:  An array of particle trajectories in "simple" format to
%       determine colocalization with

%       trks2:  An array of particle trajectories in "simple" format to
%       determine colocalization for

%       rColoc:  threshold distance (in pixels) between the centroids of
%       two features below which they are considered to be colocalized

%
%   Output:
%
%       coloc:  A subset of the trtajectories in trks2 that are colocalized
%       with feaures in trks1

%       not_coloc:  A subset of the trtajectories in trks2 that are not colocalized
%       with feaures in trks1
    rColoc
    nColoc = ceil(rColoc) + 1
   
    registry = uint16(zeros(size(im,3),size(im,2),size(im,1)));
    maskWidth = 2*nColoc+1;
    rsqd = makeRSQDMask(maskWidth,maskWidth);
    mask = le(rsqd,(maskWidth/2)^2);  

    % put trks1 features into registry
    for nTrk = 1:length(trks1)
        trk = trks1(nTrk);
        x = ceil([trk.x]);
        y = ceil([trk.y]);
        frm = trk.first;

        for j = 1:trk.lifetime
            if registry(frm,x(j)-nColoc:x(j)+nColoc,y(j)-nColoc:y(j)+nColoc)
                nTrk
            end
            registry(frm,x(j)-nColoc:x(j)+nColoc,y(j)-nColoc:y(j)+nColoc) = nTrk*mask;
            frm = frm + 1;
        end 
    end

    % trks2 features look at registry
    hasMates = zeros(1,length(trks2));
    for nTrk = 1:length(trks2)
        trk = trks2(nTrk);
        x = ceil([trk.x]);
        y = ceil([trk.y]);
        mates = zeros(trk.lifetime,1);
        frm = trk.first;

        for j = 1:trk.lifetime
            iTrk = registry(frm,x(j),y(j));
            if iTrk
                mFrm = frm-trks1(iTrk).first+1;
                dx = trks1(iTrk).x(mFrm)-trk.x(j);
                dy = trks1(iTrk).y(mFrm)-trk.y(j);
                d = sqrt(dx*dx+dy*dy);
                if d < rColoc
                    mates(j) = iTrk;
                end
            end
            frm = frm + 1;
        end 
        trks2(nTrk).mates = mates;
        hasMates(nTrk) = ~isempty(find(mates));
    end
     coloc = trks2(find(hasMates));
     not_coloc = trks2(find(~hasMates));
end