%% export release curves - change for timelapse/stream
trks = load('X:\analysis\releasecurves_pilot\10.23.24\timelapse\e_trks.mat');
trks = trks.trks
info = load('X:\analysis\releasecurves_pilot\10.23.24\timelapse\e_info.mat');
info = info.info
exportReleaseCurves(trks,info)
%% load files
tl_release = load('X:\analysis\releasecurves_pilot\M1_timelapse.txt');
stream_release = load('X:\analysis\releasecurves_pilot\M1_stream.txt');
%% sum across all embryos, normalize
tl_data = tl_release(:, 2:2:end);
tl_sum = sum(tl_data, 2);
tl_sum = tl_sum/(tl_sum(1,1));

tl_times = tl_release(:,1);
tl_pooled = [tl_times,tl_sum];

stream_data = stream_release(:, 2:2:end);
stream_sum = sum(stream_data,2);
stream_sum = stream_sum/(stream_sum(1,1));

s_times = stream_release(:,1);
stream_pooled = [s_times,stream_sum];
%% plot on log scale to find linear portion
figure;
log_tl = tl_pooled;
log_tl(:,2) = log(tl_pooled(:,2));
plot(log_tl(:,1), log_tl(:,2));

hold on

log_stream = stream_pooled;
log_stream(:,2) = log(stream_pooled(:,2));
plot(log_stream(:,1), log_stream(:,2));
% xlim([0 40]);
% ylim([-7 0]);
xlabel("time (s)");
ylabel("log(# tracks)");

hold off
%% subset - exclude first part (estimate cutoff)
tl_pooled = tl_pooled(tl_pooled(:,1)>3, :);
stream_pooled = stream_pooled(stream_pooled(:,1)>0.1, :);
%% fit exponential
figure;
tl_fit = fit(tl_pooled(:,1),tl_pooled(:,2),'exp1');
plot(tl_fit,tl_pooled(:,1),tl_pooled(:,2))
title("timelapse");
hold off

figure;
stream_fit = fit(stream_pooled(:,1),stream_pooled(:,2),'exp1');
plot(stream_fit,stream_pooled(:,1),stream_pooled(:,2))
title("stream");
hold off
%% plot data and fit together on log scale
figure;
a =      0.7165;
b =     -0.2533;
plot(tl_pooled(:,1),log(a*exp(b*tl_pooled(:,1))))
hold on
plot(tl_pooled(:,1), log(tl_pooled(:,2)))
ylim([-5 0]);
xlim([0 20]);