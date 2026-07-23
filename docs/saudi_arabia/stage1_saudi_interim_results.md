# Stage 1: Saudi Arabia Interim Results

## Analysis Status

The Stage 1 benchmark analysis uses four GBD 2023 analytical datasets:

* Age-standardized rates
* All-age counts
* Age-specific counts
* Age-specific rates

All datasets contain complete annual observations from 1990 through 2023 for
all six measures, three diabetes causes, and three sex groups. The age-specific
datasets contain 25 mutually exclusive age groups. No duplicate analytical
rows, missing values, or invalid uncertainty intervals were found.

Age-specific counts reproduce the GBD all-age counts within numerical
precision. Count/rate pairs imply internally consistent GBD population
denominators.

The Saudi Stage 1 benchmark and data-pipeline validation are complete. Formal
joinpoint and age-period-cohort models will be implemented once as shared
methods for the primary SSA analysis rather than maintained as Saudi-only
code. They are not required before proceeding with the Stage 2 data downloads.

## Benchmark Reproduction

The extracts reproduce the published Saudi Arabia benchmark findings:

| Measure | 1990 rate | 2023 rate | Relative change |
|---|---:|---:|---:|
| Prevalence | 10,648.03 | 23,138.32 | 117.3% |
| Incidence | 456.09 | 899.42 | 97.2% |
| Deaths | 25.26 | 58.74 | 132.5% |
| DALYs | 1,243.93 | 2,648.60 | 112.9% |
| YLLs | 530.00 | 1,088.90 | 105.5% |
| YLDs | 713.93 | 1,559.69 | 118.5% |

Rates are age-standardized rates per 100,000 population for both sexes and
total diabetes mellitus.

## Full-Period Trends

Log-linear models showed statistically significant increases in all six
age-standardized rates between 1990 and 2023. Estimated average annual changes
ranged from 2.09% for YLLs to 2.47% for YLDs.

These estimates describe the full-period trend and are not substitutes for
joinpoint APC and AAPC estimates.

## Sex Differences

In 2023, male age-standardized rates exceeded female rates for every measure.
The largest male-to-female rate ratios were observed for:

* Deaths: 1.47
* YLLs: 1.47
* DALYs: 1.29

The male-to-female prevalence rate ratio was 1.19, and the incidence rate ratio
was 1.09.

## Diabetes Type

T2DM accounted for most of the 2023 diabetes burden:

* 98.6% of prevalence
* 99.0% of incidence
* 97.7% of deaths
* 97.8% of DALYs
* 98.8% of YLDs
* 95.3% of YLLs

T1DM and T2DM counts sum to total diabetes counts within numerical rounding.

## Mortality-to-Disability Transition

The all-age YLL-to-YLD ratio declined from 0.57 in 1990 to 0.36 in 2010,
indicating a shift toward disability-dominated burden. It subsequently
increased to 0.38 in 2023, showing a partial reversal but remaining below its
1990 level.

Formal segmented trend analysis is required before concluding that a
statistically significant reversal occurred.

## Decomposition of Change

Symmetric three-factor decomposition was performed using the population
denominators implied by the GBD age-specific count and rate pairs. For both
sexes and total diabetes mellitus, all three drivers contributed materially to
the increase from 1990 to 2023.

| Measure | Population growth | Population aging | Rate change |
|---|---:|---:|---:|
| Prevalence | 35.9% | 22.9% | 41.2% |
| Incidence | 38.8% | 20.6% | 40.6% |
| Deaths | 42.9% | 15.5% | 41.6% |
| DALYs | 38.0% | 22.0% | 40.0% |
| YLLs | 44.1% | 19.2% | 36.7% |
| YLDs | 35.9% | 22.9% | 41.2% |

The decomposition contributions sum to the observed changes within numerical
precision.

## Population Projection Sensitivity

UN World Population Prospects 2024 medium projections were applied to the 2023
GBD age-specific rates to estimate a demographic-only scenario through 2030.
This scenario isolates the effect of projected population growth and aging; it
is not an epidemiological rate forecast.

WPP and GBD-implied Saudi population estimates differ substantially in 1990
but are close in total by 2023. Historical decomposition therefore uses
GBD-implied populations, while WPP is used only for explicitly labeled future
projection and sensitivity analyses.

## Provisional Forecasts Through 2030

Expanding-window validation from 2004 through 2023 was used to compare ARIMA
and ETS models. Models were selected using the lowest MASE within each
reporting stratum.

For both sexes and total diabetes mellitus, the selected models produced the
following 2030 age-standardized rate forecasts:

| Measure | Selected model | 2030 forecast | Model-based 95% interval |
|---|---|---:|---:|
| Prevalence | ARIMA | 26,882.08 | 24,381.32-29,382.85 |
| Incidence | ARIMA | 1,026.78 | 979.69-1,073.87 |
| Deaths | ETS | 44.34 | 18.60-70.08 |
| DALYs | ETS | 2,667.60 | 2,158.69-3,176.51 |
| YLLs | ETS | 851.53 | 412.73-1,290.32 |
| YLDs | ARIMA | 1,775.10 | 1,673.07-1,877.13 |

The forecasts suggest continued increases in prevalence, incidence, and YLDs.
The selected mortality and YLL models project declines, but their wide
intervals indicate substantial uncertainty. These intervals currently reflect
model uncertainty only. They must be updated using GBD draws before final
reporting.

## Reproduction

Run the analyses from the project root:

```bash
Rscript scripts/saudi_arabia/stage1_saudi_descriptive.R
Rscript scripts/saudi_arabia/stage1_saudi_forecast.R
Rscript scripts/saudi_arabia/stage1_saudi_age_specific.R
Rscript scripts/saudi_arabia/stage1_saudi_figure1_reproduction.R
```

Generated tables and figures are stored under `outputs/saudi_arabia/stage1/`.
