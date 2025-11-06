function l = trkLengths(trackInfo )
%trklengths:  compute an array of trajectory lengths for the tracks in
%trackinfo
%   Input:
%
%       trackinfo = an array of trajectories produced as ouput by uTrack's
%       ScriptTrackGeneral
%   
%   Outout:
%
%       l = an array of tracklengths.

    s = size(trackInfo,1);
    l = zeros(s,1);
    for i=1:s
        l(i) = size(trackInfo(i,1).tracksFeatIndxCG,2);
    end
end

