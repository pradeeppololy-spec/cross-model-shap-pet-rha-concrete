# Cross-Model SHAP Analysis of PET–RHA Concrete

## Overview

This repository is intended to provide the data-processing, machine-learning, explainability, and reproducibility materials associated with a study on PET–rice husk ash (RHA) concrete.

The study investigates machine-learning prediction of selected mechanical and durability properties of PET–RHA concrete and examines feature attribution and agreement among multiple machine-learning models.

## Experimental Dataset

The experimental programme comprises **10 concrete mixes (M0–M9)**. The mixture design includes polyethylene terephthalate (PET) and rice husk ash (RHA) as partial replacement materials.

The input variables considered in the machine-learning framework are:

- Cement
- PET
- Fine aggregate (FA)
- Rice husk ash (RHA)
- Coarse aggregate (CA)
- Water
- Superplasticizer (SP)

The machine-learning targets considered in the study are:

- Splitting tensile strength (STS)
- Flexural strength (FS)
- Water absorption (WA)
- Modulus of elasticity (MoE)
- Rapid chloride permeability test (RCPT)

Compressive strength (CS) is retained as an experimental property but is not treated as one of the five machine-learning targets in the reported framework.

## Machine-Learning Models

Four predictive models are considered:

1. Bayesian-optimized CatBoost
2. Random Forest (RF)
3. Support Vector Regression (SVR)
4. Attention-based LSTM-SVR

The models are evaluated using a mix-grouped **leave-one-mix-out (LOMO)** validation strategy. Ten outer folds are formed so that the complete observations associated with the held-out mix are excluded from model training and data augmentation.

## Fold-Wise Data Augmentation

To increase the diversity of the training representation without contaminating the held-out mix, augmentation is performed independently within each LOMO training fold after the mix-level partition has been established.

Each training fold contains nine original experimental mixes. Four augmentation mechanisms are used in equal proportion:

- Gaussian perturbation
- Random interpolation
- Nearest-neighbour blending
- Jittered bootstrap

A maximum of **189 synthetic records per fold** is generated, giving a **21:1 synthetic-to-experimental ratio** and a total training representation of **198 records**, including the nine original observations.

The augmented observations are derived from the training data and therefore do not represent additional independent experimental mixes.

## Random Seeds

Three random seeds are used for reproducibility:

- 42
- 123
- 2024

## SHAP-Based Feature Attribution

SHAP (SHapley Additive exPlanations) is used to examine model-attributed feature importance.

The following explainers are used:

- **TreeExplainer** for CatBoost and Random Forest
- **KernelExplainer** for SVR and attention-based LSTM-SVR

For KernelExplainer, the analysis uses a 10-point background sample from the corresponding training partition and 100 evaluation samples as specified in the study workflow.

SHAP values are interpreted as **model-attributed predictive importance conditional on the observed joint distribution of the input variables**. They are not interpreted as causal effects or direct physical mechanisms.

## Cross-Model Agreement

Feature-attribution rankings obtained from the four models are compared using:

- Spearman's rank correlation coefficient (rho)
- Kendall's rank correlation coefficient (tau)

Because the mixture design contains variables that remain constant across the experimental mixes, tied ranks can occur. Average ranks are used for Spearman analysis and the standard tie correction is applied for Kendall analysis. A sensitivity analysis based only on the varying constituents is also considered.

## Borda Rank Aggregation

Borda aggregation is used to summarize feature rankings across the four models.

The primary aggregation uses equal model weights. A performance-weighted formulation is considered as a sensitivity analysis. Model-performance weights are normalized to sum to one, with the performance transformation and positive floor specified in the accompanying analysis materials.

The aggregated rankings are treated as summaries of model-attributed feature importance within the experimental design rather than as measurements of physical causality.

## Exploratory Consensus Bands

For exploratory interpretation of cross-model agreement, the study uses the following descriptive bands:

- High agreement: rho ≥ 0.70
- Moderate agreement: 0.40 ≤ rho < 0.70
- Low agreement: rho < 0.40

These bands are used only as exploratory descriptive criteria and should not be interpreted as validated engineering safety thresholds or decision limits.

## Reproducibility

The repository is being organized to contain the materials required to reproduce the reported workflow, including:

- Original experimental data
- Data dictionary and variable definitions
- Fold-wise data-preparation and augmentation procedures
- LOMO validation procedure
- Machine-learning model implementations
- SHAP feature-attribution analysis
- Cross-model agreement analysis
- Borda rank aggregation
- Permutation and bootstrap uncertainty analyses, where applicable
- Sensitivity analyses
- Reproducibility information and software requirements

Synthetic observations generated during augmentation should be reproducible from the original experimental observations and the documented augmentation procedures rather than being treated as independent experimental measurements.

## Repository Structure

The repository is organized as follows:

```text
cross-model-shap-pet-rha-concrete/
│
├── README.md
├── LICENSE
├── CITATION.cff
├── requirements.txt
│
├── data/
│   ├── experimental_data.csv
│   └── data_dictionary.csv
│
├── src/
│   ├── data_preparation.py
│   ├── augmentation.py
│   ├── lomo_validation.py
│   ├── catboost_model.py
│   ├── random_forest_model.py
│   ├── svr_model.py
│   ├── lstm_svr_model.py
│   ├── shap_analysis.py
│   ├── cross_model_agreement.py
│   ├── borda_aggregation.py
│   ├── permutation_test.py
│   ├── bootstrap_analysis.py
│   └── sensitivity_analysis.py
│
├── results/
│   ├── predictions/
│   ├── shap/
│   ├── rankings/
│   ├── permutation/
│   ├── bootstrap/
│   └── sensitivity/
│
├── figures/
│
└── docs/
    ├── methodology.md
    └── reproducibility.md
```

The folders and files will be populated with the finalized research materials as they are added to the repository.

## Data Interpretation and Limitations

The study is based on a limited experimental design of 10 independent mixes. Consequently, augmented records are not equivalent to additional independent experiments. The LOMO strategy is used to separate the held-out mix from the training partition and to reduce the risk of mix-level information leakage.

The feature-attribution and cross-model agreement analyses describe the behaviour of the fitted machine-learning models for the available experimental design. They should not be interpreted as establishing causal relationships between mixture constituents and concrete properties.

## Data Availability

The experimental dataset, source code, and reproducibility materials supporting the findings of the associated study will be made available in this repository as the corresponding materials are uploaded and finalized.

## Citation

If you use the data, code, or methodology from this repository, please cite the associated research article once its bibliographic information is finalized.

## Contact

**Pololy Pradeep Kumar**  
Research Scholar, Department of Civil Engineering  
JNTU Anantapur, Andhra Pradesh, India
