function msd = getMSDvsTAU(trk,maxTau,movieInfo)
% Compute msd vs tau for tau < maxTau

% Inputs:

% trk = a particle track in simple format
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
%     frameRate:      in #/sec
%     pixelSize:      in µm
% 
% Output

% msd           msd vs tau for the given track

    maxT = min([maxTau,trk.lifetime-1]);
    msd=zeros(1,maxT);
    for tau=1:maxT
        N=trk.lifetime-tau;
        dx = trk.x(tau+1:tau+N)-trk.x(1:N);
        dy = trk.y(tau+1:tau+N)-trk.y(1:N);
        dx = dx(~isnan(dx));
        dy = dy(~isnan(dy));
        msd(tau) = mean(dx.*dx + dy.*dy);
    end
    msd = msd*movieInfo.pixelSize*movieInfo.pixelSize;
end



