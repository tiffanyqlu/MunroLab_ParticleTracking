function a = getFeatureMaskArea(featureSize)
%getFeatureMaskArea calculate the area of the featurew mask used to
%calculate total integrated intensity of features
    featureD = 2*featureSize+1;
    rsqd = makeRSQDMask(featureD,featureD);
    mask = le(rsqd,(featureD/2)^2);  
    a = sum(sum(mask));
end