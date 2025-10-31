
    clear all;
    workingDir = pwd;                   % set working directory to current directory  
    dirList = getDirectoryList('e');   % get list of sub-directories with names "e1", "e2", etc   

    load('e_info.mat');
    load('e_trks.mat');

    minT = 4;
    tau = 2;
    info.frameRate = 20;
    info.pixelSize = 0.1;

    numEmbryos = size(trks,1);
    numParameterVals = size(trks,2);

    maxLifetime = 1;
    maxNumTrajectories = 1;
    for i = 1:numEmbryos
        for j = 1:numParameterVals
            maxLifetime = max(maxLifetime, max([trks{i,j}.lifetime]));
            maxNumTrajectories = max(maxNumTrajectories, length(trks{i,j}));
        end
    end

    oligomerMSDs = cell(numParameterVals,1);
    for j = 1:numParameterVals    
        oligomerMSDs{j} = [];
        for  i = 1:numEmbryos
            msd = getMSDatTAU(filterByLifetime(trks{j,i},minT),tau,info,0);   
            oligomerMSDs{j} = [oligomerMSDs{j} msd(msd>0)];
        end
    end

    save('oligomers','oligomerMSDs');



