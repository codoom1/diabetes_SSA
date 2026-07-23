# Project Structure

The active analysis workflow is centered on the Sub-Saharan Africa report.
Saudi Arabia materials are retained only as background documentation and source
data, not as active analysis scripts.

## Data

* `data/README.md`: data-access and local file-placement instructions
* `data/raw/gbd_2023/sub_saharan_africa/`: local GBD inputs (not committed)
* `data/raw/un_wpp_2024/`: local UN population inputs (not committed)
* `data/processed/`: optional local processed files (not committed)

Source extracts, original archives, and processed datasets are excluded from
the public repository. They must be obtained from their providers and stored
locally in the paths above before the report is rendered.

## Analysis Code

* `reports/sub_saharan_africa_full_analysis.Rmd`: active SSA analysis report
* `scripts/common/report_helpers.R`: shared helper functions used by the active report

## Outputs

* `outputs/sub_saharan_africa/full_analysis/`: active SSA tables and figures
* `rendered/sub_saharan_africa_full_analysis.pdf`: rendered report

## Documentation

* `docs/saudi_arabia/`: local benchmark article and notes (article not committed)
* `docs/sub_saharan_africa/`: SSA protocol and implementation plan
* `docs/common/`: shared project standards and documentation
