# Epistemic Functions of Reengagement with Prior Findings: Data and Code

Data and analysis code for:

> Knöpfle, P. (2026). *Epistemic Functions of Reengagement with Prior Findings: An Exploratory Survey of Computational Communication Researchers.* Manuscript submitted for publication.

The survey (N = 67) asked computational communication researchers how relevant four epistemic functions of reengagement (robustness, precision, boundary, extension) are across four research stages, and measured their attitudes, subjective norms and perceived behavioural control regarding reproductions and replications. Preregistrations: [osf.io/gyvp7](https://osf.io/gyvp7/overview) and [osf.io/abyjc](https://osf.io/abyjc/overview).

## Reproduce the results

### Option 1: Docker (recommended)

Requires [Docker](https://docs.docker.com/get-docker/). From the repository folder:

```bash
docker build -t reengagement-survey .
docker run --rm -v "$(pwd)/output:/project/output" reengagement-survey
```

On Windows PowerShell, use `${PWD}` instead of `$(pwd)`.

The image pins R 4.3.3 and installs package versions from a dated CRAN snapshot (2024-02-01). The run writes all figures and tables to `output/` and ends by checking 26 key values against the numbers reported in the paper.

### Option 2: Local R

With R 4.3 or newer:

Open `reengagement-survey.Rproj` in RStudio (this sets the working directory to the repository folder), then run:

```r
source("install_packages.R")   # installs the verified package versions
source("run_all.R")
```

Without RStudio, set the working directory to the repository folder first, e.g. `setwd("path/to/reengagement-survey-repo")`. Newer package versions will most likely give the same results, but only the versions listed below were verified.

## What produces what

| Results subsection | Paper output | File | Script section |
|---|---|---|---|
| Sample description | Table 2 | `output/tables/table2_sample.csv` | `02_data_analysis.R`, RESULTS 1 |
| Perceived relevance of the four epistemic functions | Figure 1, Table A2 | `output/figures/fig1_composite_scores.png`, `output/tables/tableA2_pairwise_functions.csv` | RESULTS 2 |
| Perceived relevance across research process stages | Figure 2, Table A3 | `output/figures/fig2_heatmap.png`, `output/tables/tableA3_pairwise_stages.csv` | RESULTS 3 |
| Personal attitudes, subjective norms, and perceived behavioural control | Figure 3, replication-rate test | `output/figures/fig3_attitudes_norms_control.png` | RESULTS 4 |
| Differences by prior reproduction or replication experience | Table 3 | `output/tables/table3_experience.csv` | RESULTS 5 |

`02_data_analysis.R` follows the Results section of the paper: same order, same headings, and statistics printed in the order they appear in the text. The console output (also saved to `output/logs/results.txt`) contains every statistic reported in the Results section.

## Repository structure

```
├── R/
│   ├── 01_data_import.R           # loads the data, builds all analysis variables
│   └── 02_data_analysis.R         # all results, structured like the Results section
├── data/
│   ├── survey_public.csv          # analysis data
│   └── codebook.md                # variables, item wording, coding
├── tests/check_results.R          # compares results with the paper
├── output/                        # generated figures, tables, logs
├── run_all.R
├── reengagement-survey.Rproj
├── install_packages.R
└── Dockerfile
```

## Data

`data/survey_public.csv` contains the 67 respondents analysed in the paper and all variables the analyses use (see `data/codebook.md`). Of 132 people who opened the survey, 68 completed it; one withdrew consent. Invitation codes, timestamps, open-text answers and items not analysed in the paper are not included.

## Analysis notes

- `-1` ("don't know") and `-9` (not answered) are treated as missing.
- The replication-rate sliders are stored by the survey platform as 1 to 101; the public file contains them as percentages (0 to 100).
- Function composites are the mean of the available stage items. Five respondents each skipped one item.
- Wilcoxon signed-rank effect sizes are matched-pairs rank-biserial correlations, r = 2V / [m(m+1)/2] − 1, where m is the number of non-zero differences.
- Mann–Whitney effect sizes are r = 1 − 2U / (n₁n₂). A negative r means the experienced group rated higher.
- p-values in Table 3 are uncorrected. Pairwise tests in Tables A2 and A3 are Bonferroni-corrected within each family of six comparisons.

## Verified software environment

R 4.3.3; dplyr 1.1.4, tidyr 1.3.1, ggplot2 3.4.4, patchwork 1.2.0, colorspace 2.1-0. See `output/logs/sessionInfo_verified_run.txt` for the full session.

Figures rendered on another system can differ slightly in fonts and label spacing. The plotted values are identical.

## License

Code: MIT License. Data: CC BY 4.0. See `LICENSE.md`.

## Funding

This work was funded by the Deutsche Forschungsgemeinschaft (DFG) within the priority programme META-REP (SPP 2317), project AutoFrontCCS (464291459).

## Contact

Philipp Knöpfle, Department of Media and Communication, LMU Munich.
