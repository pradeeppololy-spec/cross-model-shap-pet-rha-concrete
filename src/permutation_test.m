function result = permutation_test(x, y, nPermutations, seed)
% PERMUTATION_TEST
% Permutation test for the association between two variables.
%
% Inputs:
%   x             - first variable/ranking
%   y             - second variable/ranking
%   nPermutations - number of random permutations
%   seed          - random seed
%
% Output:
%   result        - structure containing observed statistic and p-value

rng(seed, 'twister');

x = x(:);
y = y(:);

if numel(x) ~= numel(y)
    error('x and y must contain the same number of observations.');
end

valid = isfinite(x) & isfinite(y);

x = x(valid);
y = y(valid);

if numel(x) < 3
    error('At least three valid observations are required.');
end

% Observed Spearman correlation
observedRho = corr(x, y, ...
    'Type', 'Spearman', ...
    'Rows', 'complete');

permutedRho = zeros(nPermutations,1);

for k = 1:nPermutations

    yPerm = y(randperm(numel(y)));

    permutedRho(k) = corr(x, yPerm, ...
        'Type', 'Spearman', ...
        'Rows', 'complete');

end

% Two-sided permutation p-value
pValue = (1 + sum(abs(permutedRho) >= abs(observedRho))) ...
    / (nPermutations + 1);

result.ObservedRho = observedRho;
result.PermutationRho = permutedRho;
result.PValue = pValue;
result.NumberOfPermutations = nPermutations;
result.Seed = seed;

end
