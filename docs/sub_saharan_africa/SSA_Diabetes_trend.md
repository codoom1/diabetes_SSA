# Research Protocol: Epidemiological Transition and Forecasting of Diabetes Burden in Sub-Saharan Africa

## 1. Study Objectives and Scope

This study will assess changes in the burden of diabetes mellitus (DM) in
Sub-Saharan Africa (SSA) from 1990 to 2023 and forecast the burden through
2030. Analyses will cover SSA as a whole, the four Global Burden of Disease
(GBD) SSA subregions, and individual SSA countries.

The study has five objectives:

1. Describe temporal trends in diabetes burden by sex and diabetes type.
2. Identify significant changes in temporal trends.
3. Decompose changes in burden into population growth, population aging, and
   epidemiological rate effects.
4. Examine age, period, and birth-cohort effects.
5. Forecast diabetes burden through 2030 using validated statistical models.

### 1.1 Outcomes and Stratification

The following outcomes will be assessed:

* Prevalence
* Incidence
* Deaths
* Disability-adjusted life years (DALYs)
* Years of life lost (YLLs)
* Years lived with disability (YLDs)

Results will be stratified by sex and diabetes type: total diabetes, type 1
diabetes mellitus (T1DM), and type 2 diabetes mellitus (T2DM).

### 1.2 Reporting Levels

Age-standardized rates per 100,000 population will be used for comparisons
across locations and over time. All-age counts and age-specific counts and
rates will be used for decomposition, age-period-cohort analysis, and
count-based forecasting.

Point estimates will be reported with corresponding 95% uncertainty intervals
(UIs). UIs from GBD estimates will not be described as confidence intervals.

## 2. Data Sources and Extraction

### 2.1 Epidemiological Data

Epidemiological estimates will be obtained from the GBD 2023 Results Tool.
Extracts will include:

* Annual age-standardized rates for 1990-2023
* Annual all-age counts for 1990-2023
* Annual age-specific counts and rates for all available five-year age groups
* Point estimates and lower and upper 95% uncertainty bounds

The extraction will include Saudi Arabia, SSA, the four GBD SSA subregions,
and all SSA countries. The GBD 2023 location hierarchy will define subregional
and country membership.

### 2.2 Population Data

Population estimates associated with GBD 2023 will be used for analyses that
reproduce GBD counts and rates. United Nations World Population Prospects 2024
will provide population projections through 2030 and will be used in
sensitivity analyses.

GBD rates will not be combined with external population estimates without
labeling the resulting counts as reconstructed estimates and validating them
against published GBD counts.

### 2.3 Saudi Arabia Benchmark

The analysis pipeline will first reproduce the principal findings reported by
Ghazy et al. (2026) for Saudi Arabia. This validation step will assess whether
the pipeline can recover the published changes in prevalence, incidence,
mortality, and DALYs before it is applied to SSA.

The Saudi findings will then serve as a comparative benchmark. Comparisons will
focus on the magnitude of incidence growth, the contribution of the rate
effect, and changes in the balance between premature mortality and disability.

## 3. Descriptive Analysis

For each reporting stratum, the analysis will calculate:

* 1990 and 2023 estimates with 95% UIs
* Absolute and relative changes between 1990 and 2023
* Male-to-female rate ratios
* The proportion of total diabetes burden attributable to T2DM

Primary inferential analyses will focus on SSA and the four subregions.
Country-level results will be presented as a comparative atlas.

## 4. Temporal Trend Analysis

Joinpoint regression will be applied to the logarithm of annual
age-standardized rates to identify significant changes in temporal trends.

The analysis will report:

* Annual percentage change (APC) for each identified segment
* Average annual percentage change (AAPC) for 1990-2023
* 95% confidence intervals and p-values for APC and AAPC estimates

The maximum number of joinpoints, minimum segment length, model-selection
method, permutation-test settings, and handling of zero values will be
specified before model fitting.

Statistical significance will be assessed at `p < 0.05`. False discovery rate
correction will be applied when interpreting multiple country-level tests.
When GBD draws are available, trend models will be repeated across draws to
propagate uncertainty in the underlying estimates.

## 5. Decomposition of Changes in Burden

Changes in all-age counts between 1990 and 2023 will be decomposed into:

1. **Population growth effect:** change caused by total population growth.
2. **Age structure effect:** change caused by shifts in the population age
   distribution.
3. **Rate effect:** change caused by changes in age-specific epidemiological
   rates.

The decomposition will use age-specific rates and age-specific population
counts. Because sequential decomposition results depend on the order in which
factors are changed, contributions will be averaged across all six possible
factor orderings.

For each driver, both the absolute contribution and percentage contribution
will be reported:

```text
Percentage contribution = 100 * driver contribution / total observed change
```

The three absolute contributions must sum to the observed change, allowing
only for numerical rounding. Percentage contributions will not be interpreted
when the total observed change is close to zero.

