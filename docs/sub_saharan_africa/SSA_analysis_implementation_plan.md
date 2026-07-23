# SSA Diabetes Burden Analysis: Implementation Plan

## 1. Study Design

This study is an expanded replication of Ghazy et al. (2026), "Epidemiological
Transition and Forecasting of Diabetes Burden in Saudi Arabia: A Comprehensive
Analysis From the Global Burden of Disease Study 1990-2023"
(DOI: 10.1111/dom.70650).

The primary analysis will estimate diabetes burden from 1990 to 2023 for:

1. Sub-Saharan Africa (SSA) as a whole
2. The four GBD SSA subregions
3. Individual SSA countries

Results will be stratified by sex and diabetes type. The primary inferential
analyses will be performed at the SSA and subregional levels. Country-level
results will be treated as a comparative atlas and will use false discovery
rate correction where multiple country-level tests are reported.

## 2. Analysis Hierarchy

The project should be implemented in stages to keep the expanded scope
computationally and scientifically manageable.

### Stage 1: Saudi Arabia Reproduction

Reproduce the published Saudi Arabia headline estimates and trends using the
same GBD 2023 release. This is a pipeline validation step, not a study result.
Large discrepancies must be resolved before applying the pipeline to SSA.

Validation targets include:

* 117.3% increase in age-standardized diabetes prevalence, 1990-2023
* 97.2% increase in age-standardized incidence
* 112.9% increase in age-standardized DALY rate
* Mortality rate increase from 25.26 to 58.74 per 100,000

### Stage 2: SSA and Four Subregions

Run all primary analyses for SSA and the four GBD subregions:

* Western Sub-Saharan Africa
* Eastern Sub-Saharan Africa
* Central Sub-Saharan Africa
* Southern Sub-Saharan Africa

### Stage 3: Country-Level Atlas

Run descriptive trends, endpoint comparisons, and selected forecasts for all
SSA countries. Joinpoint and age-period-cohort models should only be reported
when model diagnostics and data support are adequate.

## 3. Required Input Data

The analysis cannot be run from age-standardized rates alone. Separate
age-specific and all-age count extracts are required for decomposition,
age-period-cohort analysis, and Poisson forecasting.

### 3.1 GBD 2023 Extracts

Download all GBD data from the same GBD Results Tool release and preserve the
download metadata with each file.

#### Extract A: Age-Standardized Rates

| Field | Required values |
|---|---|
| Location | Saudi Arabia, SSA, four SSA subregions, all SSA countries |
| Year | 1990-2023 |
| Sex | Male, Female, Both |
| Age | Age-standardized |
| Cause | Diabetes mellitus, Type 1 diabetes mellitus, Type 2 diabetes mellitus |
| Measure | Prevalence, Incidence, Deaths, DALYs, YLLs, YLDs |
| Metric | Rate |

Use this extract for endpoint summaries, temporal trends, and descriptive
forecasting of age-standardized rates.

#### Extract B: Age-Specific Counts and Rates

| Field | Required values |
|---|---|
| Location | Saudi Arabia, SSA, four SSA subregions, all SSA countries |
| Year | 1990-2023 |
| Sex | Male, Female, Both |
| Age | All available five-year age groups |
| Cause | Diabetes mellitus, Type 1 diabetes mellitus, Type 2 diabetes mellitus |
| Measure | Prevalence, Incidence, Deaths, DALYs, YLLs, YLDs |
| Metric | Number and Rate |

Use this extract for decomposition, age-period-cohort models, internal
consistency checks, and count forecasts.

#### Extract C: All-Age Counts

Use the same dimensions as Extract A, with `Age = All ages` and
`Metric = Number`. This supports headline burden totals and validates that
age-specific counts aggregate correctly.

For every extract, retain the point estimate, lower 95% uncertainty bound, and
upper 95% uncertainty bound. If GBD draws are available, use the draws instead
of reconstructing uncertainty from the bounds.

### 3.2 Population Data

The primary analysis should use one internally consistent population series.
Prefer the population estimates associated with GBD 2023 when reproducing GBD
rates and counts. Use UN World Population Prospects 2024 as a sensitivity
analysis or for future population projections.

Required population dimensions:

* Location
* Year, including projections through 2030
* Sex
* Five-year age group
* Population count

Do not mix GBD-derived rates with WPP populations without labeling the
resulting counts as reconstructed estimates and validating them against GBD
all-age counts.

## 4. Canonical Data Schema

All input files should be transformed into a long-format analytical table:

| Column | Description |
|---|---|
| `location` | GBD location name |
| `location_level` | `ssa`, `subregion`, `country`, or `benchmark` |
| `year` | Calendar year |
| `sex` | `male`, `female`, or `both` |
| `age` | GBD age-group label |
| `cause` | `diabetes`, `t1dm`, or `t2dm` |
| `measure` | `prevalence`, `incidence`, `deaths`, `dalys`, `ylls`, or `ylds` |
| `metric` | `number` or `rate` |
| `value` | Point estimate |
| `lower` | Lower 95% uncertainty bound |
| `upper` | Upper 95% uncertainty bound |
| `source_release` | GBD release identifier |

The location-to-subregion crosswalk must be versioned and checked against the
GBD 2023 location hierarchy.

