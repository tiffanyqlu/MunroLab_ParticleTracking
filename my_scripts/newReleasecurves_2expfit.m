
    clear all;

    outputFolder = 'minT_4_tau_2';
    mkdir(outputFolder);
    workingDir = pwd; % set working directory to current directory  

    load('e_info.mat');
    load('e_trks.mat');

    % in case you forgot to set these wqhen you did the tracking
    info.frameRate = 1;
    info.pixelSize = 0.107;

    % cutoff for min track lifetime to consider when constructing decay
    % curves
    minT = 2;

    % time interval for short-term mobility
    tau = 2;

    % display release curves for individual embryos out to minimimum number of trajectories 
    minCnt = 1;

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

    %%%%%%%%%%%%%  PLOT DECAY CURVES FOR POOLED DATA %%%%%%%%%%%%%

    f = figure
    if numParameterVals > 1 
        for j = 1:numParameterVals    
            subplot(1,numParameterVals,j); hold;
            maxDecay = pooledDecay(j,minT);
            plot(minLT_series,log(pooledDecay(j,minT:maxLifetime)/maxDecay),'r');         
            ylim([-6 0]);
            xlim([0 5]);
        end
    else 
        hold;
        maxDecay = pooledDecays(minT);
        plot(minLT_series,log(pooledDecays(minT:maxLifetime)/maxDecay),'r');         
        ylim([-6 0]);
        xlim([0 50]);
    end
    saveas(f,[outputFolder '/decay_pooled.pdf']);

%%
    %%%%%%%%%%%%%  COMPUTE TWO_EXPONENTIAL FITS TO ANTERIOR AND POSTERIOR DECAY CURVES %%%%%%%%%%%%%

    modelfun = @(b,t)(b(1)*(b(2)*exp(-b(3)*t)+(1-b(2))*exp(-b(4)*t)));
    beta0 = [1;0.8;4;0.7];
    opts = statset('nlinfit');
    beta = zeros(numParameterVals,4);

    %%%%%%%%%%%%%  COMPUTE AND PLOT BASIC AND EXTRAPOLATED RECRUITMENT RATIOS %%%%%%%%%%%%%
    rec_ratio = zeros(numEmbryos,numParameterVals);
    rec_ratio_extrap = zeros(numEmbryos,numParameterVals);

    if numParameterVals > 1 
        for j = 1:numParameterVals   
    
            tl_slope = log(amean(j,minT)) - log(amean(j,minT+1));
            p_slope = log(pmean(j,minT)) - log(pmean(j,minT+1));
    
            for  i = 1:numEmbryos
                rec_ratio(i,j) = adecays(i,j,minT)/pdecays(i,j,minT);
                a_extrap = exp(log(adecays(i,j,minT)) + (minT-0.5)*tl_slope);
                p_extrap = exp(log(pdecays(i,j,minT)) + (minT-0.5)*p_slope);
                rec_ratio_extrap(i,j) = a_extrap/p_extrap;
            end
        end
    else 
        tl_slope = log(meanDecays(minT)) - log(meanDecays(minT+1));
        p_slope = log(pmean(minT)) - log(pmean(minT+1));

        for  i = 1:numEmbryos
            rec_ratio(i,j) = meanDecays(i,minT)/meanDecays(i,minT);
            a_extrap = adecays(i,minT)*exp((minT-0.5)*tl_slope);
            p_extrap = pdecays(i,minT)*exp((minT-0.5)*tl_slope);
            rec_ratio_extrap(i) = a_extrap/p_extrap;
        end
    end
    
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% then fit


    if numParameterVals > 1            
        for j = 1:numParameterVals    
            beta0(1) = pooledDecays(j,minT)*exp((minT-0.5)*tl_slope);
            beta(j,:) = nlinfit(minLT_series,pooledDecays(j,minT:maxLifetime),modelfun,beta0,opts);
        end
    else
        beta0(1) = pooledDecays(j,minT)*exp((minT-0.5)*tl_slope);
        beta = nlinfit(minLT_series,pooledDecays(j,minT:maxLifetime),modelfun,beta0,opts);
    end
