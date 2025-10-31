cd 'X:\analysis\clst_trk\analysis_1.2025'
% predetermined amounts to pad arrays by so as to align all data to a
% specific timepoint
pre = [95,0,104,104,85,60];
post = [69,57,103,155,0,65];

% data files should have the form 'basename1.tif', 'basename2.tif', etc,
% where basename can be whatever
embryoBaseName = 'e';

% mask files should have the form 'maskname1.tif', 'maskname2.tif', etc
maskBaseName = 'mask';

% number of embryo files in data set
numEmbryos = 6;

% total number of timepoints needed to represent the entire data set
% (after pre- and post-padding data for individual embryos).
numTimePoints = 825;

% index within the padded data arrays that corresponds to the alignment
% timepoint
alignPoint = 105;

% number of frames to plot befoe the alignment timepoint
preFrames = 0;

% number of frames to plot after the alignment timepoint
postFrames = 600;


% time interval between frames (in seconds) in the data set
timeInterval = 2;


% set to 1 if you want to use actual mask area to measure density.  Set to
% 0 if you want to use the area of the smallest polygon that contains all
% detected features to measure density at each timepoint
useMaskAreaToMeasureDensity = 0;

% Use the GUI to determine this value
minPeakIntensity = 300;

% Use the GUI to determine this value
integratedIntensityThreshold = 4500;

% size of Gaussian smoothing window
smoothingFactor = 40;

fMeans = zeros(numEmbryos,numTimePoints);
fDens = zeros(numEmbryos,numTimePoints);
pDens = zeros(numEmbryos,numTimePoints);

%% figure 1: raw traces of mean cluster intensity for each embryo
figure; hold;
title('mean cluster intensity')
for i = 1:numEmbryos
    in = readMultiFrameTiff([embryoBaseName num2str(i) '.tif']);
    mask = imread([maskBaseName num2str(i) '.tif']);
    [fMean, fDen, pDen, MT] = measureKFParticlesInMovie(in,mask,minPeakIntensity,integratedIntensityThreshold,3,2,useMaskAreaToMeasureDensity);
    fMean = padarray(fMean,[0 pre(i)],nan,'pre');
    fMean = padarray(fMean,[0 post(i)],nan,'post');
    fDen = padarray(fDen,[0 pre(i)],nan,'pre');
    fDen = padarray(fDen,[0 post(i)],nan,'post');
    pDen = padarray(pDen,[0 pre(i)],nan,'pre');
    pDen = padarray(pDen,[0 post(i)],nan,'post');
    fMeans(i,1:length(fMean)) = fMean;
    fDens(i,1:length(fDen)) = fDen;
    pDens(i,1:length(pDen)) = pDen;
    plot(1:timeInterval:timeInterval*numTimePoints,fMean);
end

%% save and load again to make plotting faster next time
%  csvwrite('fDens.csv', fDens);
%  csvwrite('fMeans.csv',fMeans);

%% figure 2: mean cluster intensity
mean_all = mean(fMeans,1,'omitnan');
mean_all = smoothdata(mean_all,'gaussian',smoothingFactor);
std_all = std(fMeans,'omitnan');    
nData = sum( ~isnan(fMeans),1);
std_all = std_all./sqrt(nData);

figure; hold;
title('mean cluster intensity')
plot(-timeInterval*preFrames:timeInterval:timeInterval*postFrames,mean_all(alignPoint-preFrames:alignPoint+postFrames));
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,mean_all(alignPoint-preFrames:5:alignPoint+postFrames) + std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,mean_all(alignPoint-preFrames:5:alignPoint+postFrames) - std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');

%ylim([10000 30000]);   
bands = [260 355];    % X-Coordinates Of Band Limits: [x(1,1) x(1,2); x(2,1) x(2,2)]
hold on
xp = [bands fliplr(bands)];                                                         % X-Coordinate Band Definitions 
yp = ([[1;1]*min(ylim); [1;1]*max(ylim)]*ones(1,size(bands,1))).';                  % Y-Coordinate Band Definitions
for k = 1:size(bands,1)                                                             % Plot Bands
    patch(xp(k,:), yp(k,:), [1 1 1]*0.25, 'FaceAlpha',0.2, 'EdgeColor','none')
end
hold off
%% figure 3: overall fluorescence density
fdens_all = mean(fDens,1,'omitnan')
fdens_all = smoothdata(fdens_all,'gaussian',smoothingFactor);
std_all = std(fDens,'omitnan');
nData = sum( ~isnan(fDens),1);
std_all = std_all./sqrt(nData);

figure; hold;
title('overall density')
plot(-timeInterval*preFrames:timeInterval:timeInterval*postFrames,fdens_all(alignPoint-preFrames:alignPoint+postFrames));
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,fdens_all(alignPoint-preFrames:5:alignPoint+postFrames) + std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,fdens_all(alignPoint-preFrames:5:alignPoint+postFrames) - std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');
bands = [260 355];    % X-Coordinates Of Band Limits: [x(1,1) x(1,2); x(2,1) x(2,2)]
hold on
xp = [bands fliplr(bands)];                                                         % X-Coordinate Band Definitions 
yp = ([[1;1]*min(ylim); [1;1]*max(ylim)]*ones(1,size(bands,1))).';                  % Y-Coordinate Band Definitions
for k = 1:size(bands,1)                                                             % Plot Bands
    patch(xp(k,:), yp(k,:), [1 1 1]*0.25, 'FaceAlpha',0.2, 'EdgeColor','none')
end
hold off
%ylim([0 200]);

%% figure 4: cluster density
pdens_all = mean(pDens,1,'omitnan');
pdens_all = smoothdata(pdens_all,'gaussian',smoothingFactor);
std_all = std(pDens,'omitnan');
nData = sum( ~isnan(pDens),1);
std_all = std_all./sqrt(nData);

figure; hold;
title('cluster density')
plot(-timeInterval*preFrames:timeInterval:timeInterval*postFrames,pdens_all(alignPoint-preFrames:alignPoint+postFrames));
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,pdens_all(alignPoint-preFrames:5:alignPoint+postFrames) + std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,pdens_all(alignPoint-preFrames:5:alignPoint+postFrames) - std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');

bands = [260 355];    % X-Coordinates Of Band Limits: [x(1,1) x(1,2); x(2,1) x(2,2)]
hold on
xp = [bands fliplr(bands)];                                                         % X-Coordinate Band Definitions 
yp = ([[1;1]*min(ylim); [1;1]*max(ylim)]*ones(1,size(bands,1))).';                  % Y-Coordinate Band Definitions
for k = 1:size(bands,1)                                                             % Plot Bands
    patch(xp(k,:), yp(k,:), [1 1 1]*0.25, 'FaceAlpha',0.2, 'EdgeColor','none')
end
hold off
ylim([0.0075 0.0125]);



