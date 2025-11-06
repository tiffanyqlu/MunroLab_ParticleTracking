function [arcLengths] = getArclengths(traj)
%getArclengths Compute and return arcLength for each position along the
%curve specified by traj


len = length(traj);
arcLengths = zeros(1,len);
s = 0;
arcLengths(1) = 0;

    for i = 2:len
        s = s + norm(traj(:,i) - traj(:,i-1));
        arcLengths(i) = s;
    end

end

