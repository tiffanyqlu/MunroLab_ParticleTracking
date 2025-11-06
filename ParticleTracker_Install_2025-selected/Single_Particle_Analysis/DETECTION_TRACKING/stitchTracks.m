function strks = stitchTracks(trks1,trks2,frm,gap)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

small = 1e-12;
if isempty(trks1)
    strks = trks2;
else
    frmT = frm + gap;

    % find trajectories that overlap the stitchpoint
    ends1 = find(([trks1.first] <= frmT) & ([trks1.last] >= frmT));
    ends2 = find(([trks2.first] <= frmT) & ([trks2.last] >= frmT));

    % find local index of stitchpint within each trajectory
    s1 = frmT-[trks1(ends1).first]+1;
    s2 = frmT-[trks2(ends2).first]+1;

    n1 = length(ends1);
    n2 = length(ends2);

    % find x and y positions of the stitchpoints
    x1 = zeros(1,n1);
    y1 = zeros(1,n1);
    x2 = zeros(1,n2);
    y2 = zeros(1,n2);
    for i = 1:n1
        x1(i) = trks1(ends1(i)).x(s1(i));
        y1(i) = trks1(ends1(i)).y(s1(i));
    end
    for i = 1:n2
        x2(i) = trks2(ends2(i)).x(s2(i));
        y2(i) = trks2(ends2(i)).y(s2(i));
    end

    % set up logical array to record unstitched trajectories
    unstitched = true(length(trks2),1);

    % find two trajectories that are very close at stitchpoint
    for i = 1:n1
        % find all points in trks2 that match stitchpoint x1(i),y1(i) in
        % trks1
        m = find((x1(i) - x2).^2 + (y1(i) - y2).^2 < small);
        if ~isempty(m)
            i1 = ends1(i);
            i2 = ends2(m);
            
            % stitch trks2(i2) onto trks1(i1)
            trks1(i1).last = trks2(i2).last;
            trks1(i1).lifetime = trks1(i1).last - trks1(i1).first + 1;
            trks1(i1).x = [trks1(i1).x(1:s1(i)) trks2(i2).x(s2(m)+1:end)];
            trks1(i1).y = [trks1(i1).y(1:s1(i)) trks2(i2).y(s2(m)+1:end)];
            trks1(i1).I = [trks1(i1).I(1:s1(i)) trks2(i2).I(s2(m)+1:end)];
            trks1(i1).fate = trks2(i2).fate;

            % mark trks2(i2) as stitched
            unstitched(i2) = false;
        end
    end

    strks = [trks1 trks2(unstitched)];
end