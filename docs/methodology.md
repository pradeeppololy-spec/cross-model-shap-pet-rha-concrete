# Methodology

## 1. Experimental Dataset

The study uses an experimental dataset consisting of ten concrete mixes, identified as M0-M9.

The mixture-design variables are:

- Cement
- PET
- Fine aggregate (FA)
- Rice husk ash (RHA)
- Coarse aggregate (CA)
- Water
- Superplasticizer (SP)

The original experimental observations are provided in:

`data/experimental_data.csv`

Variable definitions are provided in:

`data/data_dictionary.csv`

## 2. Machine-Learning Targets

Five concrete properties are modeled:

1. Splitting tensile strength (STS)
2. Flexural strength (FS)
3. Water absorption (WA)
4. Modulus of elasticity (MoE)
5. Rapid chloride permeability test (RCPT)

Compressive strength (CS) is retained in the experimental dataset but is not included among the five machine-learning targets of the reported framework.

## 3. Validation Strategy

A mix-grouped leave-one-mix-out (LOMO) validation strategy is used.

In each fold:

1. One complete mix is held out for testing.
2. The remaining nine mixes form the training partition.
3. The held-out mix is excluded from model training.
4. The held-out mix is also excluded from data augmentation.
5. The trained model is evaluated on the held-out experimental observation.

The procedure is repeated for all ten mixes.

## 4. Data Augmentation

Data augmentation is performed independently within each LOMO training fold.

Four augmentation mechanisms are used:

- Gaussian perturbation
- Random interpolation
- Nearest-neighbour blending
- Jittered bootstrap

The maximum augmentation configuration produces 189 synthetic records from the nine original training mixes, resulting in 198 training observations when the nine original observations are included.

Synthetic observations are not considered additional independent experimental observations.

## 5. Machine-Learning Models

The study considers four predictive models:

- Bayesian-optimized CatBoost
- Random Forest (RF)
- Support Vector Regression (SVR)
- Attention-based LSTM-SVR

The detailed model implementations and final hyperparameters should be provided in the source-code directory.

## 6. Explainable Machine Learning

SHAP-based feature attribution is used to investigate the contribution of input variables to model predictions.

TreeExplainer is used for tree-based models, while KernelExplainer is used for models requiring a model-agnostic SHAP approach.

SHAP values represent model-attributed predictive importance conditional on the observed input distribution. They are not interpreted as causal effects.

## 7. Cross-Model Agreement

Feature-attribution rankings from the four models are compared using:

- Spearman's rank correlation coefficient
- Kendall's rank correlation coefficient

The analysis accounts for tied rankings associated with variables that remain constant across the experimental mixture design.

A sensitivity analysis can also be performed using only the varying mixture constituents.

## 8. Borda Rank Aggregation

Borda rank aggregation is used to obtain a combined ranking of model-attributed feature importance.

The primary analysis uses equal model weights.

A performance-weighted formulation is considered as a sensitivity analysis.

The resulting ranking represents a summary of model attribution and should not be interpreted as a direct physical or causal ranking of concrete constituents.

## 9. Random Seeds

The reproducibility analysis uses the following random seeds:

- 42
- 123
- 2024

## 10. Reproducibility

All fold-dependent operations should be performed after establishing the mix-level training and test partition.

In particular, the held-out mix must not contribute to:

- training,
- data augmentation,
- model fitting,
- hyperparameter selection,
- or background-data construction for explainability.

The source code and generated results should be organized so that the analysis can be independently inspected and reproduced.
