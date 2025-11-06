function [out] = getSimpleTrajFromCompoundTracks(tracks, movieInfo)
% getSimpleTrajFromCompoundTracks transforms track data from the tracksFinal format into
% a form that is suitable for further analysis. First uses extractCmpTrks.m. to
% extract the subset of compound tracks, then breaks these compund tracks
% up into "simple tracks", each representing the sections of a track between
% merge and split events.


%Inputs:

%tracks = the tracksFinal structure output by ScriptTrackGeneral.

% movieInfo         =   a struct containing the following fields:
%     
%     baseName:       original datafile name minus the ".tif" ext
%     frameRate:      in #/sec
%     pixelSize:      in µm
%     firstFrame      first frame of movie segment 
%     lastFrame:      last frame of movie segment 
%     APOrientation:  0 if anterior is to the left; 1 if it is to the right 


%Ouput : 

%  out = an array of structures, one for each simple track, whose fields are defined as follows:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.



%% Set up some basics
    tracks = extractCmpdTrks(tracks);
    numCTracks = size(tracks,1);

    if numCTracks == 0
        out = [];
    else
        
        numTracks = 0;
        for i = 1:numCTracks
            numTracks = numTracks + size(tracks(i,1).tracksFeatIndxCG,1);
            events = tracks(i,1).seqOfEvents;
            coords=tracks(i,1).tracksCoordAmpCG;
            ncTrks = size(coords,1);
            for j = 1:2*ncTrks
                if ~isnan(events(j,4))
                    numTracks = numTracks + 1;
                end
            end
        end
        out(numTracks) = struct('first',0,'last',0,'lifetime',0,'x',0,'y',0,'I',0,'origin','birth','fate','death');
        breaks = [];
    
    
        cnt = 0;
        for i=1:numCTracks
            events = tracks(i,1).seqOfEvents;
            coords=tracks(i,1).tracksCoordAmpCG;
            ncTrks = size(coords,1);
            for j = 1:2*ncTrks
                frm = events(j,1) + movieInfo.firstFrame - 1;
                ind = events(j,3);
                if events(j,2) == 1     %  initiation event
                    out(cnt+ind).first = frm;
                    if isnan(events(j,4))
                        out(cnt+ind).origin = 'birth';
                    else
                       out(cnt+ind).origin = 'split';
                       breaks = [breaks struct('index',cnt+events(j,4),'frm',frm,'fate','split')];
                    end
                else              %  termination event
                    if isnan(events(j,4))% death
                        out(cnt+ind).last = frm;
                        out(cnt+ind).fate = 'death';
                    else % merge
                        out(cnt+ind).last = frm-1;
                        out(cnt+ind).fate = 'merge'; 
                        breaks = [breaks struct('index',cnt+events(j,4),'frm',frm,'fate','merge')];
                    end
                end
            end
    
            for j = 1:ncTrks      
                l = out(cnt+j).last-out(cnt+j).first+1;
                x = zeros(1,l);
                y = zeros(1,l);
                I = zeros(1,l);
                offset = out(cnt+j).first-out(cnt+1).first;
                first = out(cnt+j).first-out(cnt+1).first+1;
                last = out(cnt+j).last-out(cnt+1).first;
                for k=1:l
                    x(k)=coords(j,8*(k+offset)-7);
                    y(k)=coords(j,8*(k+offset)-6);
                    I(k) = coords(j,8*(k+offset)-4);
                end
    
                out(cnt+j).lifetime = l;
                out(cnt+j).x = naninterp(x);
                out(cnt+j).y = naninterp(y);
                out(cnt+j).I = naninterp(I);
    
            end
            cnt=cnt+ncTrks;
    
        end
        
        nB = size(breaks,2);
        for j = 1:nB
     
            trk = out(breaks(j).index);  % track that needs to be divided at breakpoint
            
            if strcmp(breaks(j).fate,'merge')    
                out(cnt+j).first = trk.first;
                out(cnt+j).last = breaks(j).frm-1;
                out(breaks(j).index).first = breaks(j).frm;
            else   % split
                out(cnt+j).first = trk.first;
                out(cnt+j).last = breaks(j).frm-1;
                out(breaks(j).index).first = breaks(j).frm;
            end            
            l = out(cnt+j).last - out(cnt+j).first+1;
            out(cnt+j).lifetime = l;
            out(cnt+j).x = trk.x(1:l);
            out(cnt+j).y = trk.y(1:l);
            out(cnt+j).I = trk.I(1:l);
            out(cnt+j).origin = trk.origin;
            out(cnt+j).fate = breaks(j).fate;
            
            out(breaks(j).index).x = trk.x(l+1:trk.lifetime);
            out(breaks(j).index).y = trk.y(l+1:trk.lifetime);
            out(breaks(j).index).I = trk.I(l+1:trk.lifetime);
            out(breaks(j).index).origin = breaks(j).fate;
            out(breaks(j).index).lifetime = trk.lifetime-l;
        end
    end
end


        