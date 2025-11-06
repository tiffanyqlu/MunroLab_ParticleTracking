function out = filterByROI(tracks, roi,fate)
% This function transforms a list of particle tracks, returning only those that are contained within 
% the specified ROI.

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



%roi: a 2D array such that roi(x,y) = non-zero inside the region of interest, zero outside.


% fate         = 'birth', 'death', 'passthrough' or 'both


%out  = a subarray of the input containing only those tracks whose starting or ending 

%   'birth' => retain all trajectories that are born in the masked region
%   'death' => retain all trajectories that die in the masked region
%   'both' => retain all trajectories that are born and die in the masked region


    numTracks = size(tracks,2);
    indices = zeros(1,numTracks);
    roi = transpose(roi);
    for i=1:numTracks
        x = floor(naninterp(tracks(i).x));
        y = floor(naninterp(tracks(i).y));
        ind = sub2ind(size(roi),x,y);
        mVal = roi(ind);
        zel = mVal(mVal == 0);
        if ~isempty(zel)
            if strcmp(fate,'passthrough')
                indices(i) = 1;
            end
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
    end
    
    out = tracks(logical(indices));

    
end