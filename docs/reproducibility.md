# Reproducibility Guide

## Dataset

The repository contains the original experimental dataset for ten concrete mixes (M0-M9) in:

`data/experimental_data.csv`

The corresponding variable descriptions are provided in:

`data/data_dictionary.csv`

## Validation Strategy

The machine-learning analysis uses mix-grouped leave-one-mix-out (LOMO) validation.

For each fold:

1. One experimental mix is completely held out for testing.
2. The remaining nine mixes form the training partition.
3. Data augmentation is performed only within the training partition.
4. The held-out mix is not used during training or augmentation.
5. The trained model is evaluated on the held-out experimental observation.

This procedure is repeated for all ten mixes.

## Machine-Learning Targets

The five modeled properties are:

- Splitting tensile strength (STS)
- Flexural strength (FS)
- Water absorption (WA)
- Modulus of elasticity (MoE)
- Rapid chloride permeability test (RCPT)

## Random Seeds

The reported workflow uses the following random seeds:

- 42
- 123
- 2024

## Data Augmentation

Four augmentation mechanisms are used within the LOMO training folds:

- Gaussian perturbation
- Random interpolation
- Nearest-neighbour blending
- Jittered bootstrap

The augmented observations are synthetic training observations and do not represent additional independent experimental mixes.

## Explainability

SHAP-based feature attribution is used to investigate model-attributed predictive importance.

Tree-based models use TreeExplainer, while kernel-based models use KernelExplainer where applicable.

SHAP results are interpreted as model-attributed importance rather than causal physical effects.

## Cross-Model Agreement

Feature-attribution rankings are compared using:

- Spearman's rank correlation
- Kendall's rank correlation

Borda rank aggregation is used to summarize feature rankings across models.

## Reproducibility Principle

All preprocessing, augmentation, model fitting, validation, and explainability operations should be performed using only information available within the corresponding training partition. The held-out mix must remain isolated until final evaluation.
