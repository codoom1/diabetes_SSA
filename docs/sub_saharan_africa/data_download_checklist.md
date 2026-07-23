# SSA Data Download Guide

> **Public repository note:** GBD, UN WPP, and derived data files are not
> distributed with this repository. A status of “Complete” below records the
> datasets used to produce the included report and outputs; it does not mean
> those datasets are present in a fresh clone. Download them from the original
> providers and place them according to `data/README.md`.

Use this guide when downloading the remaining data from the GBD 2023 Results
Tool. Complete Stage 2 before downloading the much larger country-level files.

## 1. Data Already Available

Do not download these again:

| Dataset | Status | File |
|---|---|---|
| Saudi Arabia benchmark data | Complete | `data/raw/gbd_2023/saudi_arabia/` |
| SSA and subregional age-standardized rates | Complete | `data/raw/gbd_2023/sub_saharan_africa/ssa_and_subregions_age_standardized_rates_1990_2023.csv` |
| SSA and subregional all-age counts | Complete | `data/raw/gbd_2023/sub_saharan_africa/ssa_and_subregions_all_age_counts_1990_2023.csv` |
| SSA and subregional age-specific counts | Complete | `data/raw/gbd_2023/sub_saharan_africa/ssa_and_subregions_age_specific_counts_1990_2023.csv` |
| SSA and subregional age-specific rates | Complete | `data/raw/gbd_2023/sub_saharan_africa/ssa_and_subregions_age_specific_rates_1990_2023.csv` |
| UN WPP 2024 medium population | Complete | `data/raw/un_wpp_2024/WPP2024_PopulationByAge5GroupSex_Medium.csv.gz` |

The three completed Stage 2 files each contain overall SSA and all four
subregions for 1990-2023. They passed checks for expected dimensions,
duplicate analytical rows, and valid uncertainty bounds where applicable.

### Age-Specific Count Downloads Combined

The following original ZIP files were checked, combined into the canonical
Request 3 CSV, and then deleted from `data/`. Each ZIP contained one CSV plus
`citation.txt`, covered 1990-2023, used metric `Number`, and contained the
three diabetes causes.

| ZIP | CSV inside | Location and sex coverage | Measures | Age groups | Rows |
|---|---|---|---|---:|---:|
| `data/IHME-GBD_2023_DATA-2cedf9f5-1.zip` | `IHME-GBD_2023_DATA-2cedf9f5-1.csv` | Overall SSA: Male, Female, Both | Deaths, DALYs, YLDs, YLLs, Prevalence, Incidence | 25 | 43,452 |
| `data/IHME-GBD_2023_DATA-52417b6d-1.zip` | `IHME-GBD_2023_DATA-52417b6d-1.csv` | Central SSA: Male, Female, Both | Deaths, DALYs, YLDs, YLLs, Prevalence, Incidence | 25 | 43,452 |
| `data/IHME-GBD_2023_DATA-74d1caf5-1.zip` | `IHME-GBD_2023_DATA-74d1caf5-1.csv` | Western SSA: Male and Female | Deaths only | 23 | 4,284 |
| `data/IHME-GBD_2023_DATA-22c6ccfe-1.zip` | `IHME-GBD_2023_DATA-22c6ccfe-1.csv` | Western SSA: Male and Female | DALYs, YLDs, YLLs, Prevalence, Incidence | 25 | 24,684 |
| `data/IHME-GBD_2023_DATA-388c3be0-1.zip` | `IHME-GBD_2023_DATA-388c3be0-1.csv` | Western SSA: Both | Deaths, DALYs, YLDs, YLLs, Prevalence, Incidence | 25 | 14,484 |
| `data/IHME-GBD_2023_DATA-f97c70c1-1.zip` | `IHME-GBD_2023_DATA-f97c70c1-1.csv` | Eastern SSA: Male, Female, Both | Deaths, DALYs, YLDs, YLLs, Prevalence, Incidence | 25 | 43,452 |
| `data/IHME-GBD_2023_DATA-308696d7-1.zip` | `IHME-GBD_2023_DATA-308696d7-1.csv` | Southern SSA: Male, Female, Both | Deaths, DALYs, YLDs, YLLs, Prevalence, Incidence | 25 | 43,452 |

Together, these ZIPs provided complete age-specific count coverage for overall
SSA and all four SSA subregions. They have been combined into:

```text
data/raw/gbd_2023/sub_saharan_africa/ssa_and_subregions_age_specific_counts_1990_2023.csv
```

The combined file contains 217,260 rows, all 15 location-sex combinations, the
25 required age groups, and no duplicate analytical rows. The deleted ZIPs did
not provide any age-specific rates.

