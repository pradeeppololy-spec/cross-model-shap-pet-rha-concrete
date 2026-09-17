function [X_aug, y_aug] = augmentation(X, y, targetSize, seed)
% AUGMENTATION
% Fold-wise augmentation for PET-RHA concrete data.
%
% Inputs:
%   X          - training input matrix
%   y          - training target vector
%   targetSize - required total number of observations
%   seed       - random seed
%
% Outputs:
%   X_aug      - original + synthetic input observations
%   y_aug      - original + synthetic target observations
%
% IMPORTANT:
%   This function must be called AFTER the LOMO training/test partition
%   has been established. The held-out mix must never be supplied to
%   this function.

rng(seed, 'twister');

% Keep the original experimental observations
X_aug = X;
y_aug = y;

nOriginal = size(X,1);

if targetSize <= nOriginal
    return;
end

nSynthetic = targetSize - nOriginal;

% Four augmentation mechanisms in approximately equal proportion
nEach = floor(nSynthetic / 4);
remaining = nSynthetic - 4*nEach;

nGaussian = nEach;
nInterpolation = nEach;
nNeighbour = nEach;
nBootstrap = nEach + remaining;

%% ---------------------------------------------------------------
% 1. Gaussian perturbation
% ---------------------------------------------------------------

featureSD = std(X, 0, 1);

% Prevent zero variance from causing problems
featureSD(featureSD == 0) = 1;

for i = 1:nGaussian

    idx = randi(nOriginal);

    xNew = X(idx,:) + ...
        0.01 .* featureSD .* randn(1,size(X,2));

    yNew = y(idx);

    X_aug = [X_aug; xNew];
    y_aug = [y_aug; yNew];

end

%% ---------------------------------------------------------------
% 2. Random interpolation
% ---------------------------------------------------------------

for i = 1:nInterpolation

    idx1 = randi(nOriginal);
    idx2 = randi(nOriginal);

    alpha = rand();

    xNew = alpha .* X(idx1,:) + ...
        (1-alpha) .* X(idx2,:);

    yNew = alpha .* y(idx1) + ...
        (1-alpha) .* y(idx2);

    X_aug = [X_aug; xNew];
    y_aug = [y_aug; yNew];

end

%% ---------------------------------------------------------------
% 3. Nearest-neighbour blending
% ---------------------------------------------------------------

for i = 1:nNeighbour

    idx = randi(nOriginal);

    distances = sum((X - X(idx,:)).^2, 2);

    distances(idx) = Inf;

    [~, neighbourIdx] = min(distances);

    alpha = 0.5;

    xNew = alpha .* X(idx,:) + ...
        (1-alpha) .* X(neighbourIdx,:);

    yNew = alpha .* y(idx) + ...
        (1-alpha) .* y(neighbourIdx);

    X_aug = [X_aug; xNew];
    y_aug = [y_aug; yNew];

end

%% ---------------------------------------------------------------
% 4. Jittered bootstrap
% ---------------------------------------------------------------

for i = 1:nBootstrap

    idx = randi(nOriginal);

    xNew = X(idx,:) + ...
        0.005 .* featureSD .* randn(1,size(X,2));

    ySD = std(y);

    if ySD == 0
        ySD = 1;
    end

    yNew = y(idx) + ...
        0.005 .* ySD .* randn();

    X_aug = [X_aug; xNew];
    y_aug = [y_aug; yNew];

end

%% ---------------------------------------------------------------
% Final size check
% ---------------------------------------------------------------

if size(X_aug,1) ~= targetSize

    error('Augmented dataset size does not match targetSize.');

end

end
