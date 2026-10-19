# ============================================================
# 01 — Data import and preparation
#
# Loads the public survey data and builds all analysis variables:
#   - "don't know" (-1) and "no answer" (-9) are set to missing
#   - the 16 epistemic-function items are mapped to function x stage
#   - function composites = mean of the available stage items
#   - reproduction/replication experience groups
# Also defines the helper functions used in 02_data_analysis.R.
#
# Input: data/survey_public.csv (see data/codebook.md)
# ============================================================

# Locate the repository folder, so the scripts also work when they are
# opened directly in RStudio and run line by line.
find_repo <- function() {
  has_data <- function(d) file.exists(file.path(d, "data", "survey_public.csv"))
  candidates <- c(".", "..")
  # In RStudio: use the location of the script that is currently open
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    script <- tryCatch(rstudioapi::getSourceEditorContext()$path, error = function(e) "")
    if (nzchar(script)) candidates <- c(candidates, dirname(dirname(script)), dirname(script))
  }
  for (d in candidates) if (has_data(d)) return(normalizePath(d))
  stop("Data not found. Open reengagement-survey.Rproj in RStudio, or set the ",
       "working directory to the repository folder, e.g.\n",
       "  setwd(\"path/to/reengagement-survey-repo\")")
}
setwd(find_repo())

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(patchwork)
  library(colorspace)
})

dir.create(file.path("output", "figures"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path("output", "tables"),  recursive = TRUE, showWarnings = FALSE)

# ============================================================
# Data loading and variable construction
# ============================================================

ds <- read.csv(file.path("data", "survey_public.csv"),
               stringsAsFactors = FALSE, na.strings = "")
N  <- nrow(ds)
cat(sprintf("N respondents: %d\n", N))

clean_num <- function(x) { x <- as.numeric(x); x[x < 0] <- NA; x }

# Treat "don't know" (-1) as missing in all rating items, once, up front.
rating_items <- grep("^(PS0[1-4]|PB0[2-4])_|^RC0[34]_01$", names(ds), value = TRUE)
for (v in rating_items) ds[[v]] <- clean_num(ds[[v]])

# Epistemic-function items: function x stage
# (item wording: see Table A1 in the paper)
ds$Rob_Sam <- ds$PS01_10; ds$Pre_Sam <- ds$PS01_09
ds$Bou_Sam <- ds$PS01_15; ds$Ext_Sam <- ds$PS01_13
ds$Rob_Met <- ds$PS02_02; ds$Pre_Met <- ds$PS02_01
ds$Bou_Met <- ds$PS02_03; ds$Ext_Met <- ds$PS02_04
ds$Rob_Suc <- ds$PS03_02; ds$Pre_Suc <- ds$PS03_03
ds$Bou_Suc <- ds$PS03_04; ds$Ext_Suc <- ds$PS03_01
ds$Rob_The <- ds$PS04_01; ds$Pre_The <- ds$PS04_06
ds$Bou_The <- ds$PS04_02; ds$Ext_The <- ds$PS04_03

fn_cols <- list(
  Robustness = c("Rob_Sam","Rob_Met","Rob_Suc","Rob_The"),
  Precision  = c("Pre_Sam","Pre_Met","Pre_Suc","Pre_The"),
  Boundary   = c("Bou_Sam","Bou_Met","Bou_Suc","Bou_The"),
  Extension  = c("Ext_Sam","Ext_Met","Ext_Suc","Ext_The"))
fn_labels    <- names(fn_cols)
stage_labels <- c("Sampling","Methodological","Success","Theoretical")

# Composite = mean of available stage items (5 respondents miss one item;
# no composite rests on fewer than three items, see note to Figure 1)
for (f in fn_labels) ds[[f]] <- rowMeans(ds[, fn_cols[[f]]], na.rm = TRUE)

# Reproduction/replication experience (ER02: 1 = yes, 2 = no)
ds$experienced <- ifelse(ds$ER02 == 1, "Experienced",
                  ifelse(ds$ER02 == 2, "Not experienced", NA))

fn_colors <- c(Robustness = "#66c2a5", Precision = "#fc8d62",
               Boundary   = "#8da0cb", Extension = "#e78ac3")

# ------------------------------------------------------------
# Effect sizes
# ------------------------------------------------------------
# Matched-pairs rank-biserial correlation for the Wilcoxon signed-rank
# test: r = 2V / [m(m+1)/2] - 1, where m = number of NON-ZERO
# differences (wilcox.test drops zero differences before computing V).
# Positive r: the first variable tends to be higher.
rb_signed_rank <- function(x, y) {
  d <- x - y
  d <- d[!is.na(d) & d != 0]
  m <- length(d)
  if (m == 0) return(list(r = NA_real_, m = 0L, V = NA_real_))
  rk <- rank(abs(d))
  V  <- sum(rk[d > 0])
  list(r = 2 * V / (m * (m + 1) / 2) - 1, m = m, V = V)
}

# Bonferroni-corrected pairwise Wilcoxon signed-rank tests
run_pairwise <- function(mat, labels, group_label = NA) {
  pairs <- combn(ncol(mat), 2)
  out <- data.frame()
  for (i in seq_len(ncol(pairs))) {
    a <- pairs[1, i]; b <- pairs[2, i]
    x <- mat[, a]; y <- mat[, b]
    wt  <- wilcox.test(x, y, paired = TRUE, exact = FALSE)
    eff <- rb_signed_rank(x, y)
    stopifnot(abs(eff$V - as.numeric(wt$statistic)) < 1e-6)
    out <- rbind(out, data.frame(
      Group = group_label, A = labels[a], B = labels[b],
      V = as.numeric(wt$statistic), p_raw = wt$p.value,
      m = eff$m, r = eff$r, stringsAsFactors = FALSE))
  }
  out$p_adj <- pmin(1, out$p_raw * nrow(out))
  out
}

kendall_w <- function(ft, n, k) as.numeric(ft$statistic / (n * (k - 1)))

