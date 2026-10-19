# Reproduces all results of the paper from the public data and checks
# them against the values reported in the paper.
#
#   Rscript run_all.R
#
# Steps:
#   R/01_data_import.R    load data/survey_public.csv, build variables
#   R/02_data_analysis.R  all results, tables and figures, in the order
#                         of the Results section
#   tests/check_results.R compare with the values in the paper

dir.create(file.path("output", "logs"), recursive = TRUE, showWarnings = FALSE)

sink(file.path("output", "logs", "results.txt"), split = TRUE)
source(file.path("R", "01_data_import.R"))
source(file.path("R", "02_data_analysis.R"))
sink()

source(file.path("tests", "check_results.R"))
