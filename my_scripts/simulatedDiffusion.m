%% simulate monomers
% parameters, initialize
clear all;
nParticles = 1000;
nSteps = 100;
dt = 0.05; % time step size, in seconds 
D = 0.15; % diffusion coefficient (um^2/s)
stepSize = sqrt(2*D*dt);
x = zeros(nParticles, nSteps);
y = zeros(nParticles, nSteps);

% simulate Brownian motion, compute MSDs after lag times
for t = 2:nSteps
    x(:, t) = x(:, t-1) + stepSize * randn(nParticles, 1);
    y(:, t) = y(:, t-1) + stepSize * randn(nParticles, 1);
end

