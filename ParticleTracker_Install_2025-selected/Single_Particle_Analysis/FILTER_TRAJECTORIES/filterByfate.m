function out = filterByROI(tracks, fate)
% This function  returning only those trajectories with the specified fate.

%Inputs

% tracks = a list of particle tracks which is assumed to be in the format 
% output by the function uTrackToSimpleTraj.m:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% fate         = 'birth', 'death', 'both'


%out  = a subarray of the input containing only those tracks have the
% specified fate


    numTracks = size(tracks,2);
    indices = zeros(1,numTracks);

    for i=1:numTracks
        if strcmp(fate,'birth')
            if roi(x(1),y(1)) == 0
                indices(i) = 1;
            end
        end
        if strcmp(fate,'death')
            if roi(x(tracks(i).lifetime),y(tracks(i).lifetime)) == 0
                indices(i) = 1;
            end
        end
        if strcmp(fate,'both')
            if roi(x(1),y(1)) == 0 && roi(x(tracks(i).lifetime),y(tracks(i).lifetime)) == 0
                indices(i) = 1;
            end
        end      
    end
    
    out = tracks(logical(indices));

    
end