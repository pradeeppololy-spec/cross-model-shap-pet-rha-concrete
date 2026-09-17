%% LOMO Baseline Models for PET-RHA Concrete
% Reproducibility code for the PET-RHA concrete study.
%
% This script performs mix-level Leave-One-Mix-Out (LOMO) validation
% using Random Forest regression and Support Vector Regression (SVR).
%
% Dataset:
%   data/experimental_data.csv
%
% Original experimental mixes:
%   M0-M9
%
% Random seeds:
%   42, 123, 2024

clear;
clc;
close all;

%% ---------------------------------------------------------------
% 1. SETTINGS
% ---------------------------------------------------------------

dataFile = fullfile('..', 'data', 'experimental_data.csv');

randomSeeds = [42, 123, 2024];

% Five machine-learning target properties
targetNames = { ...
    'STS_MPa', ...
    'FS_MPa', ...
    'WA_percent', ...
    'MoE_GPa', ...
    'RCPT_Coulombs'};

% Seven mixture-design input variables
inputNames = { ...
    'Cement_kg_m3', ...
    'PET_kg_m3', ...
    'FA_kg_m3', ...
    'RHA_kg_m3', ...
    'CA_kg_m3', ...
    'Water_kg_m3', ...
    'SP_kg_m3'};

%% ---------------------------------------------------------------
% 2. LOAD ORIGINAL EXPERIMENTAL DATA
% ---------------------------------------------------------------

fprintf('Loading experimental dataset...\n');

T = readtable(dataFile);

fprintf('Number of experimental observations: %d\n', height(T));

mixIDs = string(T.Mix_ID);
uniqueMixes = unique(mixIDs, 'stable');

fprintf('Number of unique mixes: %d\n', numel(uniqueMixes));

if numel(uniqueMixes) ~= 10
    warning('Expected 10 mixes (M0-M9), but found %d.', ...
        numel(uniqueMixes));
end

X = T{:, inputNames};

%% ---------------------------------------------------------------
% 3. RESULTS TABLE
% ---------------------------------------------------------------

allResults = table();

%% ---------------------------------------------------------------
% 4. LOOP OVER TARGET PROPERTIES
% ---------------------------------------------------------------