The SSA rate effect will be compared with the rate effect reported for Saudi
Arabia to assess whether diabetes burden is increasing independently of
population growth and aging.

## 6. Age-Period-Cohort Analysis

Age-period-cohort (APC) analysis will assess the independent patterns
associated with age, calendar period, and birth cohort. Annual age-specific
counts and matching population denominators will be aggregated into compatible
five-year age and period groups.

Poisson or negative-binomial models will be fitted with the logarithm of
population as an offset. The age-period-cohort identification problem will be
addressed using a documented intrinsic-estimator or constrained approach.

The analysis will report:

* Longitudinal age curves
* Period rate ratios
* Cohort rate ratios
* Net drift and local drifts

Primary APC analyses will focus on incidence and mortality. Period and cohort
patterns will be interpreted in relation to SSA-specific changes such as
urbanization, HIV and tuberculosis comorbidity, obesity, and access to
diabetes diagnosis, insulin, and long-term care. These factors will be treated
as possible explanations rather than causal conclusions.

## 7. Mortality-to-Disability Transition

The YLL-to-YLD ratio will be used to assess whether the burden is dominated by
premature mortality or long-term disability.

The primary ratio will be calculated from all-age YLL and YLD counts:

```text
YLL-to-YLD ratio = YLL count / YLD count
```

Ratios will be calculated annually and summarized at five-year intervals. A
declining ratio will indicate a shift toward disability-dominated burden,
whereas an increasing ratio may indicate worsening premature mortality.
Potential reversals will be evaluated descriptively and using segmented trend
analysis.

## 8. Forecasting Through 2030

Forecasts will be generated using:

1. Autoregressive integrated moving average (ARIMA) models
2. Exponential smoothing state-space (ETS) models
3. Poisson or negative-binomial count models with population offsets

ARIMA and ETS models will forecast age-standardized rates. Count models will
forecast counts using projected populations as offsets; Poisson models will
not be fitted directly to continuous rates.

### 8.1 Validation and Model Selection

Models will be evaluated using expanding-window cross-validation. The primary
analysis will use an initial 15-year training period from 1990 to 2004 and
sequential forecasts through 2023.

Forecast performance will be assessed using:

* Root mean squared error (RMSE)
* Mean absolute error (MAE)
* Mean absolute percentage error (MAPE), when observed values are not near zero
* Mean absolute scaled error (MASE)
* Residual diagnostics and temporal stability

The Diebold-Mariano test will compare models evaluated at the same forecast
origins and horizons. Final model selection will consider forecast accuracy,
residual diagnostics, stability, and epidemiological plausibility rather than
relying on a single test.

Prediction intervals will incorporate both model uncertainty and uncertainty
in GBD estimates. Simulation across GBD draws will be preferred when draws are
available. Published lower and upper UI bounds will not be modeled as
independent time series.

## 9. Sensitivity Analyses

The robustness of results will be assessed using:

* Initial forecast-training windows of 10, 15, and 20 years
* Forecast horizons of 1, 3, and 5 years
* Alternative Poisson and negative-binomial count models
* GBD and UN population series
* Alternative valid APC constraints
* Analyses with and without country-level multiple-testing correction

## 10. Quality Assurance and Reproducibility

The analysis pipeline will verify that:

1. All required years, locations, outcomes, and strata are present.
2. Point estimates fall within their reported uncertainty bounds.
3. Age-specific counts approximately sum to all-age counts.
4. T1DM and T2DM estimates approximately sum to total diabetes estimates where
   GBD definitions permit.
5. Decomposition contributions sum to the observed change.
6. Forecast residuals do not contain severe unresolved autocorrelation.

All analyses will be conducted in R version 4.3.1 or later. Data-processing
steps, model settings, software versions, validation results, and deviations
from the protocol will be documented. Statistical significance will be
defined as `p < 0.05`, with multiplicity adjustments where specified.

If mortality is projected to decline while DALYs rise, the final report will
discuss the implications for integrated diabetes care and long-term disability
management.

## 11. Planned Outputs

The main report will include:

* A summary table of 1990 and 2023 burden estimates and temporal trends
* Subregional and country-level comparative results
* Decomposition of changes in burden
* Age-period-cohort results
* YLL-to-YLD trends
* Validated forecasts through 2030

Supplementary materials will include the Saudi Arabia reproduction results,
country-level estimates, full model diagnostics, sensitivity analyses, and a
reproducibility report.

## Reference

Ghazy RM, Alsaleem SA, Alshaikh AA, et al. Epidemiological transition and
forecasting of diabetes burden in Saudi Arabia: a comprehensive analysis from
the Global Burden of Disease Study 1990-2023. *Diabetes, Obesity and
Metabolism*. 2026. <https://doi.org/10.1111/dom.70650>.
