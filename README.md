# Diabetes Burden in Sub-Saharan Africa

This repository contains a reproducible R analysis of the diabetes burden in
Sub-Saharan Africa (SSA) using Global Burden of Disease (GBD) 2023 estimates.
It describes regional and subregional trends from 1990 to 2023 and projects
age-standardized rates through 2030.

## Study scope

The analysis covers SSA overall and its Central, Eastern, Southern, and Western
subregions. Results are evaluated by sex and for total diabetes, type 1
diabetes, and type 2 diabetes across the following outcomes:

- Prevalence
- Incidence
- Deaths
- Disability-adjusted life years (DALYs)
- Years of life lost (YLLs)
- Years lived with disability (YLDs)

The workflow produces:

- Trends in age-standardized rates and all-age counts
- Sex comparisons and diabetes-type composition
- YLL-to-YLD ratios
- Symmetric decomposition of changes into population growth, population aging,
  and epidemiological rate effects
- Age-specific patterns and age-adjusted temporal drift
- ARIMA, ETS, and LSTM forecast comparisons and projections through 2030
- Publication-ready figures, tables, and a PDF report

## Repository structure

```text
data/
  README.md                    Data-access and local placement instructions
docs/
  common/                      Project and figure standards
  sub_saharan_africa/          Study protocol and implementation plan
  saudi_arabia/                Background benchmark materials
reports/
  sub_saharan_africa_full_analysis.Rmd
scripts/
  common/report_helpers.R      Cleaning, validation, modeling, and plotting helpers
outputs/
  sub_saharan_africa/full_analysis/
    figures/                   Publication figures
    tables/                    Machine-readable results
rendered/
  sub_saharan_africa_full_analysis.pdf
```

## Data

The source and processed datasets are not included in this repository. The main
epidemiological inputs are GBD 2023 extracts for 1990–2023. After obtaining
access from the original providers, place these files in
`data/raw/gbd_2023/sub_saharan_africa/`:

- `ssa_and_subregions_age_standardized_rates_1990_2023.csv`
- `ssa_and_subregions_all_age_counts_1990_2023.csv`
- `ssa_and_subregions_age_specific_counts_1990_2023.csv`
- `ssa_and_subregions_age_specific_rates_1990_2023.csv`

Place the UN World Population Prospects 2024 population file under
`data/raw/un_wpp_2024/`. See [`data/README.md`](data/README.md) for the expected
local layout. Users are responsible for complying with the original data
providers' access, citation, and redistribution requirements.

## Reproducing the analysis

The project uses [`renv`](https://rstudio.github.io/renv/) to record its R
package environment. From the repository root:

```r
install.packages("renv")
renv::restore()
rmarkdown::render("reports/sub_saharan_africa_full_analysis.Rmd")
```

Rendering the PDF requires a LaTeX distribution with XeLaTeX. The report writes
derived CSV tables and PNG figures to
`outputs/sub_saharan_africa/full_analysis/`. The compiled report is also
available at `rendered/sub_saharan_africa_full_analysis.pdf`.

## Interpretation notes

GBD uncertainty intervals are reported as uncertainty intervals, not confidence
intervals. Forecast intervals represent model uncertainty and do not propagate
GBD estimation uncertainty unless draws are incorporated. Age-adjusted drift
estimates are descriptive temporal trends and should not be interpreted as a
fully identified age-period-cohort decomposition.

## Data citation

Analyses use the *Global Burden of Disease Study 2023 (GBD 2023) Results*
produced by the Global Burden of Disease Collaborative Network, Institute for
Health Metrics and Evaluation (IHME), Seattle, United States, 2024. Consult the
GBD Results Tool for the required citation and terms associated with each
download. Population projections use the United Nations *World Population
Prospects 2024*.

## Documentation

See the study protocol in
[`docs/sub_saharan_africa/SSA_Diabetes_trend.md`](docs/sub_saharan_africa/SSA_Diabetes_trend.md)
and the implementation plan in
[`docs/sub_saharan_africa/SSA_analysis_implementation_plan.md`](docs/sub_saharan_africa/SSA_analysis_implementation_plan.md).