for t = 1:numel(targetNames)

    targetName = targetNames{t};

    fprintf('\n=============================================\n');
    fprintf('Target: %s\n', targetName);
    fprintf('=============================================\n');

    y = T{:, targetName};

    %% -----------------------------------------------------------
    % Loop over random seeds
    % -----------------------------------------------------------

    for s = 1:numel(randomSeeds)

        seed = randomSeeds(s);
        rng(seed, 'twister');

        fprintf('\nRandom seed: %d\n', seed);

        %% -------------------------------------------------------
        % Storage for predictions
        % -------------------------------------------------------

        yTrue_RF = [];
        yPred_RF = [];

        yTrue_SVR = [];
        yPred_SVR = [];

        heldOutMix = strings(0,1);

        %% -------------------------------------------------------
        % 10-fold LOMO
        % -------------------------------------------------------

        for fold = 1:numel(uniqueMixes)

            testMix = uniqueMixes(fold);

            testIdx = mixIDs == testMix;
            trainIdx = ~testIdx;

            XTrain = X(trainIdx, :);
            yTrain = y(trainIdx);

            XTest = X(testIdx, :);
            yTest = y(testIdx);

            fprintf('  Fold %d/10: held-out mix = %s\n', ...
                fold, testMix);

            %% ---------------------------------------------------
            % Standardization using training data only
            % ---------------------------------------------------

            mu = mean(XTrain, 1);
            sigma = std(XTrain, 0, 1);

            % Avoid division by zero for constant variables
            sigma(sigma == 0) = 1;

            XTrainZ = (XTrain - mu) ./ sigma;
            XTestZ  = (XTest  - mu) ./ sigma;

            %% ---------------------------------------------------
            % Random Forest regression
            % ---------------------------------------------------

            RF = fitrensemble( ...
                XTrainZ, ...
                yTrain, ...
                'Method', 'Bag', ...
                'NumLearningCycles', 100, ...
                'Learners', templateTree( ...
                    'MaxNumSplits', 20));

            predRF = predict(RF, XTestZ);

            %% ---------------------------------------------------
            % Support Vector Regression
            % ---------------------------------------------------

            SVR = fitrsvm( ...
                XTrainZ, ...
                yTrain, ...
                'KernelFunction', 'gaussian', ...
                'Standardize', false);

            predSVR = predict(SVR, XTestZ);

            %% ---------------------------------------------------
            % Store predictions
            % ---------------------------------------------------

            yTrue_RF = [yTrue_RF; yTest];
            yPred_RF = [yPred_RF; predRF];

            yTrue_SVR = [yTrue_SVR; yTest];
            yPred_SVR = [yPred_SVR; predSVR];

            heldOutMix = [heldOutMix; ...
                repmat(testMix, numel(yTest), 1)];

        end

        %% -------------------------------------------------------
        % 5. CALCULATE PERFORMANCE METRICS
        % -------------------------------------------------------

        metricsRF = calculateMetrics(yTrue_RF, yPred_RF);
        metricsSVR = calculateMetrics(yTrue_SVR, yPred_SVR);

        %% -------------------------------------------------------
        % Store RF result
        % -------------------------------------------------------

        rowRF = table( ...
            string(targetName), ...
            string("RF"), ...
            seed, ...
            metricsRF.MAE, ...
            metricsRF.RMSE, ...
            metricsRF.R2, ...
            'VariableNames', { ...
            'Target', ...
            'Model', ...
            'Seed', ...
            'MAE', ...
            'RMSE', ...
            'R2'});

        %% -------------------------------------------------------
        % Store SVR result
        % -------------------------------------------------------

        rowSVR = table( ...
            string(targetName), ...
            string("SVR"), ...
            seed, ...
            metricsSVR.MAE, ...
            metricsSVR.RMSE, ...
            metricsSVR.R2, ...
            'VariableNames', { ...
            'Target', ...
            'Model', ...
            'Seed', ...
            'MAE', ...
            'RMSE', ...
            'R2'});

        allResults = [allResults; rowRF; rowSVR];

        %% -------------------------------------------------------
        % Save predictions
        % -------------------------------------------------------

        predictionTable = table( ...
            heldOutMix, ...
            yTrue_RF, ...
            yPred_RF, ...
            yPred_SVR, ...
            'VariableNames', { ...
            'Mix_ID', ...
            'Observed', ...
            'RF_Predicted', ...
            'SVR_Predicted'});

        outputFolder = fullfile('..', 'results', 'predictions');

        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end

        outputFile = fullfile( ...
            outputFolder, ...
            sprintf('%s_seed_%d_predictions.csv', ...
            targetName, seed));

        writetable(predictionTable, outputFile);

    end
end

%% ---------------------------------------------------------------
% 6. SAVE SUMMARY RESULTS
% ---------------------------------------------------------------

outputFolder = fullfile('..', 'results');

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

writetable( ...
    allResults, ...
    fullfile(outputFolder, 'baseline_lomo_metrics.csv'));

fprintf('\n=============================================\n');
fprintf('Analysis completed.\n');
fprintf('Results saved to:\n');
fprintf('results/baseline_lomo_metrics.csv\n');
fprintf('=============================================\n');


%% ===============================================================
% LOCAL FUNCTION
% ===============================================================

function metrics = calculateMetrics(yTrue, yPred)

    residuals = yTrue - yPred;

    % Mean Absolute Error
    MAE = mean(abs(residuals));

    % Root Mean Squared Error
    RMSE = sqrt(mean(residuals.^2));

    % Coefficient of determination
    SSres = sum(residuals.^2);
    SStot = sum((yTrue - mean(yTrue)).^2);

    if SStot == 0
        R2 = NaN;
    else
        R2 = 1 - SSres / SStot;
    end

    metrics.MAE = MAE;
    metrics.RMSE = RMSE;
    metrics.R2 = R2;

end
