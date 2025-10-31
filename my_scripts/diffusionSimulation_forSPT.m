%% setup
clear all;

nParticles = 299;
frameInterval = 0.05;  % 20 ms in seconds
maxLag = 25;

% diffusivity range
D = 0.15; % μm^2/s
D_range = 0.05;
D_all = D + D_range * (2*rand(1000, 1)- 1); % randomly generate values 

% get track lengths from actual data 
trackLengths = load("lifetimes.csv");
trackLengths = trackLengths';

% % random track lengths (replace with actual later)
% rng(1); 
% trackLengths = randi([30, 200], numParticles, 1);

% storage for results
alphas = zeros(1, numParticles); 
D_fit = zeros(1,numParticles);

%% simulate, fit to get D and alpha
% parameters, initialize
clear all;
nSteps = 100;
dt = 0.05; % time step size, in seconds 
D = 0.15; % diffusion coefficient (um^2/s)
stepSize = sqrt(2*D*dt);
x = zeros(nParticles, nSteps);
y = zeros(nParticles, nSteps);

% simulate Brownian motion, compute RMSD after total time
for t = 2:nSteps
    x(:, t) = x(:, t-1) + stepSize * randn(nParticles, 1);
    y(:, t) = y(:, t-1) + stepSize * randn(nParticles, 1);
end
% generate trajectories
for i = 1:numParticles
    D_rand = D_all(randi(1000)); % pick a random D value
    N = trackLengths(i);
    steps = sqrt(2*D_rand*frameInterval)*randn(N,2);
    traj = cumsum(steps);

    msd = zeros(maxLag, 1); % compute MSDs
    for lag = 1:maxLag
        displacements = traj(1+lag:end, :) - traj(1:end-lag, :);
        squaredDisp = sum(displacements.^2, 2);
        msd(lag) = mean(squaredDisp);
    end

    % Fit MSDs to get D and alpha
    tau = (1:maxLag)' * frameInterval;
    log_tau = log(tau); log_msd = log(msd);

    coeffs = polyfit(log_tau, log_msd, 1);
    alphas(i) = coeffs(1);
    D_fit(i) = exp(coeffs(2)) / 4;
end 

%% plot
f = figure; 
hold on;
scatter(alphas, D_fit, 25, 'filled');
xlabel('α');
ylabel('diffusion coefficient (μm^2/s)');
xlim([0 1.3]);
ylim([0 0.6]);
set(findall(gcf,'-property','FontSize'),'FontSize',16);
title('simulated')

%saveas(f,[pwd, '/DvsAlphaSimulated.svg']);
