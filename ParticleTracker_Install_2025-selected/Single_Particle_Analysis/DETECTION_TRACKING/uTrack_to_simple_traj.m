function [out] = uTrack_to_simple_Traj(tracks, firstFrame,lastFrame,movieInfo,includeCompoundTracks)
% uTrack_to_simple_Traj transforms track data from the tracksFinal format into
% a form that is suitable for further analysis. Uses removeCmpTrks.m. to
% remove any cmpd tracks.


%Inputs:

%tracks = the tracksFinal structure output by ScriptTrackGeneral.

%     firstFrame      first frame of movie segment 

%     lastFrame:      last frame of movie segment 

%excludeCompoundTracks = a logical value:

% if includeCompoundTracks = 0, ignore compound tracks
% if excludeCompoundTracks = 1, extract segments of compound tracks
% between merge and split events and add to the list


%Ouput : 

%  out = an array of structures, one for each track, whose fields are defined as follows:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.
%   'origin' = 'unknown', 'birth', 'merge' or 'split.
%   'fate' = 'merge', 'split, 'death' or 'unknown'.



%% Set up some basics
cTrks = [];
if includeCompoundTracks
    cTrks = getSimpleTrajFromCompoundTracks(tracks,movieInfo);
    if ~isempty(cTrks)
        cTrks = cTrks([cTrks.lifetime]>1);
    end
end
tracks = removeCmpdTrks(tracks);

numTracks = size(tracks,1);
trkLengths = trkLength(tracks);
sTrks(numTracks) = struct('first',0,'last',0,'lifetime',0,'x',0,'y',0,'I',0,'origin','unknown','fate','unknown');


for trk=1:numTracks
    coords=tracks(trk,1).tracksCoordAmpCG;
    events = tracks(trk,1).seqOfEvents;
    x = zeros(1,trkLengths(trk));
    y = zeros(1,trkLengths(trk));
    I = zeros(1,trkLengths(trk));

    for j=1:trkLengths(trk)
        x(j)=coords(1,8*j-7);
        y(j)=coords(1,8*j-6);
        I(j) = coords(1,8*j-4);
    end

    sTrks(trk).first = firstFrame - 1 + movieInfo.firstFrame - 1 + events(1,1);
    sTrks(trk).last = firstFrame - 1 + movieInfo.firstFrame - 1 + events(2,1);
    sTrks(trk).lifetime = trkLengths(trk);
%     sTrks(trk).I = I;
%     sTrks(trk).x = x;
%     sTrks(trk).y = y;
    sTrks(trk).x = naninterp(x);
    sTrks(trk).y = naninterp(y);
    sTrks(trk).I = naninterp(I);
   if sTrks(trk).first > firstFrame 
        sTrks(trk).origin = 'birth';
    else 
        sTrks(trk).origin = 'unknown';
    end
    
    if sTrks(trk).first < lastFrame 
        sTrks(trk).fate = 'death';
    else 
        sTrks(trk).fate = 'unknown';
    end      
end

out = [sTrks cTrks];


        