GBD does not report Deaths and YLLs for every neonatal age-measure combination.
For example, the Western Deaths ZIP has 23 age groups rather than 25 because
the two neonatal Deaths groups are absent. This expected structural absence is
already reflected in the usable row totals.

## 2. Settings Used in Every GBD Request

Use the **GBD 2023 Results Tool** and keep these selections identical across
all remaining requests:

| Field | Select |
|---|---|
| Context | Cause |
| Years | `1990` through `2023`, all years |
| Sex | `Male`, `Female`, `Both` |
| Causes | `Diabetes mellitus`, `Diabetes mellitus type 1`, `Diabetes mellitus type 2` |
| Measures | `Prevalence`, `Incidence`, `Deaths`, `DALYs`, `YLLs`, `YLDs` |
| Population | `All Population` |

For every completed request:

1. Download the result ZIP or CSV.
2. Download or retain the accompanying citation and request-settings file.
3. Do not rename or delete the original download before it is checked.
4. Tell Codex that the download has finished so it can validate, extract, and
   assign the final filename.

## 3. Stage 2 Downloads: Complete These First

Stage 2 covers overall SSA and its four subregions:

* `Sub-Saharan Africa`
* `Central Sub-Saharan Africa`
* `Eastern Sub-Saharan Africa`
* `Southern Sub-Saharan Africa`
* `Western Sub-Saharan Africa`

Requests 1, 2, 3, and 4 are complete.

### Request 1: Subregional Age-Standardized Rates

**Status: Complete**

Purpose: subregional trends, endpoint comparisons, and rate forecasts.

| Field | Select |
|---|---|
| Location | Four SSA subregions only |
| Age | `Age-standardized` |
| Metric | `Rate` |

Final filename:

```text
ssa_and_subregions_age_standardized_rates_1990_2023.csv
```

### Request 2: SSA and Subregional All-Age Counts

**Status: Complete**

Purpose: headline burden totals, YLL-to-YLD ratios, and validation of summed
age-specific counts.

| Field | Select |
|---|---|
| Location | Overall SSA plus four SSA subregions |
| Age | `All ages` |
| Metric | `Number` |

Final filename:

```text
ssa_and_subregions_all_age_counts_1990_2023.csv
```

### Request 3: SSA and Subregional Age-Specific Counts

**Status: Complete**

Purpose: decomposition, age-period-cohort analysis, population reconstruction,
and count-based forecasts.

| Field | Select |
|---|---|
| Location | Overall SSA plus four SSA subregions |
| Age | The 25 mutually exclusive individual age groups listed below |
| Metric | `Number` |

Select exactly:

```text
0-6 days
7-27 days
1-5 months
6-11 months
12-23 months
2-4 years
5-9 years
10-14 years
15-19 years
20-24 years
25-29 years
30-34 years
35-39 years
40-44 years
45-49 years
50-54 years
55-59 years
60-64 years
65-69 years
70-74 years
75-79 years
80-84 years
85-89 years
90-94 years
95+ years
```

Do not select:

* `All ages`
* `Age-standardized`
* `<5 years`
* Any other overlapping aggregate age group

Final filename:

```text
ssa_and_subregions_age_specific_counts_1990_2023.csv
```

Current usable coverage:

| Location | Male | Female | Both |
|---|:---:|:---:|:---:|
| Sub-Saharan Africa | Complete | Complete | Complete |
| Central Sub-Saharan Africa | Complete | Complete | Complete |
| Eastern Sub-Saharan Africa | Complete | Complete | Complete |
| Southern Sub-Saharan Africa | Complete | Complete | Complete |
| Western Sub-Saharan Africa | Complete | Complete | Complete |

No more age-specific count downloads are needed.

Final size after retaining only the 25 required ages is 217,260 rows.

### Request 4: SSA and Subregional Age-Specific Rates

**Status: Complete**

Purpose: matched denominators, decomposition, age-period-cohort analysis, and
internal consistency checks.

Use exactly the same locations, years, sexes, causes, measures, and 25 ages as
Request 3. Change only:

| Field | Select |
|---|---|
| Metric | `Rate` |

Final filename:

```text
ssa_and_subregions_age_specific_rates_1990_2023.csv
```

The following original ZIP files are present in `data/` and were validated on
2026-07-11. Each contains one CSV plus `citation.txt`, uses metric `Rate`, and
covers 1990-2023, all three sexes, all three diabetes causes, all six measures,
and the 25 required age groups.

