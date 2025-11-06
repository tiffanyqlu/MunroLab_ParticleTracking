function s = makeRSQDMask(w,h)
% produce a parabolic mask
% if n_params() eq 1 then h = w
s = zeros(w,h);
xc = (w-1)/2;
yc = (h-1)/2;
x = [-xc:xc];
x = x.^2;
y = [-yc:yc];
y = y.^2;

for j = 1:h
	s(:,j) = x' + y(j);
end
