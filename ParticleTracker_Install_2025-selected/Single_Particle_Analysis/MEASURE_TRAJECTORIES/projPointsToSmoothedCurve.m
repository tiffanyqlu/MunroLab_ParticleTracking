function [segmentIndex, arcLengthOnSegment, arcLengthOnPath] = projPointsToSmoothedCurve(x,y,sgWindowWidth)

% projPointsToSmoothedCurve:  For the given trajectory, projects raw x,y positions onto a smoothed version 
% of the same trajectory, using the Savitsky Golay filter. Returns arrays containing the indices of the segments 
% to which each point projects, the local arclength of the projected 
% points along these segments and the global arclength along the path


% Inputs:

% x             =       list of x coords along trajectory

% y             =       list of y coords along trajector    

% sgWindowWidth     =      size of the smoothing window used by the SavitskyGolay filter


% Outputs:

%   segmentIndex    =       Indices of the segments along the smoothed path to which each point on the original p[ath projects
%
%   arcLengthOnSegment  =   Arclengths of each projected point along the smoothed path, measured
%                           from the beginning of the segment to to which
%                           it projects
%
%   arcLengthOnPath     =   Arclengths of each projected point along the smoothed path, measured
%                           from its beginning

% initialize

    path = vertcat(x,y);
    sx = smoothdata(x,'sgolay',sgWindowWidth);
    sy = smoothdata(y,'sgolay',sgWindowWidth);
    smoothedPath = vertcat(sx,sy);
    arcLengths = getArclengths(smoothedPath);

    nPoints = length(x);
    segmentIndex = zeros(1,nPoints);
    arcLengthOnSegment = zeros(1,nPoints);
    arcLengthOnPath = zeros(1,nPoints);

    
    % loop through all points along trajectory
    for i = 1:nPoints
        
        % project current raw point onto current trajectory segment
        P = path(:,i);
        seg = i;
        if i == nPoints
            seg = nPoints-1;
        end
        P1 = smoothedPath(:,seg);
        P2 = smoothedPath(:,seg+1);
                
        [alpha,dS] = projPointToLine(P,P1,P2);

        
        if alpha < 0    % projected point before segment start; back up
            while seg > 1 & alpha < 0
                seg = seg - 1;
                P2 = P1;
                P1 = smoothedPath(:,seg);
                [alpha,dS] = projPointToLine(P,P1,P2);
            end
            if alpha < 1
                segmentIndex(i) = seg;
                arcLengthOnSegment(i) = dS;
                arcLengthOnPath(i) = arcLengths(seg) + dS;
            else
                segmentIndex(i) = seg;
                arcLengthOnSegment(i) = 0;
                arcLengthOnPath(i) = arcLengths(seg);
            end
        
        elseif alpha > 1    % projected point after segment end; go forward
            while seg < nPoints-1 & alpha > 1
                seg = seg + 1;
                P1 = P2;
                P2 = smoothedPath(:,seg+1);
                [alpha,dS] = projPointToLine(P,P1,P2);
            end
            if alpha > 0
                segmentIndex(i) = seg;
                arcLengthOnSegment(i) = dS;
                arcLengthOnPath(i) = arcLengths(seg) + dS;
            else 
                segmentIndex(i) = seg;
                arcLengthOnSegment(i) = 0;
                arcLengthOnPath(i) = arcLengths(seg);
            end            
        else    % projected point within segment.
            segmentIndex(i) = seg;
            arcLengthOnSegment(i) = dS;
            arcLengthOnPath(i) = arcLengths(seg) + dS;
        end
    end
end

