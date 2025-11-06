function subtracks = filterBySpeed(tracks,minSpeed, maxSpeed,movieInfo,sgolay)
% Go through all input tracks, estimate speed by fittinglinear functon to cumulative displacement vs time, 
% then return only those with speed>minSpeed and speed < maxSpeed

% Inputs:

% tracks = a list of particle tracks which is assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.

% minSpeed  Return all tracks with speed greater than minSpeed

% maxSpeed  Return all tracks with speed less than maxSpeed

% sgolay = width of the goley window to smooth the x and y
% data


% movieInfo         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm
% 
% Output:

% subtracks          The sublist of tracks.

    numTracks = size(tracks,2);
    speed = zeros(1,numTracks);
    
    for i=1:numTracks
        speed(i) = getSpeed(tracks(i),movieInfo,sgolay);
    end
    subtracks = tracks((speed<maxSpeed)&(speed>minSpeed));

end

