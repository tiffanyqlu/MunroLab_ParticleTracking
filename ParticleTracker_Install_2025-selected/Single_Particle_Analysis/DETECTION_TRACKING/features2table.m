function [featureTable] = features2table(features, ffrm,lfrm)
%features2table:  A utility function that converts a cell array in which each cell contains an array of feature data for
%one frame to a single Table


    featureArray = [];
    
    nFrames = length(features);
    frm = ffrm;

    for i = 1:nFrames
        tmp = horzcat(frm*ones(size(features{i},1),1),features{i});
        frm = frm+1
        featureArray = vertcat(featureArray,tmp);
    end
    featureTable = array2table(featureArray,'VariableNames',{'frame','CentroidX','CentroidY','Integrated Intensity','Background Subtracted Intensity','Gyration Radius','Eccentricity' });

end