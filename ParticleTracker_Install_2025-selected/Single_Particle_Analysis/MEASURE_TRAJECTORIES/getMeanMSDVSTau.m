function [X, Dis, sd, se] = getMeanMSDVSTau(trks,movieInfo)

% % Computes mean square displacement vs time lag tau for each trajectory
% in the given list.  Then computes and returns the mean value, the
% standard deviation, and the standard error


% Inputs:

% trks = an array of particle trajectories which is assumed to be in the format 
% output by the function uTrackToSimpleTraj:
%
%   'first' =   the first movie frame in which this track appears
%   'last' =    the last movie frame in which this track appears.
%   'lifetime' = the length of the track in frames.
%   'x' = an array containing the sequence of x positions.
%   'y' = an array containing the sequence of y positions.
%   'I' = an array containing the intensity values.


% minTrackLength = minimum length of particle track in frames to include in
% the analysis.

% movieInfo         =   a struct containing the following fields:
%     
%     frameRate:      in #/sec
%     pixelSize:      in µm
% 
% Output:

% 


    numTracks = size(trks,2);

    % set up arrays
    maxN = max(cell2mat({trks.lifetime}));
    Disx=zeros(1,maxN);
    Disy=zeros(1,maxN);
    sd = zeros(1,maxN);
    se = zeros(1,maxN);
    count=zeros(1,maxN);
    X = 1:maxN;

    % physical units of time and space
    frameInterval = 1/movieInfo.frameRate;
    X=X*frameInterval;    
    pixSQ = movieInfo.pixelSize*movieInfo.pixelSize;

    for i=1:numTracks 
        lt = trks(i).lifetime;
        judge=isnan(trks(i).x);
        for tau=1:lt-1
            for j=tau+1:tau:lt
                if ~(judge(j-tau)||judge(j))
                    x0=trks(i).x(j-tau);
                    y0=trks(i).y(j-tau);
                    x1=trks(i).x(j);
                    y1=trks(i).y(j);
                    Disx(tau)=Disx(tau)+(x1-x0)^2;
                    Disy(tau)=Disx(tau)+(y1-y0)^2;
                    count(tau)=count(tau)+1;
                end
            end
        end
    end

    Disx = pixSQ*Disx./count;
    Disy = pixSQ*Disy./count;
    Dis=Disx+Disy;

    for i=1:numTracks 
        lt = trks(i).lifetime;
        judge=isnan(trks(i).x);
        for tau=1:lt-1
            for j=tau+1:tau:lt
                if ~(judge(j-tau)||judge(j))
                    x0=trks(i).x(j-tau);
                    y0=trks(i).y(j-tau);
                    x1=trks(i).x(j);
                    y1=trks(i).y(j);
                    dx2 = pixSQ*(x1-x0)^2;
                    dy2 = pixSQ*(y1-y0)^2;
                    sd(tau) = sd(tau) + (Dis(tau) - (dx2+dy2))^2;
                    count(tau)=count(tau)+1;
                end
            end
        end
    end


    lastI = find(count>=100,1,'last');
    sd = sd./count;
    sd = sqrt(sd);
    se = 1.96*sd./sqrt(count);

    X = X(1:lastI);
    Dis = Dis(1:lastI);
    sd = sd(1:lastI);
    se = se(1:lastI);
end

