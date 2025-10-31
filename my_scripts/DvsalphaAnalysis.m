%% setup
clear all;
outputFolder = 'plots';
mkdir(outputFolder);
workingDir = pwd; %set wd to current
trks = load('e_trks.mat');
eNum = size(trks.trks);
eNum = eNum(1,1); % number of embryos
movieInfo = load('e_info.mat'); movieInfo = movieInfo.info;
maxTau = 10;

%% filter tracks with desired lifetime, fit to get D and alpha 
trks_filt = struct();
minLifetime = 5; 

for m = 1:eNum
    index = [trks.trks{m,1}.lifetime] >= minLifetime;
    index = index';
    x = trks.trks{m,1}(index);
    trks_filt.trks.trks{m,1} = x;    
end

trks_filt = trks_filt.trks.trks{1,1}; 

[D,Alpha] = getDAlpha(trks_filt,maxTau,movieInfo);

%% get track lengths for simulation
lifetimes = zeros(1,length(trks_filt));
for i = 1:length(trks_filt)
    lifetimes(i) = trks_filt(i).lifetime;
end
writematrix(lifetimes, 'lifetimes.csv');
%% plot
%DvsAlpha = load("fits.mat"); -- if you want to plot the simulated data on the same plot

f = figure; 
hold on;
scatter(Alpha, D, 25, 'filled');
%if you want to plot the simulated data on the same plot
%scatter(DvsAlpha.fits(:,2), DvsAlpha.fits(:,1), 'MarkerEdgeColor', '#c3c4c4'); 
xlabel('α');
ylabel('diffusion coefficient (μm^2/s)');
xlim([0 1.3]);
ylim([0 0.6]);
set(findall(gcf,'-property','FontSize'),'FontSize',16);
title('measured');


saveas(f,[pwd, '/DvsAlphaMeasured_clusters.svg']);
