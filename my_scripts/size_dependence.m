%% open files, etc.
trks = load('X:\analysis\sizedepdis\2.2025\e_trks.mat');
eNum = size(trks.trks);
eNum = eNum(1,1); %number of embryos
%% get single molecule intensity
basepath = ('X:\analysis\sizedepdis\2.2025\sm\');
filebase = ('_featureStats.csv');

sm_data = table();
for i = 1:3 %fix this when you do for real
    embryo = (['e', num2str(i)]);
    data = readtable([basepath,embryo,filebase]);
    sm_data = vertcat(data, sm_data);
end 

sm_data = table2array(sm_data);
fit = fitdist(sm_data(:,3),'Normal');
sm_int = mean(fit);

%% filter out particles present in relevant frame for each embryo (switch to 1 for all if needed)
fr1_prts = struct();
%cyto = [117,5,67,39,60,60];

for j = 1:eNum
    fieldName = strcat("e", num2str(j));
    index = [trks.trks{j,1}.first] == 1;
    x = trks.trks{j,1}(index);
    fr1_prts.(fieldName)= x;
end
%% get the initial intensities for each particle
fields = fieldnames(fr1_prts);
for k = 1:length(fields)
    embryo = fields{k}; 
    nRows = size(fr1_prts.(embryo)); 
    nRows = nRows(1,2);
    t0_Intensity = zeros(1,nRows);

    for n = 1:nRows
        t0_Intensity(n)=fr1_prts.(embryo)(n).I(1,1);
        t0_Intensity = t0_Intensity';
    end

    if length(fr1_prts.(embryo)) == length(t0_Intensity)
        for m = 1:length(fr1_prts.(embryo))
            fr1_prts.(embryo)(m).initial_int = t0_Intensity(m);
        end
    else
        error('The double array and structure array must have the same length. :-(');
    end
end
%% classify initial intensities by number of molecules
for k = 1:length(fields)
    embryo = fields{k}; 

    nRows = size(fr1_prts.(embryo)); 
    nRows = nRows(1,2);

    sizes = []; 
    for n = 1:nRows
        sizes(n) = fr1_prts.(embryo)(n).initial_int; 
    end
    sizes = sizes';
    sizes = sizes*(1/sm_int);
    max_size = max(sizes);
    max_size = ceil(max_size);
    bin_edges = 0:1:max_size;

    [N, edges, bin_indices] = histcounts(sizes, bin_edges);

    if length(fr1_prts.(embryo)) == length(bin_indices)
        for m = 1:length(fr1_prts.(embryo))
            fr1_prts.(embryo)(m).clst_bin = bin_indices(m);
        end
    else
        error('The double array and structure array must have the same length. :-(');
    end
end
%% filtering out particles still present after x time
fr1_prts_filt = struct();
tf = 20; %%% time interval of interest

for m = 1:length(fields)
    embryo = fields{m};
    fieldName = strcat("e", num2str(m));
    index = [fr1_prts.(embryo).last] == tf; 
    index = index';
    x = fr1_prts.(embryo)(index);
    fr1_prts_filt.(fieldName) = x;
end

%% count number of particles of each class present initially and at time of interest
initialbins = zeros(1);
for m = 1:eNum
    embryo = fields{m};
    bins = {fr1_prts.(embryo)(:).clst_bin};
    initialbins = horzcat(initialbins, bins);
end
initialbins(:,1) = []; % remove the 0
initialbins = initialbins';

finalbins = zeros(1);
for m = 1:eNum
    embryo = fields{m};
    bins = {fr1_prts_filt.(embryo)(:).clst_bin};
    finalbins = horzcat(finalbins, bins);
end
finalbins(:,1) = []; % remove the 0
finalbins = finalbins';
%% estimate dissociation rate constant
initialbins = cell2mat(initialbins);
pSizes = unique(initialbins);
counts = histc(initialbins,pSizes);
bincounts = horzcat(pSizes, counts);

finalbins = cell2mat(finalbins);
counts = histc(finalbins, pSizes);
counts(1)=categorical(counts(1));
bincounts = horzcat(bincounts, counts);

rates = zeros(length(bincounts),1);
for i = 1:length(bincounts)
    a = -log(bincounts(i,3)/bincounts(i,2));
    rates(i,1) = a;
end

final = horzcat(bincounts,rates);
columnLabels = {'cluster size','initial count','final count', 'dissociation rate constant'};
final= array2table(final, 'VariableNames', columnLabels);
 
