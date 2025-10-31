%% setup   
clear all;

    outputFolder = 'minT_4_tau_2';
    mkdir(outputFolder);
    workingDir = pwd; % set working directory to current directory  

    load('e_info.mat');
    load('e_trks.mat');

    % in case you forgot to set these when you did the tracking
    info.frameRate = 1;
    info.pixelSize = 0.107;

    %stream or timelapse?
    dr = '_tl.mat';

    % cutoff for min track lifetime to consider when constructing decay
    % curves
    minT = 4;

    % time interval for short-term mobility
    tau = 2;

    % display release curves for individual embryos out to minimimum number of trajectories 
    minCnt = 10;

    % threshold lifetime that defines "long tracks" for rmsd analysis

    numEmbryos = size(trks,1);
    numParameterVals = size(trks,2);

    % find max trajectory lifetime
    maxLifetime = 1;
    for i = 1:numEmbryos
        for j = 1:numParameterVals
            maxLifetime = max(maxLifetime, max([trks{i,j}.lifetime]));
        end
    end

    % set up time vectors for plotting decay curves
    minLT_series = (minT-0.5:1:maxLifetime-0.5)/info.frameRate;
    LT_series = (0.5:1:maxLifetime-0.5)/info.frameRate;
    T_series = (0:maxLifetime)/info.frameRate;

%% plot decay curves
%%%%%%%%%%%%%  COMPUTE INDIVIDUAL AND POOLED ANTERIOR AND POSTERIOR DECAY CURVES %%%%%%%%%%%%%

    decays = nan(numEmbryos,numParameterVals,maxLifetime);

    last = zeros(numEmbryos,numParameterVals);

    allTrks = cell(numParameterVals,1);

    pooledDecays = zeros(numParameterVals,maxLifetime);

    for j = 1:numParameterVals            
        for  i = 1:numEmbryos
            decays(i,j,:) = decay(filterByFirstAndLast(trks{i,j},2,10000),info,maxLifetime);
            last(i,j) = find(decays(i,j,:) > minCnt,1,'last');
            allTrks{j} = [allTrks{j} trks{i,j}];
            
        end

        % compute decay curves from pooled data, normalized by total roi area
        pooledDecays(j,:) = decay(filterByFirstAndLast(allTrks{j},2,10000),info,maxLifetime);
    end

%%%%%%%%%%%%%  PLOT INDIVIDUAL DECAY CURVES %%%%%%%%%%%%%

    f = figure;
    for j = 1:numParameterVals            
        subplot(1,numParameterVals,j); hold;
        for  i = 1:numEmbryos
            maxDecay = decays(i,j,minT);
            plot((minT-0.5:1:last(i,j)-0.5)/info.frameRate,log(squeeze(decays(i,j,minT:last(i,j)))/maxDecay),'r');
            ylim([-6 0]);
            xlim([0 50]);
        end
    end
    saveas(f,[outputFolder '/decay_ind.pdf']);

%%%%%%%%%%%%%  PLOT MEAN DECAY CURVES %%%%%%%%%%%%%


    meanDecays = squeeze(sum(decays,1,'omitnan'));

    f = figure
    if numParameterVals > 1 
        for j = 1:numParameterVals    
            subplot(1,numParameterVals,j); hold;
            maxDecay = meanDecays(j,minT);
            plot(minLT_series,log(meanDecays(j,minT:maxLifetime)/maxDecay),'r');         
            ylim([-6 0]);
            xlim([0 5]);
        end
    else 
        hold;
        maxDecay = meanDecays(minT);
        plot(minLT_series,log(meanDecays(minT:maxLifetime)/maxDecay),'r');         
        ylim([-6 0]);
        xlim([0 50]);
    end
    saveas(f,[outputFolder '/mean_decay.pdf']);
%%
    %%%%%%%%%%%%%  PLOT DECAY CURVES FOR POOLED DATA %%%%%%%%%%%%%

    f = figure;
    if numParameterVals > 1 
        for j = 1:numParameterVals    
            subplot(1,numParameterVals,j); hold;
            maxDecay = pooledDecays(j,minT);
            plot(minLT_series,log(pooledDecays(j,minT:maxLifetime)/maxDecay),'r');         
            ylim([-6 0]);
            xlim([0 5]);
        end
    else 
        hold;
        maxDecay = pooledDecays(minT);
        plot(minLT_series,log(pooledDecays(minT:maxLifetime)/maxDecay),'r');         
        ylim([-6 0]);
        %xlim([0 3]);
    end
 saveas(f,[outputFolder '/decay_pooled.pdf']);
%%
    %%%%%%%%%%%%%  COMPUTE SLOPES %%%%%%%%%%%%%
  if numParameterVals > 1 
    a_slope = zeros(numParameterVals,1);
    a_extrap = zeros(numParameterVals,1);
    for j = 1:numParameterVals   
        a_slope(j) = log(meanDecays(j,minT)) - log(meanDecays(j,minT+1));

        for  i = 1:numParameterVals
            a_extrap(i) = pooledDecays(i,minT) * exp((minT-0.5) * a_slope(j));
        end

    end
  else 
    a_slope = log(meanDecays(minT)) - log(meanDecays(minT+1));

    for  i = 1:numEmbryos
        a_extrap = pooledDecays(minT) * exp((minT-0.5) * a_slope);
    end
  end
