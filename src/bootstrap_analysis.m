function result = bootstrap_analysis(x, statisticFunction, nBootstrap, seed)
% BOOTSTRAP_ANALYSIS
% Non-parametric bootstrap confidence interval for a statistic.
%
% Inputs:
%   x                  - input data
%   statisticFunction  - function handle returning the statistic
%   nBootstrap         - number of bootstrap resamples
%   seed               - random seed
%
% Output:
%   result             - bootstrap statistic and confidence interval

rng(seed, 'twister');

x = x(:);

x = x(isfinite(x));

n = numel(x);

if n < 2
    error('At least two observations are required.');
end

if nBootstrap < 100
    warning('A larger number of bootstrap samples is generally preferable.');
end

% Observed statistic
observedStatistic = statisticFunction(x);

% Bootstrap distribution
bootstrapStatistics = zeros(nBootstrap,1);

for b = 1:nBootstrap

    indices = randi(n,n,1);

    xBootstrap = x(indices);

    bootstrapStatistics(b) = ...
        statisticFunction(xBootstrap);

end

% Percentile confidence interval
lowerCI = prctile(bootstrapStatistics,2.5);
upperCI = prctile(bootstrapStatistics,97.5);

result.ObservedStatistic = observedStatistic;
result.BootstrapStatistics = bootstrapStatistics;
result.Lower95CI = lowerCI;
result.Upper95CI = upperCI;
result.NumberOfBootstrapSamples = nBootstrap;
result.Seed = seed;

end
