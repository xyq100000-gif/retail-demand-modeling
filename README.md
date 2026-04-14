# Interpretable Retail Demand Modeling with Heterogeneity Controls and Time-Aware Validation

This project studies weekly frozen-pizza sales using interpretable statistical models for overdispersed count data. The main question is:

> When predicting weekly retail demand, how much do model family, heterogeneity controls, and validation design change the conclusion?

## Overview

Weekly sales are observed at the store–product–week level. The modeling workflow compares transformed-linear and count-based approaches, then tests whether stronger structure in the data—especially product and store heterogeneity—matters more than small interaction extensions.

The main result is that future-week forecasting improves much more from heterogeneity controls than from interaction tinkering. In particular, adding `UPC` and `STORE_NUM` controls materially reduces holdout error and also shrinks overstated pooled promotion effects.

## Data scope

The underlying data contain frozen-pizza sales with regular price, realized shelf price, store identifier, product identifier, manufacturer, week index, and promotion flags.

Because the raw CSV is not distributed in this public repository, place the source file manually at:

```text
data/raw/grocery.csv
```

## Modeling logic

The repository is organized around three linked modeling questions:

1. **Model family**: Are count-based models preferable to transformed-linear regression for overdispersed weekly sales?
2. **Heterogeneity**: Do product and store controls materially change forecasting accuracy and the interpretation of promotion effects?
3. **Validation design**: Does future-week forecasting lead to the same model ranking as random cross-validation?

## Model ladder

| Model | Description | Rolling RMSE | Future holdout RMSE |
|---|---|---:|---:|
| M0 | Log-linear baseline + manufacturer + linear trend | 9.980 | 9.458 |
| M1 | Pooled count baseline + manufacturer + linear trend | 9.671 | 9.013 |
| M2 | M1 + seasonal harmonics | 9.629 | 9.024 |
| M3 | M2, but manufacturer replaced by `UPC` fixed effects | 9.221 | 8.732 |
| M4 | M3 + `STORE_NUM` fixed effects | 7.748 | 6.753 |
| M5 | M4 + DISPLAY interactions | 7.762 | 6.720 |

![Holdout RMSE across model ladder](figures/holdout_rmse_model_ladder.png)

## Main takeaways

- Moving from the pooled count baseline (M1) to the main upgraded model (M4) reduces future-holdout RMSE from 9.013 to 6.753, a **25.1%** improvement.
- DISPLAY interactions are directionally sensible but add little predictive value beyond the heterogeneity-controlled model.
- Pooled promotion coefficients are too large. Once product and store heterogeneity are controlled, the estimated DISPLAY lift shrinks materially.
- Negative binomial robustness checks confirm real overdispersion, but the main project story is structural: validation design and heterogeneity controls matter more than small family tweaks.

## Repository layout

```text
retail-demand-modeling/
├── README.md
├── .gitignore
├── data/
│   ├── README.md
│   └── raw/
├── figures/
├── notebooks/
│   └── retail_demand_modeling.qmd
├── results/
│   ├── stage2_model_summary.csv
│   ├── stage2_coef_stability.csv
│   └── stage2_nb_checks.csv
└── src/
    ├── 00_setup.R
    ├── 01_data_prep.R
    ├── 02_feature_engineering.R
    ├── 03_model_specs.R
    ├── 04_validation_helpers.R
    ├── 05_run_model_comparison.R
    └── 06_counterfactual_demo.R
```

## Reproducibility

1. Put `grocery.csv` at `data/raw/grocery.csv`.
2. Run `src/05_run_model_comparison.R`.
3. Inspect the generated `.csv` files in `results/`.
4. Render `notebooks/retail_demand_modeling.qmd` for the narrative report.

## Limits

This is a predictive demand-modeling project, not a causal promotion-effects study. Coefficients should be interpreted as predictive associations under observed store–product–week variation.

The strongest use case is future-week forecasting for already-seen stores and products, not cold-start prediction for new stores or unseen UPCs.