%%
    %%%%%%%%%%%%%  PLOT TWO_EXPONENTIAL FITS TO ANTERIOR AND POSTERIOR DECAY CURVES %%%%%%%%%%%%% 
    %%%%%%%%%%%%%   OVERLAYING POOLED AND INDIVIDUAL DECAY CURVES   %%%%%%%%%%%%%

    if numParameterVals > 1            
        f = figure;

        for j = 1:numParameterVals    
            subplot(1,numParameterVals,j); hold;

            maxDecay = beta(j,1);

            plot(T_series,log(modelfun(beta(j,:),T_series)/maxDecay),'b');         
            plot(minLT_series,log(pooledDecays(j,minT:maxLifetime)/maxDecay),'g');         
    
            for i = 1:numEmbryos
                sFac = pooledDecays(j,minT)/maxDecay;
                plot((minT-0.5:1:last(i,j)-0.5)/info.frameRate,log(squeeze(decays(i,j,minT:last(i,j)))*sFac/decays(i,j,minT)),'r');
            end

            ylim([-6 0]);
            xlim([0 5]);
        end
    else
        figure; hold;

        maxDecay = beta(1);

        plot(T_series,log(modelfun(beta,T_series)/maxDecay),'b');         
        plot(minLT_series,log(pooledDecays(minT:maxLifetime)/maxDecay),'g');         

        for i = 1:numEmbryos                            
            sFac = pooledDecays(minT)/maxDecay;
            plot((minT-0.5:1:last(i,j)-0.5)/info.frameRate,log(squeeze(decays(i,j,minT:last(i,j)))*sFac/decays(i,j,minT)),'r');
        end

        ylim([-6 0]);
        xlim([0 5]);
    end

    saveas(f,[outputFolder '/two_exp_fits.pdf']);

%%
    %%%%%%%%%%%%%  COMPUTE AND PLOT RMSD DISTRIBUTIONS %%%%%%%%%%%%%

    lam_long = cell(numParameterVals,1);
    lam_short = cell(numParameterVals,1);
    lam_all = cell(numParameterVals,1);
    lam_first = cell(numParameterVals,1);
    lam_last = cell(numParameterVals,1);
    
    % Set up basic parameters for rmsd histogram display
    err = 0.04; % positional measurement error
    maxRMSD = 1.0;
    numBins = 100;
    binwidth = maxRMSD/numBins;
    binEdges = 0:binwidth:maxRMSD;