| ZIP | Location | Rows | Validation |
|---|---|---:|---|
| `data/IHME-GBD_2023_DATA-f4602470-1.zip` | Sub-Saharan Africa | 43,452 | Passed |
| `data/IHME-GBD_2023_DATA-347c5508-1.zip` | Central Sub-Saharan Africa | 43,452 | Passed |
| `data/IHME-GBD_2023_DATA-7e712d5c-1.zip` | Eastern Sub-Saharan Africa | 43,452 | Passed |
| `data/IHME-GBD_2023_DATA-91b6acab-1.zip` | Southern Sub-Saharan Africa | 43,452 | Passed |
| `data/IHME-GBD_2023_DATA-b5d00860-1.zip` | Western Sub-Saharan Africa | 45,288 downloaded; 43,452 retained | Passed after excluding `20-54 years` |

Together, the five ZIPs contain 217,260 usable rows. They have no duplicate
analytical rows, missing estimate bounds, or invalid uncertainty-bound order.
The Western SSA ZIP also contained 1,836 rows for the overlapping aggregate
age group `20-54 years`; these were excluded from the canonical file. The five
validated parts have been combined into:

```text
data/raw/gbd_2023/sub_saharan_africa/ssa_and_subregions_age_specific_rates_1990_2023.csv
```

Current usable coverage:

| Location | Male | Female | Both |
|---|:---:|:---:|:---:|
| Sub-Saharan Africa | Complete | Complete | Complete |
| Central Sub-Saharan Africa | Complete | Complete | Complete |
| Eastern Sub-Saharan Africa | Complete | Complete | Complete |
| Southern Sub-Saharan Africa | Complete | Complete | Complete |
| Western Sub-Saharan Africa | Complete | Complete | Complete |

No more Stage 2 downloads are needed.

## 4. If the GBD Tool Reaches Its Limit

Do not remove measures, causes, sexes, years, or age groups from the scientific
scope. Split a large request into parts and retain the same settings otherwise.

Preferred splitting order:

1. Split by metric: counts and rates must always remain separate.
2. Split locations into batches.
3. Split measures into batches only if location batches are still too large.

Suggested location batches for Request 4:

```text
Batch A: Sub-Saharan Africa
Batch B: Central and Eastern Sub-Saharan Africa
Batch C: Southern and Western Sub-Saharan Africa
```

Add `_part_a`, `_part_b`, or `_part_c` to temporary filenames. Codex will
combine and validate the parts after download.

### Current Additional-Row Requirement

No additional rows are needed. Stage 2 is complete.

## 5. Optional Stage 3 Downloads: Country-Level Atlas

This stage is optional and is not required for the primary SSA and
subregional analysis. Begin it only if a country-level comparative atlas is
needed and after all four Stage 2 requests pass validation.

Repeat the same four request types for every individual SSA country:

1. Country age-standardized rates
2. Country all-age counts
3. Country age-specific counts
4. Country age-specific rates

Country-level age-specific files will be large. Download countries in
manageable location batches and keep matching count and rate batches organized
identically. A country-to-GBD-subregion crosswalk must also be retained or
downloaded from the GBD location hierarchy before the country atlas is built.

## 6. Population and Additional Data

No additional UN population file is needed. The existing WPP file contains
annual five-year-age population estimates and medium projections through 2100.

Historical GBD population denominators will be reconstructed from matched
age-specific counts and rates. WPP populations will be used only for future
projections and sensitivity analyses.

GBD draws would improve uncertainty propagation but are not required to begin
the main analysis. If the Results Tool offers downloadable draws for these
estimates, retain them as an optional later request.

## 7. Current Download Order

Complete the remaining Stage 2 work in this order:

- [x] Request 1: Subregional age-standardized rates
- [x] Request 2: SSA and subregional all-age counts
- [x] Request 3A: Overall SSA age-specific counts, all three sexes
- [x] Request 3B: Central SSA age-specific counts, all three sexes
- [x] Request 3C: Eastern SSA age-specific counts, all three sexes
- [x] Request 3D: Southern SSA age-specific counts, all three sexes
- [x] Request 3E: Western SSA age-specific counts, Male and Female
- [x] Request 3F: Western SSA age-specific counts, Both sex only
- [x] Ask Codex to combine and validate Request 3
- [x] Request 4A: Overall SSA age-specific rates, all three sexes
- [x] Request 4B: Central SSA age-specific rates, all three sexes
- [x] Request 4C: Eastern SSA age-specific rates, all three sexes
- [x] Request 4D: Southern SSA age-specific rates, all three sexes
- [x] Request 4E: Western SSA age-specific rates, all three sexes
- [x] Confirm each downloaded Request 4 part has a citation record
- [x] Ask Codex to check and organize the new downloads

Stop after Stage 2. The files will be validated before the country-level
downloads begin.
