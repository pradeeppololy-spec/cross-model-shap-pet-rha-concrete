function model = catboost_model(XTrain, yTrain)
% CATBOOST_MODEL
% Train a CatBoost regression model.
%
% NOTE:
% MATLAB does not provide CatBoost as a standard built-in regression
% learner. This wrapper therefore expects a CatBoost MATLAB/Python
% interface to be configured separately.
%
% The function is provided as a repository interface and should be
% connected to the exact CatBoost implementation used in the study.

arguments
    XTrain double
    yTrain double
end

error(['CatBoost implementation is not configured in this MATLAB ', ...
       'environment. Connect this wrapper to the exact CatBoost ', ...
       'version and hyperparameters used in the study before using ', ...
       'this function for final reproducibility.']);

end
