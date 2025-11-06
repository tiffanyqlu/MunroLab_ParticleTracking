function features = preTrack(frms, fl,featureSize, minPeakIntensity, minIntegratedIntensity, haloSize)
% preTrack  A modified version of the Kilfoil
% mpretrack function, hiding the unimportant details.
% Note: feature2D requires the Image processing toolbox due to a call to
% imdilate in the localmax subfunction. Use feature2D_nodilate for an
% alternative which works almost as well.
%
% INPUTS :

% frms                 =                    sequence of image frames
%
% fl = [firstFrame lastFrame]               first and last frames
%
% minPeakIntensity          =               the minimum intensity of local peaks to consider in the first step of particle detection
%                                           read from Min intensity setting in Kilfoil Pretrack GUI.
%
% minIntegratedIntensity       =            the minimum integhrated intensity of local peaks to consider in the second step of particle detection
%                                           read from Int intensity setting
%                                           in Kilfoil Pretrack GUI.
%
% featureSize               =           the particle feature sizeto use, read from the Feature Size setting in Kilfoil Pretrack GUI 
%
% haloSize                  =           the width of an annular region around the feature in which to meausure background intensity so as to 
%                                       produce a backgorund subtracted integrated intensity measurement

% OUTPUTS
%
% features - an array of data for each feature detected with the following
% columns:

%   features(:,1)   - X centroid position (in pixels)
%   features(:,2)   - Y centroid position (in pixels)
%   features(:,3)   - Integrated intensity
%   features(:,4)   - background-subtracted integrated intensity
%   features(:,5)   - frame #
%

    d=0;
    ff = fl(1);
    lf = fl(2);
    nf = ff-lf+1;

    % allocate storage for found features
    features = cell(nf);

    for frm = ff:lf
        img = frms(:,:,frm);
        M = findFeatures(img,featureSize,minPeakIntensity,haloSize);
    
        if mod(frm,100) == 0
            disp(['Frame ' num2str(frm)])
        end
    
        if not(isempty(M))   
            % Reject features with integrated intensity less than threshold
            M = M(M(:,3) > minIntegratedIntensity,:);
            features{frm-ff+1} = M;
            a = length(M(:,1));
            disp([num2str(a) ' features kept.'])
        end
    end
end