## 5. Statistical Analysis Specifications

### 5.1 Descriptive Endpoints

For every reporting stratum, calculate:

* 1990 and 2023 point estimates with 95% uncertainty intervals
* Absolute change: `value_2023 - value_1990`
* Relative change: `100 * (value_2023 / value_1990 - 1)`
* Male-to-female rate ratio
* T2DM share of total diabetes burden

Uncertainty intervals are GBD uncertainty intervals, not conventional
confidence intervals. Statistical inference should propagate GBD draws when
available.

### 5.2 Joinpoint Trends

Fit joinpoint models to the log of each annual age-standardized rate. Report
segment-specific APCs and the full-period AAPC with 95% confidence intervals.

Pre-specify:

* Maximum number of joinpoints
* Minimum observations between joinpoints
* Model selection method and permutation-test settings
* Handling of zero rates

For country-level analyses, control the false discovery rate across related
tests. If GBD draws are available, repeat trend estimation across draws to
quantify uncertainty attributable to the GBD estimates.

### 5.3 Decomposition

Perform decomposition on all-age counts using age-specific rates and
age-specific populations. Define three counterfactual totals:

* Baseline: 1990 population size, 1990 age structure, 1990 rates
* Population counterfactual: 2023 population size, 1990 age structure, 1990 rates
* Age counterfactual: 2023 population size, 2023 age structure, 1990 rates
* Observed endpoint: 2023 population size, 2023 age structure, 2023 rates

Because sequential decomposition depends on factor ordering, use a symmetric
three-factor decomposition, averaging contributions across all six possible
factor orderings. Confirm that the three effects sum to the observed change,
allowing only numerical rounding error.

Report both absolute contributions and percentage contributions. When the
total change is close to zero, percentage contributions are unstable and
should not be interpreted.

### 5.4 Age-Period-Cohort Analysis

APC analysis requires age-specific counts and matching population offsets.
Aggregate annual observations into compatible five-year age and period groups,
then derive birth cohorts as `period midpoint - age midpoint`.

Use a Poisson or negative-binomial model with log population as an offset.
Address the identification problem using a clearly documented intrinsic
estimator or constrained approach. Report:

* Longitudinal age curve
* Period rate ratios
* Cohort rate ratios
* Net drift and local drifts

APC models should be limited to incidence and mortality unless a defensible
count-and-offset model is specified for other measures.

### 5.5 YLL-to-YLD Ratio

Calculate `YLL / YLD` from all-age counts at annual and five-year intervals.
Use counts, not independently age-standardized rates, for the primary ratio.
Identify reversals using both descriptive plots and segmented trend analysis.

Interpret ratios cautiously when YLD estimates are close to zero.

### 5.6 Forecasting to 2030

Forecast age-standardized rates with ARIMA and ETS. Fit Poisson or
negative-binomial count models with population offsets to counts, rather than
fitting Poisson models directly to continuous rates.

Use expanding-window validation with initial windows of 10, 15, and 20 years,
and forecast horizons of 1, 3, and 5 years. Report RMSE, MAE, MAPE, and MASE.
MAPE should not be used when observed values are zero or near zero.

Use the Diebold-Mariano test only for models evaluated on the same forecast
origins and horizon, with an autocorrelation-robust variance estimate. Because
the number of forecast errors is small, treat the test as supporting evidence,
not the sole model-selection criterion. Select the final model using forecast
accuracy, residual diagnostics, stability, and plausibility.

Prediction intervals should combine model uncertainty with GBD estimate
uncertainty. Prefer simulation across GBD draws. Do not treat the published
lower and upper GBD bounds as independent time series.

## 6. Quality-Control Gates

The pipeline must stop with a clear error when any of these checks fail:

1. Required dimensions or years are missing.
2. Point estimates fall outside their uncertainty bounds.
3. Age-specific counts do not approximately sum to all-age counts.
4. T1DM plus T2DM does not approximately equal total diabetes for compatible
   measures and strata.
5. Reconstructed counts materially disagree with GBD counts.
6. Decomposition effects do not sum to the observed change.
7. Forecast residuals show severe unresolved autocorrelation.

All tolerances must be specified in code and reported in a validation log.

## 7. Planned Outputs

### Main Manuscript

* Table 1: SSA endpoint rates and temporal trends
* Table 2: Subregional changes and decomposition
* Table 3: Forecast validation and selected 2030 forecasts
* Figure 1: SSA trends by measure, diabetes type, and sex
* Figure 2: Subregional burden trends
* Figure 3: Decomposition of change
* Figure 4: Age, period, and cohort effects
* Figure 5: YLL-to-YLD transition and forecasts

### Supplement

* Saudi Arabia reproduction results
* Country-level atlas and maps
* Joinpoint segment estimates
* Full forecast sensitivity results
* Data validation report
* Reproducibility and session information

## 8. Immediate Next Dependency

The Saudi Arabia benchmark datasets and WPP 2024 medium population file are
complete. The overall SSA age-standardized-rate extract is also available.

The immediate next downloads are the four-subregion age-standardized rates,
followed by all-age counts and matched age-specific counts and rates for SSA
and the four subregions. Exact request settings and filenames are documented
in `docs/sub_saharan_africa/data_download_checklist.md`.
