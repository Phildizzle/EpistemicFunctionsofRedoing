# Compares the recomputed results with the values printed in the paper.
# Run after R/02_data_analysis.R (run_all.R does this automatically).

paper <- list(
  # Table 2
  list("Germany n",              sum(ds$country == "Germany"), 36, 0),
  list("Other countries n",      sum(country_grp == "Other"), 9, 0),
  list("Age M",                  mean(ds$age, na.rm = TRUE), 39.3, 1),
  list("Age SD",                 sd(ds$age, na.rm = TRUE), 11.3, 1),
  list("Age n",                  sum(!is.na(ds$age)), 48, 0),
  # Figure 1 / Section "Perceived relevance"
  list("Robustness composite M", mean(ds$Robustness), 3.77, 2),
  list("Precision composite M",  mean(ds$Precision),  3.89, 2),
  list("Boundary composite M",   mean(ds$Boundary),   3.69, 2),
  list("Extension composite M",  mean(ds$Extension),  3.82, 2),
  list("Friedman overall chi2",  as.numeric(ft_fn$statistic), 8.035, 3),
  list("Friedman overall W",     kendall_w(ft_fn, N, 4), 0.040, 3),
  list("Mean composite r",       mean(cor_mat[lower.tri(cor_mat)]), 0.42, 2),
  list("Median within-resp. SD", median(within_sd), 0.38, 2),
  # Table A2 / A3 (selected rows)
  list("A2 Precision vs Boundary p_adj",
       tabA2$p_adj[tabA2$A == "Precision" & tabA2$B == "Boundary"], 0.176, 3),
  list("A3 Precision Sam-Met r",
       tabA3$r[tabA3$Group == "Precision" & tabA3$A == "Sampling" & tabA3$B == "Methodological"], -0.467, 3),
  list("A3 Boundary Sam-Suc r",
       tabA3$r[tabA3$Group == "Boundary" & tabA3$A == "Sampling" & tabA3$B == "Success"], -0.551, 3),
  list("A3 Extension Sam-The r",
       tabA3$r[tabA3$Group == "Extension" & tabA3$A == "Sampling" & tabA3$B == "Theoretical"], 0.643, 3),
  # Figure 3 / RQ2
  list("Academic recognition M", mean(ds$PB02_02, na.rm = TRUE), 3.32, 2),
  list("Community values M",     mean(ds$PB03_07, na.rm = TRUE), 3.21, 2),
  list("Data ease M (reversed)", 6 - mean(ds$PB04_06, na.rm = TRUE), 3.12, 2),
  # The paper's draft reported 53.6% and 15.2%, computed from the raw
  # slider codes (1-101). Correct percentages are one point lower.
  list("Desired replication %",  mean(ds$RC03_01[ok]), 52.6, 1),
  list("Expected replication %", mean(ds$RC04_01[ok]), 14.2, 1),
  list("Replication-rate r",     eff$r, 0.956, 3),
  # Table 3 (selected rows)
  list("T3 Community values U",  tab3$U[tab3$Item == "Community values repl./repr."], 381.5, 1),
  list("T3 University p",        tab3$p[tab3$Item == "University expects repl./repr."], 0.082, 3),
  list("T3 Boundary r",          tab3$r[tab3$Item == "Boundary"], -0.259, 3)
)

res <- do.call(rbind, lapply(paper, function(x)
  data.frame(check = x[[1]], recomputed = round(x[[2]], x[[4]]), paper = x[[3]])))
res$ok <- abs(res$recomputed - res$paper) < 1e-9

cat("\n=== Check against values reported in the paper ===\n")
print(res, row.names = FALSE)
if (all(res$ok)) {
  cat("\nAll checks passed.\n")
} else {
  stop(sprintf("%d check(s) failed.", sum(!res$ok)))
}
