function results = lomo_validation(X, y, mixIDs, targetSize, seed)
% LOMO_VALIDATION
% Mix-grouped Leave-One-Mix-Out validation with fold-wise augmentation.
%
% Each complete mix is held out once.
% Augmentation is performed only on the nine training mixes.
%
% Inputs:
%   X          - input matrix
%   y          - target vector
%   mixIDs     - mix identification vector
%   targetSize - desired training size after augmentation
%   seed       - random seed
%
% Output:
%   results    - table containing held-out observations and predictions

rng(seed, 'twister');

mixIDs = string(mixIDs);
uniqueMixes = unique(mixIDs, 'stable');

nFolds = numel(uniqueMixes);

Observed = [];
Predicted = [];
HeldOutMix = strings(0,1);

for fold = 1:nFolds

    %% -----------------------------------------------------------
    % Identify training and test observations
    % ------------------------------------------------------------

    testMix = uniqueMixes(fold);

    testIdx = mixIDs == testMix;
    trainIdx = ~testIdx;

    XTrain = X(trainIdx,:);
    yTrain = y(trainIdx);

    XTest = X(testIdx,:);
    yTest = y(testIdx);

    %% -----------------------------------------------------------
    % Fold-wise augmentation
    % ------------------------------------------------------------

    [XTrainAug, yTrainAug] = augmentation( ...
        XTrain, ...
        yTrain, ...
        targetSize, ...
        seed + fold);

    %% -----------------------------------------------------------
    % Standardize using training data only
    % ------------------------------------------------------------

    mu = mean(XTrainAug,1);
    sigma = std(XTrainAug,0,1);

    sigma(sigma == 0) = 1;

    XTrainZ = (XTrainAug - mu) ./ sigma;
    XTestZ = (XTest - mu) ./ sigma;

    %% -----------------------------------------------------------
    % Random Forest regression
    % ------------------------------------------------------------

    model = fitrensemble( ...
        XTrainZ, ...
        yTrainAug, ...
        'Method','Bag', ...
        'NumLearningCycles',100, ...
        'Learners',templateTree('MaxNumSplits',20));

    yPred = predict(model,XTestZ);

    %% -----------------------------------------------------------
    % Store results
    % ------------------------------------------------------------

    Observed = [Observed; yTest];
    Predicted = [Predicted; yPred];

    HeldOutMix = [HeldOutMix; ...
        repmat(testMix,numel(yTest),1)];

end

%% ---------------------------------------------------------------
% Performance metrics
% ---------------------------------------------------------------

errorValues = Observed - Predicted;

MAE = mean(abs(errorValues));

RMSE = sqrt(mean(errorValues.^2));

SSres = sum(errorValues.^2);
SStot = sum((Observed - mean(Observed)).^2);

if SStot == 0
    R2 = NaN;
else
    R2 = 1 - SSres/SStot;
end

%% ---------------------------------------------------------------
% Return results
% ---------------------------------------------------------------

results = table( ...
    HeldOutMix, ...
    Observed, ...
    Predicted, ...
    'VariableNames', ...
    {'Mix_ID','Observed','Predicted'});

results.MAE = repmat(MAE,height(results),1);
results.RMSE = repmat(RMSE,height(results),1);
results.R2 = repmat(R2,height(results),1);

end