%% %%%%%%%%%%%%%  COMPUTE TWO_EXPONENTIAL FITS TO ANTERIOR AND POSTERIOR DECAY CURVES %%%%%%%%%%%%%

modelfun = @(b,t)(b(1)*(b(2)*exp(-b(3)*t)+(1-b(2))*exp(-b(4)*t)));
beta0 = [max(pooledDecays(:)); 0.5; 1; 0.5];
opts = statset('nlinfit');
beta = zeros(numParameterVals,4);

y = pooledDecays(j,minT:maxLifetime);
x = minLT_series;

validIdx = isfinite(x) & isfinite(y) & y > 0; % removes 0s from the data you're fitting (I think this is okay to do
                                              % but will check with Ed
x = x(validIdx);
y = y(validIdx);
beta(j,:) = nlinfit(x, y, modelfun, beta0, opts);
    
        if numParameterVals > 1            
            for j = 1:numParameterVals    
                beta0(1) = pooledDecays(j,minT)*exp((minT-0.5)*a_slope(j));
                beta(j,:) = nlinfit(minLT_series,pooledDecays(j,minT:maxLifetime),modelfun,beta0,opts);
            end
        else
            beta0(1) = pooledDecays(j,minT)*exp((minT-0.5)*a_slope);
            beta = nlinfit(minLT_series,pooledDecays(j,minT:maxLifetime),modelfun,beta0,opts);
        end


fullname = strcat('beta', dr);
save(fullname,"beta");

%% plot fits and decay curves
    %%%%%%%%%%%%%  PLOT TWO_EXPONENTIAL FITS TO ANTERIOR AND POSTERIOR DECAY CURVES %%%%%%%%%%%%% 
    %%%%%%%%%%%%%   OVERLAYING POOLED AND INDIVIDUAL DECAY CURVES   %%%%%%%%%%%%%

    if numParameterVals > 1            
        f = figure;

        for j = 1:numParameterVals    
            subplot(1,numParameterVals,j); hold;

            maxDecay = beta(j,1);

            plot(T_series,log(modelfun(beta(j,:),T_series)/maxDecay),'color',[0.4940 0.1840 0.5560 0.5]);         
            plot(minLT_series,log(pooledDecays(j,minT:maxLifetime)/maxDecay),'color',[0.4660 0.6740 0.1880 0.5]);         
    
            for i = 1:numEmbryos
                sFac = pooledDecays(j,minT)/maxDecay;
                plot((minT-0.5:1:last(i,j)-0.5)/info.frameRate,log(squeeze(decays(i,j,minT:last(i,j)))*sFac/decays(i,j,minT)),'r');
            end

            ylim([-6 0]);
            xlim([0 5]);
        end
    
    else
        f = figure; 
        hold;

        maxDecay = beta(1);
        
        for i = 1:numEmbryos                            
            sFac = pooledDecays(minT)/maxDecay;
            plot((minT-0.5:1:last(i,j)-0.5)/info.frameRate,log(squeeze(decays(i,j,minT:last(i,j)))*sFac/decays(i,j,minT)), ...
                'color',[0.3010 0.7450 0.9330 0.5]);
        end
       
        plot(T_series,log(modelfun(beta,T_series)/maxDecay),'LineWidth',2,'color','m');         
        plot(minLT_series,log(pooledDecays(minT:maxLifetime)/maxDecay),'LineWidth',2,'color',[0.4660 0.6740 0.1880 0.9]);         
        ylim([-6 0]);
        %xlim([0 50]);
    end
     saveas(f,[outputFolder '/two_exp_fits_plusindcurves.pdf']);

% plot curves without individual decay curves
    f = figure; 
    hold;
    maxDecay = beta(1);
    plot(T_series,log(modelfun(beta,T_series)/maxDecay),'LineWidth',2,'color','m');         
    plot(minLT_series,log(pooledDecays(minT:maxLifetime)/maxDecay),'LineWidth',2,'color',[0.4660 0.6740 0.1880 0.9]);         
    ylim([-6 0]);
    %xlim([0 4]);
    saveas(f,[outputFolder '/two_exp_fits.pdf']);

%% calculate rates from timelapse and streaming data
beta_tl = load("beta_tl.mat"); 
beta_tl = beta_tl.beta;
beta_stream = load("beta_stream.mat")
beta_stream = beta_stream.beta;

%%%%% solve system of equations to get dissociation and photobleaching rates
% k_d + k_pb == beta_stream(4,1);
% k_d + 0.05*k_pb == beta_tl(4,1);

A = [1 1 ; 0.05 1]; 
b = [beta_stream(4,1) ; beta_tl(4,1)];
rates = A\b;

clear A b;
