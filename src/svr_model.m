function model = svr_model(XTrain, yTrain)
% SVR_MODEL
% Support Vector Regression model for PET-RHA concrete prediction.
%
% Inputs:
%   XTrain - training input matrix
%   yTrain - training target vector
%
% Output:
%   model - trained SVR regression model

arguments
    XTrain double
    yTrain double
end

% Train Gaussian-kernel SVR.
% Standardization is performed internally using the training data.

model = fitrsvm( ...
    XTrain, ...
    yTrain, ...
    'KernelFunction', 'gaussian', ...
    'Standardize', true);

end
