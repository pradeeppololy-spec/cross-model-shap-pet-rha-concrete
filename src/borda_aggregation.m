function [equalScore, weightedScore] = borda_aggregation(rankings, weights)
% BORDA_AGGREGATION
% Borda rank aggregation for model-derived feature rankings.
%
% Inputs:
%   rankings - M x N matrix
%              M = number of models
%              N = number of features
%              Each row contains feature ranks for one model.
%
%   weights  - M x 1 vector of model weights.
%              If empty, equal weights are used.
%
% Outputs:
%   equalScore    - Borda scores using equal model weights
%   weightedScore - Borda scores using supplied model weights
%
% Higher Borda scores indicate a higher aggregated rank.

arguments
    rankings double
    weights double = []
end

[M,N] = size(rankings);

if isempty(weights)
    weights = ones(M,1) ./ M;
else
    weights = weights(:);

    if numel(weights) ~= M
        error('Number of weights must equal number of models.');
    end

    if any(weights < 0)
        error('Model weights cannot be negative.');
    end

    if sum(weights) == 0
        error('At least one model weight must be positive.');
    end

    weights = weights ./ sum(weights);
end

% Borda points:
% highest-ranked feature receives N-1 points,
% next receives N-2, etc.
%
% Therefore:
% Borda points = N - rank

bordaPoints = N - rankings;

% Equal-weight aggregation
equalScore = sum(bordaPoints,1) ./ M;

% Performance-weighted aggregation
weightedScore = sum( ...
    bordaPoints .* weights, ...
    1);

end
