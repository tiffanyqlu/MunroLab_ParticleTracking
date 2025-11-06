function [tracks] = extractCmpdTrks(trks)

%Extract the compound tracks from a list of trajectories in µTrack format.
%These are the tracks that include merge and split events.


%Input : tracksFinal structure produced by µTrack's ScriptTrackGeneral.m

%Ouput : subset of tracksFinal structure containing only the compound tracks

numtrks = size(trks,1);
newtrks = zeros(numtrks,1);
j = 1;

for i = 1:numtrks
    curTrk = trks(i);
    curCoordAmp = curTrk.tracksCoordAmpCG;
    if (size(curCoordAmp,1) > 1)   % if the curCoordAmp has more than 1 row, include it (general compound track)
        newtrks(i) = 1;
        j = j + 1;
    end
end
tracks = trks(logical(newtrks));
