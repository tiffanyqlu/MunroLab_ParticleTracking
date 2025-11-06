function [featureList] = tracks2Features(trks, ffrm,lfrm)
%UNTITLED convert a cell array in which each cell contains an array of feature data for
%one frame to a single Table
%   Detailed explanation goes here

    maxAvailable = max([trks.last]);
    nFrames = min(maxAvailable,lfrm) - ffrm + 1;

    featureList = cell(1,nFrames);

    n = zeros(nFrames,1);
    for trk = 1:length(trks)
        for j = max(trks(trk).first,ffrm):min(trks(trk).last,lfrm)
            frm = j-ffrm+1;
            n(frm) = n(frm) + 1;
        end
    end

    for j = 1:nFrames
        featureList{j} = zeros(n(j),4);
    end

    n = zeros(nFrames,1);
    for trk = 1:length(trks)
        for j = max(trks(trk).first,ffrm):min(trks(trk).last,lfrm)
            frm = j-ffrm+1;
            n(frm) = n(frm) + 1;
            featureList{frm}(n(frm),1) = trks(trk).x(j-trks(trk).first+1);
            featureList{frm}(n(frm),2) = trks(trk).y(j-trks(trk).first+1);
            featureList{frm}(n(frm),3) = trk;
            if j == trks(trk).first
                switch trks(trk).origin
                    case 'birth'
                        featureList{frm}(n(frm),4) = 1;
                    case 'split'
                        featureList{frm}(n(frm),4) = 3;
                end
            else 
                if j == trks(trk).last
                    switch trks(trk).fate
                        case 'death'
                            featureList{frm}(n(frm),4) = 2;
                        case 'merge'
                            featureList{frm}(n(frm),4) = 4;
                    end
                else  % continuation
                    featureList{frm}(n(frm),4) = 5;
                end
            end
        end
    end
end