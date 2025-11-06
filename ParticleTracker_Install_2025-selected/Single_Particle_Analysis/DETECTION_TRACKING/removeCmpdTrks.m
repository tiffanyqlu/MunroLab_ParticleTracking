function [tracks] = removeCmpdTrks(trks)

%Purpose: remove the compound tracks from a list of trajectories in µTrack format,



%Input : tracksFinal structure produced by µTrack's ScriptTrackGeneral.m
%Ouput : subset of tracksFinal structure containing only simple tracks

numtrks = size(trks,1);
newtrks = ones(numtrks,1);
j = 1;


for i = 1:numtrks
    curTrk = trks(i);
    curCoordAmp = curTrk.tracksCoordAmpCG;
    if (size(curCoordAmp,1) > 1)   % if the curCoordAmp has more than 1 row, exclude it (general compound track)
        newtrks(i) = 0;
        j = j + 1;
    end
end
tracks = trks(logical(newtrks));
