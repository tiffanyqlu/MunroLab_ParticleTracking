trks = load('X:\analysis\partial photobleach analysis\9.27.24\e_trks.mat');
eNum = size(trks.trks);
eNum = eNum(1,1); % number of embryos
%% %% filtering out particles present in frame 1 that persist to recovery
trks_filt = struct();

for m = 1:eNum
    index = [trks.trks{m,1}.first] == 1;
    index = index';
    x = trks.trks{m,1}(index);
    trks_filt.trks.trks{m,1} = x;    
end

for m = 1:eNum
    index = [trks_filt.trks.trks{m,1}.last] >= 21;
    index = index';
    x = trks_filt.trks.trks{m,1}(index);
    trks_filt.trks.trks{m,1} = x;    
end

nParticles = size(index);
nParticles = nParticles(1);
%% get initial intensities 

particles = trks_filt.trks.trks;
initial_int = zeros(nParticles, 0);

for q = 1:eNum
    m=length(particles{q,1});
    for m = 1:m
        initial = particles{q,1}(m).I(1);
        initial_int = [initial_int;initial];
    end
end

nParticles = size(initial_int);
nParticles = nParticles(1);