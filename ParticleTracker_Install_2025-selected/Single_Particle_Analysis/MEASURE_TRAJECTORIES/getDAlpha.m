function [D,Alpha] = getDAlpha(trks,maxTau,movieInfo)
% Compute msd vs tau for tau < maxTau, and then fit to msd = 4Dt^alpha to
% estimate D and alpha

% Inputs:

% trks = an array of particle tracks in simple format
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% maxTau            Estimate D and alpha from MSD vs tau for tau <= maxTau.

% movieInfo         =   a struct containing the following fields:
%     
%     baseName:       original datafile name minus the ".tif" ext
%     frameRate:      in #/sec
%     pixelSize:      in µm
%     firstFrame      first frame of movie segment 
%     lastFrame:      last frame of movie segment 
%     APOrientation:  0 if anterior is to the left; 1 if it is to the right 
% 
% Output:

% subtracks          D,alpha

    numTracks = size(trks,2);   
    D = zeros(numTracks,1);
    Alpha = zeros(numTracks,1);

    for i = 1:numTracks
        msd = getMSDvsTAU(trks(i),maxTau,movieInfo);
        X=1:maxTau;
        temp=polyfit(log(X/movieInfo.frameRate),log(msd),1);
        Alpha(i) = temp(1);
        D(i) = exp(temp(2))/4;
    end

end



