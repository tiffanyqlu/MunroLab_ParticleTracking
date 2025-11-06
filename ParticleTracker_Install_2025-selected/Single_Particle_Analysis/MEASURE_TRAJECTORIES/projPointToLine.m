function [alpha, dS] = projPointToLine(P,P1,P2)
%projPointToLine: Find the projection of a point P to line that passes through points P1 and P2 in 2D

%Inputs

% P = the point
% P1 = first endpoint of line
% P2 = second endpoint of line

%Output:

%   dS = unnormalized (signed) displacement along line from P1  

%   alpha = displacement along line from P1 normalized by length of se=gment joining P1 and P2

%  alpha is:

%   < 0 when Q lies along the line before P1
%     0 when Q == V1
%     1 when Q == V2
%   > 1 when Q lies along the line beyond P2
    L12 = norm(P2-P1);
    v = (P2-P1)/L12;        % normalized vector from P1 to P2
    Q = dot(P-P1,v)*v+P1;               % projection of P onto line from P1 to P2
    dS = dot(Q-P1,v);                 % displacement from P1 to P
    alpha = dS/L12;  % fractional distance to cue along the line
end

