# Data access

Source and processed data are intentionally excluded from this public
repository. This prevents redistribution of provider-controlled GBD extracts
and keeps the repository lightweight.

## Required files

After obtaining access through the relevant data providers, create the
following local directories:

```text
data/
  raw/
    gbd_2023/
      sub_saharan_africa/
        ssa_and_subregions_age_standardized_rates_1990_2023.csv
        ssa_and_subregions_all_age_counts_1990_2023.csv
        ssa_and_subregions_age_specific_counts_1990_2023.csv
        ssa_and_subregions_age_specific_rates_1990_2023.csv
    un_wpp_2024/
      WPP2024_PopulationByAge5GroupSex_Medium.csv.gz
```

GBD inputs can be requested through the IHME GBD Results Tool. UN population
data can be obtained from World Population Prospects 2024. The exact GBD query
dimensions and preparation checks are documented in
[`docs/sub_saharan_africa/data_download_checklist.md`](../docs/sub_saharan_africa/data_download_checklist.md).

Do not commit downloaded archives, source extracts, or processed datasets.
The repository's `.gitignore` excludes these paths by default.