%%
    %%%%%%%%%%%%%  COMPUTE MONOMER AND OLIGOMER MSD DISTRIBUTIONS %%%%%%%%%%%%%
    effectiveD = 0.1;
    rmsd = sqrt(4*effectiveD*((tau)/info.frameRate));
    dxSample = abs(rmsd*randn(1,10000) + err*randn(1,10000) - err*randn(1,10000));
    dySample = abs(rmsd*randn(1,10000) + err*randn(1,10000) - err*randn(1,10000));
    RMSDSample = sqrt(dxSample.*dxSample + dySample.*dySample);


    %%%%% Replace this with apropriate path %%%%
    load('/Users/munroem/Dropbox/Lang_et_al_2024/Paper_Data/Figure 5/Figur5BDF/oligomers/oligomers.mat');
  
    olig = histcounts(sqrt(oligomerMSDs{1}),binEdges,'Normalization','probability');
    mon = histcounts(RMSDSample,binEdges,'Normalization','probability');


    %%%%%%%%%%%%%  COMPUTE AND PLOT MONOMER DISTRIBUTIONS FOR LONGEST TRAJECTORIES %%%%%%%%%%%%%
    MSDs = cell(numParameterVals,1);

    f = figure;
    for i = 1:numParameterVals
        MSDs{i} = [];
        for  j = 1:numEmbryos
            msd = getMSDatTAU(filterByLifetime(trks{j,i},longTrackThreshold),tau,info,0);   
            MSDs{i} = [MSDs{i} msd(msd>0)];
        end

        subplot(1,numParameterVals,i); hold;

        % compute linear least squares fit solution
        both = histcounts(sqrt(aMSDs{i}),binEdges,'Normalization','probability');
        lam_long{i} = -sum((olig - mon).*(mon - both))/sum((olig - mon).*(olig - mon));
        if lam_long{i} > 1
            lam_long{i} = 1;
        end

        fit = lam_long{i}*olig + (1-lam_long{i})*mon;
        histogram('BinEdges',binEdges,'BinCounts',both);
        histogram('BinEdges',binEdges,'BinCounts',fit,'DisplayStyle','stairs','EdgeColor','m','LineWidth',2);
        xlim([0,maxRMSD]);
        ylim([0 0.15]);
        
    end
    
    saveas(f,[outputFolder '/long_rmsd_fits.pdf']);

    %%%%%%%%%%%%%  COMPUTE AND PLOT MONOMER DISTRIBUTIONS FOR SHORTEST TRAJECTORIES %%%%%%%%%%%%%
    
    f = figure;
    for i = 1:numParameterVals
        MSDs{i} = [];
        for  j = 1:numEmbryos
            msd = getMSDatTAU(filterByLifetime(trks{j,i},minT,minT+1),tau,info,0);   
            MSDs{i} = [MSDs{i} msd(msd>0)];
        end

        subplot(1,numParameterVals,i); hold;

        % compute linear least squares fit solution
        both = histcounts(sqrt(aMSDs{i}),binEdges,'Normalization','probability');
        lam_long{i} = -sum((olig - mon).*(mon - both))/sum((olig - mon).*(olig - mon));
        if lam_long{i} > 1
            lam_long{i} = 1;
        end

        fit = lam_long{i}*olig + (1-lam_long{i})*mon;
        histogram('BinEdges',binEdges,'BinCounts',both);
        histogram('BinEdges',binEdges,'BinCounts',fit,'DisplayStyle','stairs','EdgeColor','m','LineWidth',2);
        xlim([0,maxRMSD]);
        ylim([0 0.15]);
        
    end

    saveas(f,[outputFolder '/short_rmsd_fits.pdf']);
    
    %%%%%%%%%%%%%  PLOT FITS TO ALL RMSDs %%%%%%%%%%%%%
    
    for i = 1:numParameterVals
        MSDs{i} = [];
        for  j = 1:numEmbryos
            msd = getMSDatTAU(filterByLifetime(trks{j,i},minT),tau,info,0);   
            MSDs{i} = [MSDs{i} msd(msd>0)];
        end

        subplot(1,numParameterVals,i); hold;

        % compute linear least squares fit solution
        both = histcounts(sqrt(aMSDs{i}),binEdges,'Normalization','probability');
        lam_long{i} = -sum((olig - mon).*(mon - both))/sum((olig - mon).*(olig - mon));
        if lam_long{i} > 1
            lam_long{i} = 1;
        end

        fit = lam_long{i}*olig + (1-lam_long{i})*mon;
        histogram('BinEdges',binEdges,'BinCounts',both);
        histogram('BinEdges',binEdges,'BinCounts',fit,'DisplayStyle','stairs','EdgeColor','m','LineWidth',2);
        xlim([0,maxRMSD]);
        ylim([0 0.15]);
        
    end


    saveas(f,[outputFolder '/all_rmsd_fits.pdf']);
    
    %%%%%%%%%%%%%  PLOT FITS TO FIRST RMSDs %%%%%%%%%%%%%
    for i = 1:numParameterVals
        MSDs{i} = [];
        for  j = 1:numEmbryos
            msd = getFirstMSDatTAU(filterByLifetime(trks{j,i},minT),tau,info,0);   
            MSDs{i} = [MSDs{i} msd(msd>0)];
        end

        subplot(1,numParameterVals,i); hold;

        % compute linear least squares fit solution
        both = histcounts(sqrt(aMSDs{i}),binEdges,'Normalization','probability');
        lam_long{i} = -sum((olig - mon).*(mon - both))/sum((olig - mon).*(olig - mon));
        if lam_long{i} > 1
            lam_long{i} = 1;
        end

        fit = lam_long{i}*olig + (1-lam_long{i})*mon;
        histogram('BinEdges',binEdges,'BinCounts',both);
        histogram('BinEdges',binEdges,'BinCounts',fit,'DisplayStyle','stairs','EdgeColor','m','LineWidth',2);
        xlim([0,maxRMSD]);
        ylim([0 0.15]);
        
    end

    saveas(f,[outputFolder '/first_rmsd_fits.pdf']);

    %%%%%%%%%%%%%  PLOT FITS TO LAST RMSDs %%%%%%%%%%%%%
    for i = 1:numParameterVals
        MSDs{i} = [];
        for  j = 1:numEmbryos
            msd = getLastMSDatTAU(filterByLifetime(trks{j,i},minT),tau,info,0);   
            MSDs{i} = [MSDs{i} msd(msd>0)];
        end

        subplot(1,numParameterVals,i); hold;

        % compute linear least squares fit solution
        both = histcounts(sqrt(aMSDs{i}),binEdges,'Normalization','probability');
        lam_long{i} = -sum((olig - mon).*(mon - both))/sum((olig - mon).*(olig - mon));
        if lam_long{i} > 1
            lam_long{i} = 1;
        end

        fit = lam_long{i}*olig + (1-lam_long{i})*mon;
        histogram('BinEdges',binEdges,'BinCounts',both);
        histogram('BinEdges',binEdges,'BinCounts',fit,'DisplayStyle','stairs','EdgeColor','m','LineWidth',2);
        xlim([0,maxRMSD]);
        ylim([0 0.15]);
        
    end
    
    saveas(f,[outputFolder '/last_rmsd_fits.pdf']);

    save([outputFolder '/decays.mat'],'decays');
    save([outputFolder '/lam_all.mat'],'lam_all');
    save([outputFolder '/lam_first.mat'],'lam_first');
    save([outputFolder '/lam_last.mat'],'lam_last');



