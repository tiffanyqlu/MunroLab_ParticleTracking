function rmsds = sampleRMSD(tau,numSamples,D,err)
%sampleRMSD create a random sample of root mean square displacements after timnelag tau for 
% molecules that are assumed to undergo brownian duffusion with diffusivity D, where err 
% defines the localization error modelled as a gaussian with std = err;



%  Inputs

% tau  -            time lag
% numSamples -      number of sampled rmsds
% D -               diffusivity
% err  -            standard deviation of the localization error
% 

% Outputs

% rmsds - an array of sampled rmsds

    rmsd = sqrt(4*D*tau);
    xSample = rmsd*randn(1,numSamples) + err*randn(1,numSamples);
    ySample = rmsd*randn(1,numSamples) + err*randn(1,numSamples);
    rmsds= sqrt(xSample.*xSample + ySample.*ySample);
end