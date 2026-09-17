function agreement = cross_model_agreement(rankings, modelNames, featureNames)
% CROSS_MODEL_AGREEMENT
% Calculates pairwise Spearman and Kendall rank agreement.
%
% Inputs:
%   rankings     - matrix: rows = models, columns = features
%   modelNames   - names of the models
%   featureNames - names of the input features
%
% Output:
%   agreement    - structure containing pairwise correlations
%
% The rankings should be calculated from the SHAP feature-attribution
% results obtained from the corresponding LOMO analysis.

arguments
    rankings double
    modelNames
    featureNames
end

nModels = size(rankings,1);

if nModels < 2
    error('At least two models are required.');
end

spearmanRho = NaN(nModels,nModels);
kendallTau = NaN(nModels,nModels);

for i = 1:nModels

    for j = 1:nModels

        if i == j
            spearmanRho(i,j) = 1;
            kendallTau(i,j) = 1;

        else

            % Spearman rank correlation
            spearmanRho(i,j) = corr( ...
                rankings(i,:)', ...
                rankings(j,:)', ...
                'Type','Spearman', ...
                'Rows','complete');

            % Kendall rank correlation
            kendallTau(i,j) = corr( ...
                rankings(i,:)', ...
                rankings(j,:)', ...
                'Type','Kendall', ...
                'Rows','complete');

        end

    end

end

agreement.SpearmanRho = spearmanRho;
agreement.KendallTau = kendallTau;
agreement.ModelNames = modelNames;
agreement.FeatureNames = featureNames;

end
