

% predetermined amounts to pad arrays by so as to align all data to a
% specific timepoint
pre = [42,66,118,67,104,51,25,32,106,33,64,98];
post = [212,52,0,51,152,67,93,86,130,180,54,243];

% data files should have the form 'basename1.tif', 'basename2.tif', etc,
% where basename can be whatever
embryoBaseName = 'e';

% mask files should have the form 'maskname1.tif', 'maskname2.tif', etc
maskBaseName = 'amask';

% number of embryo files in data set
numEmbryos = 12;

% total number of timepoints needed to represent thew entire data set
% (after pre- and post-padding data for individual embryos).
numTimePoints = 619;

% index within the padded data arrays that corresponds to the alignment
% timepoint
alignPoint = 210;

% number of frames to plot befoe the alignment timepoint
preFrames = 150;

% number of frames to plot after the alignment timepoint
postFrames = 150;


% time interval between frames (in seconds) in the data set
timeInterval = 3;


% set to 1 if you want to use actual mask area to measure density.  Set to
% 0 if you want to use the area of the smallest polygon that contains all
% detected features to measure density at each timepoint
useMaskAreaToMeasureDensity = 0;

% Use the GUI to determine this value
minPeakIntensity = 1200;

% Use the GUI to determine this value
integratedIntensityThreshold = 16000;

% size of Gaussian smoothing window
smoothingFactor = 40;

fMeans = zeros(numEmbryos,numTimePoints);
fDens = zeros(numEmbryos,numTimePoints);
pDens = zeros(numEmbryos,numTimePoints);

figure; hold;

for i = 1:numEmbryos
    in = readMultiFrameTiff([embryoBaseName num2str(i) '.tif']);
    mask = imread([maskBaseName num2str(i) '.tif']);
    [fAll, fMean, fDen, pDen, MT] = measureKFParticlesInMovie(in,mask,minPeakIntensity,integratedIntensityThreshold,3,2,useMaskAreaToMeasureDensity);
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

mean_all = mean(fMeans,1,'omitnan');
mean_all = smoothdata(mean_all,'gaussian',smoothingFactor);
std_all = std(fMeans,'omitnan');
nData = sum( ~isnan(fMeans),1);
std_all = std_all./sqrt(nData);

figure; hold;

plot(-timeInterval*preFrames:timeInterval:timeInterval*postFrames,mean_all(alignPoint-preFrames:alignPoint+postFrames));
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,mean_all(alignPoint-preFrames:5:alignPoint+postFrames) + std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,mean_all(alignPoint-preFrames:5:alignPoint+postFrames) - std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');

ylim([20000 90000]);   

fdens_all = mean(fDens,1,'omitnan');
fdens_all = smoothdata(fdens_all,'gaussian',smoothingFactor);
std_all = std(fDens,'omitnan');
nData = sum( ~isnan(fDens),1);
std_all = std_all./sqrt(nData);

figure; hold;

plot(-timeInterval*preFrames:timeInterval:timeInterval*postFrames,fdens_all(alignPoint-preFrames:alignPoint+postFrames));
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,fdens_all(alignPoint-preFrames:5:alignPoint+postFrames) + std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,fdens_all(alignPoint-preFrames:5:alignPoint+postFrames) - std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');

ylim([0 1200]);

pdens_all = mean(pDens,1,'omitnan');
pdens_all = smoothdata(pdens_all,'gaussian',smoothingFactor);
std_all = std(pDens,'omitnan');
nData = sum( ~isnan(pDens),1);
std_all = std_all./sqrt(nData);

figure; hold;

plot(-timeInterval*preFrames:timeInterval:timeInterval*postFrames,pdens_all(alignPoint-preFrames:alignPoint+postFrames));
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,pdens_all(alignPoint-preFrames:5:alignPoint+postFrames) + std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');
plot(-timeInterval*preFrames:5*timeInterval:timeInterval*postFrames,pdens_all(alignPoint-preFrames:5:alignPoint+postFrames) - std_all(alignPoint-preFrames:5:alignPoint+postFrames),'r.');

ylim([0 0.014]);





