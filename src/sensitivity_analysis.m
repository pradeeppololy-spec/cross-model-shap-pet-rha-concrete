function result = sensitivity_analysis(fullRankings, variableNames, nVarying)
% SENSITIVITY_ANALYSIS
% Compares feature rankings using all variables versus only the
% varying mixture constituents.
%
% Inputs:
%   fullRankings  - M x N matrix of model feature rankings
%   variableNames - names of all N variables
%   nVarying      - number of varying mixture constituents
%
% Output:
%   result        - sensitivity-analysis structure
%
% This analysis is intended to assess whether conclusions are
% materially affected by variables that remain constant in the
% experimental mixture design.

arguments
    fullRankings double
    variableNames
    nVarying double
end

[M,N] = size(fullRankings);

if numel(variableNames) ~= N
    error('Number of variable names must equal number of features.');
end

if nVarying < 1 || nVarying > N
    error('nVarying must be between 1 and the total number of features.');
end

%% Full ranking

fullMeanRank = mean(fullRankings,1);

[~,fullOrder] = sort(fullMeanRank,'ascend');

fullRankingOrder = variableNames(fullOrder);

%% Varying-constituent ranking

% The first nVarying columns are assumed to represent the varying
% constituents supplied to this function.
varyingRankings = fullRankings(:,1:nVarying);

varyingMeanRank = mean(varyingRankings,1);

[~,varyingOrder] = sort(varyingMeanRank,'ascend');

varyingRankingOrder = variableNames(varyingOrder);

%% Store results

result.FullMeanRank = fullMeanRank;
result.FullRankingOrder = fullRankingOrder;

result.VaryingMeanRank = varyingMeanRank;
result.VaryingRankingOrder = varyingRankingOrder;

result.NumberOfModels = M;
result.NumberOfFeatures = N;
result.NumberOfVaryingFeatures = nVarying;

end
