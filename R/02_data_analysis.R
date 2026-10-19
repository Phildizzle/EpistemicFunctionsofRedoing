# ============================================================
# 02 — Data analysis: all results, tables and figures for
#   "Epistemic Functions of Reengagement with Prior Findings:
#    An Exploratory Survey of Computational Communication Researchers"
#
# Input : analysis data prepared by 01_data_import.R
# Output: output/figures/fig1_composite_scores.png         (Figure 1)
#         output/figures/fig2_heatmap.png                  (Figure 2)
#         output/figures/fig3_attitudes_norms_control.png  (Figure 3)
#         output/tables/table2_sample.csv                  (Table 2)
#         output/tables/table3_experience.csv              (Table 3)
#         output/tables/tableA2_pairwise_functions.csv     (Table A2)
#         output/tables/tableA3_pairwise_stages.csv        (Table A3)
#         console output: all statistics reported in the text
#
# Sections follow the Results section of the paper, in the same order
# and with the same headings. Within each section, statistics are
# printed in the order in which they appear in the text.
#   Results 1  Sample description                          -> Table 2
#   Results 2  Perceived relevance of the four epistemic
#              functions (RQ1)                             -> Figure 1, Table A2
#   Results 3  Perceived relevance across research process
#              stages (RQ1)                                -> Figure 2, Table A3
#   Results 4  Personal attitudes, subjective norms, and
#              perceived behavioural control (RQ2)         -> Figure 3
#   Results 5  Differences by prior reproduction or
#              replication experience (RQ3)                -> Table 3
#
# Two PBC items ask about difficulty and are reversed (6 - x) so that
# higher values mean greater ease.
# ============================================================

if (!exists("ds")) source(file.path("R", "01_data_import.R"))

# ============================================================
# RESULTS 1: Sample description (Table 2)
# ============================================================
cat("\n=== RESULTS 1: Sample description (Table 2) ===\n")

freq <- function(codes, map, label) {
  x <- factor(as.character(codes), levels = names(map), labels = map)
  tab <- table(x); tab <- tab[tab > 0]
  data.frame(Characteristic = label, Category = names(tab),
             n = as.integer(tab), pct = round(100 * as.integer(tab) / N, 1))
}

sample_tab <- rbind(
  freq(ds$DM06, c("1"="Master student","2"="PhD researcher","3"="Postdoc",
                  "4"="Research scientist","5"="Assistant professor",
                  "6"="Associate professor","7"="Full professor","8"="Other"),
       "Career stage"),
  freq(ifelse(is.na(ds$DM02), -1, ds$DM02),
       c("1"="Male","2"="Female","3"="Non-binary/Other","-1"="Prefer not to say"),
       "Gender"),
  freq(ds$DM04, c("2"="Master's degree","3"="Doctorate","4"="Other"), "Education"),
  freq(ds$DM13, c("1"="Permanent","2"="Temporary","3"="Other"), "Employment"),
  freq(ds$DM07, c("1"="University","2"="Research institute","3"="Government agency",
                  "4"="NGO","5"="Industry/private","6"="Other"), "Affiliation"),
  freq(ds$ER02, c("1"="Has attempted","2"="Has not attempted"),
       "Reproduction or replication experience"))

# Country: the three largest groups as in Table 2, the rest pooled as "Other"
top <- c("Germany", "USA", "Netherlands")
country_grp <- ifelse(ds$country %in% top | ds$country == "Prefer not to say",
                      ds$country, "Other")
ctab <- table(factor(country_grp, levels = c(top, "Other", "Prefer not to say")))
sample_tab <- rbind(sample_tab,
  data.frame(Characteristic = "Country", Category = names(ctab),
             n = as.integer(ctab), pct = round(100 * as.integer(ctab) / N, 1)))
cat("Countries pooled as 'Other' (Table 2, footnote b):\n")
print(sort(table(ds$country[country_grp == "Other"]), decreasing = TRUE))

cat(sprintf("Age: M = %.1f, SD = %.1f, range = %d-%d, n = %d (%.1f%%)\n",
            mean(ds$age, na.rm = TRUE), sd(ds$age, na.rm = TRUE),
            min(ds$age, na.rm = TRUE), max(ds$age, na.rm = TRUE),
            sum(!is.na(ds$age)), 100 * mean(!is.na(ds$age))))
print(sample_tab, row.names = FALSE)
write.csv(sample_tab, file.path("output", "tables", "table2_sample.csv"), row.names = FALSE)

# ============================================================
# RESULTS 2: Perceived relevance of the four epistemic functions
#            (RQ1; Figure 1, Table A2)
# ============================================================
cat("\n=== RESULTS 2: Perceived relevance of the four epistemic functions ===\n")

# Paragraph 1: Figure 1, composite means, Friedman test, correlations
# Figure 1
df_long <- ds %>%
  select(all_of(fn_labels)) %>%
  pivot_longer(everything(), names_to = "Function", values_to = "Score") %>%
  mutate(Function = factor(Function, levels = fn_labels))
means_ov <- df_long %>% group_by(Function) %>%
  summarise(m = mean(Score), sd = sd(Score), .groups = "drop")

set.seed(1)  # jitter positions
fig1 <- ggplot(df_long, aes(x = Function, y = Score, fill = Function)) +
  geom_boxplot(width = 0.5, outlier.color = "grey40", alpha = 0.85) +
  geom_jitter(width = 0.12, alpha = 0.35, size = 1.8) +
  geom_crossbar(data = means_ov, aes(x = Function, y = m, ymin = m, ymax = m),
                width = 0.5, color = "darkred", linewidth = 0.9) +
  geom_label(data = means_ov,
             aes(x = Function, y = m, label = sprintf("M=%.2f\nSD=%.2f", m, sd)),
             vjust = 0.5, hjust = 0, nudge_x = 0.32, size = 4.5,
             color = "darkred", fontface = "bold", fill = "white",
             label.size = 0, label.padding = unit(0.1, "lines")) +
  scale_fill_manual(values = fn_colors) +
  scale_y_continuous(limits = c(1, 5.6), breaks = 1:5) +
  coord_cartesian(clip = "off") +
  labs(x = NULL) +
  theme_minimal(base_size = 17) +
  theme(legend.position = "none", plot.margin = margin(5, 40, 5, 5))
ggsave(file.path("output", "figures", "fig1_composite_scores.png"),
       fig1, width = 9, height = 5.5, dpi = 300, bg = "white")


for (f in fn_labels) {
  x <- ds[[f]]
  cat(sprintf("%-11s M = %.2f, SD = %.2f, Mdn = %.2f, n = %d\n",
              f, mean(x), sd(x), median(x), sum(!is.na(x))))
}

fn_mat <- as.matrix(ds[, fn_labels])
ft_fn  <- friedman.test(fn_mat)
cat(sprintf("Friedman: chi2(%d) = %.3f, p = %.3f, W = %.3f, n = %d\n",
            ft_fn$parameter, ft_fn$statistic, ft_fn$p.value,
            kendall_w(ft_fn, nrow(fn_mat), 4), nrow(fn_mat)))

cor_mat <- cor(fn_mat)
cat(sprintf("Composite correlations (Pearson): range %.2f-%.2f, mean %.2f\n",
            min(cor_mat[lower.tri(cor_mat)]), max(cor_mat[lower.tri(cor_mat)]),
            mean(cor_mat[lower.tri(cor_mat)])))

# Paragraph 2: within-respondent differentiation and pairwise tests (Table A2)
within_sd <- apply(fn_mat, 1, sd)
spread    <- apply(fn_mat, 1, function(x) diff(range(x)))
cat(sprintf("Within-respondent SD: median = %.2f\n", median(within_sd)))
cat(sprintf("Spread > 0.5: %d of %d (%.1f%%); spread > 1: %d (%.1f%%)\n",
            sum(spread > 0.5), N, 100 * mean(spread > 0.5),
            sum(spread > 1), 100 * mean(spread > 1)))

tabA2 <- run_pairwise(fn_mat, fn_labels)
cat("\nTable A2 (pairwise, Bonferroni):\n")
print(transform(tabA2[, c("A","B","V","p_raw","p_adj","m","r")],
                p_raw = round(p_raw, 4), p_adj = round(p_adj, 3), r = round(r, 3)),
      row.names = FALSE)
write.csv(tabA2[, c("A","B","V","p_raw","p_adj","m","r")],
          file.path("output", "tables", "tableA2_pairwise_functions.csv"), row.names = FALSE)

# ============================================================
# RESULTS 3: Perceived relevance across research process stages
#            (RQ1; Figure 2, Table A3)
# ============================================================
cat("\n=== RESULTS 3: Perceived relevance across research process stages ===\n")

# Paragraph 1: Figure 2 and mean relevance per stage
# Figure 2 (cell means use all available responses per item)
item_means <- expand.grid(Function = fn_labels, Stage = stage_labels,
                          stringsAsFactors = FALSE)
item_means$var  <- mapply(function(f, s) fn_cols[[f]][match(s, stage_labels)],
                          item_means$Function, item_means$Stage)
item_means$Mean <- sapply(item_means$var, function(v) mean(ds[[v]], na.rm = TRUE))
item_means$SD   <- sapply(item_means$var, function(v) sd(ds[[v]], na.rm = TRUE))
item_means$Stage <- factor(item_means$Stage,
  levels = c("Success", "Methodological", "Sampling", "Theoretical"),
  labels = c("Success\nevaluation", "Methodological\nconsiderations",
             "Sampling and\nrepresentation\nconsiderations",
             "Theoretical\nconsiderations"))
item_means$Function <- factor(item_means$Function, levels = fn_labels)
item_means <- item_means %>%
  group_by(Function) %>%
  mutate(value_frac = (Mean - min(Mean)) / (max(Mean) - min(Mean))) %>%
  ungroup() %>%
  mutate(fill_hex = mapply(function(f, v)
           colorspace::lighten(fn_colors[[as.character(f)]], amount = 0.55 * (1 - v)),
           Function, value_frac),
         label_color = ifelse(value_frac > 0.5, "white", "grey20"))

fig2 <- ggplot(item_means, aes(x = Function, y = Stage, fill = fill_hex)) +
  geom_tile(color = "white", linewidth = 0.9) +
  geom_text(aes(label = sprintf("%.2f", Mean), color = label_color),
            size = 5, fontface = "bold", vjust = -0.35) +
  geom_text(aes(label = sprintf("(%.2f)", SD), color = label_color),
            size = 3.3, vjust = 1.5) +
  scale_color_identity() + scale_fill_identity() +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(size = 13, face = "bold"),
        axis.text.y = element_text(size = 13, face = "bold"),
        panel.grid = element_blank(), legend.position = "none")
ggsave(file.path("output", "figures", "fig2_heatmap.png"),
       fig2, width = 9, height = 5, dpi = 300, bg = "white")


stage_cols <- lapply(1:4, function(s) sapply(fn_cols, `[`, s))
names(stage_cols) <- stage_labels
for (s in stage_labels) {
  cat(sprintf("Stage mean, %-15s %.2f\n", s,
              mean(sapply(stage_cols[[s]], function(v) mean(ds[[v]], na.rm = TRUE)))))
}

# Paragraph 2: Friedman tests per function
# Paragraph 3: Bonferroni-corrected pairwise tests (Table A3)
tabA3 <- data.frame()
for (fn in fn_labels) {
  mat <- as.matrix(ds[, fn_cols[[fn]]])
  mat <- mat[complete.cases(mat), , drop = FALSE]
  ft  <- friedman.test(mat)
  cat(sprintf("%-11s Friedman: chi2(%d) = %.3f, p = %.3f, W = %.3f, n = %d\n",
              fn, ft$parameter, ft$statistic, ft$p.value,
              kendall_w(ft, nrow(mat), 4), nrow(mat)))
  tabA3 <- rbind(tabA3, run_pairwise(mat, stage_labels, group_label = fn))
}
cat("\nTable A3 (pairwise within function, Bonferroni):\n")
print(transform(tabA3[, c("Group","A","B","V","p_raw","p_adj","m","r")],
                p_raw = round(p_raw, 4), p_adj = round(p_adj, 3), r = round(r, 3)),
      row.names = FALSE)
write.csv(tabA3[, c("Group","A","B","V","p_raw","p_adj","m","r")],
          file.path("output", "tables", "tableA3_pairwise_stages.csv"), row.names = FALSE)

# ============================================================
# RESULTS 4: Personal attitudes, subjective norms, and perceived
#            behavioural control (RQ2; Figure 3)
# ============================================================
cat("\n=== RESULTS 4: Personal attitudes, subjective norms, and perceived behavioural control ===\n")

# Paragraphs 1-3: item means for attitudes, subjective norms and PBC (Figure 3)

item_spec <- data.frame(
  code = c("PB02_01","PB02_03","PB02_04","PB02_02",
           "PB03_07","PB03_06","PB03_08","PB03_10","PB03_09","PB03_05",
           "PB04_03","PB04_02","PB04_04","PB04_06"),
  Item = c("Repl./repr. are important\nin Communication Science",
           "Repl./repr. add value even if\nfindings are not replicated",
           "Willing to put in extra effort\nto make my research repr.",
           "Repl./repr. can enhance\nmy academic recognition",
           "Repl./repr. work is valued\nin my research community",
           "Researchers in Comm. Science\nwould expect it of me",
           "Journals/conferences I submit to\nexpect repl./repr. research",
           "Funding bodies I apply to\nexpect repl./repr. research",
           "My university or research institute\nexpects repl./repr. research",
           "Researchers in Comm. Science\naim to conduct repl./repr. studies",
           "Capable of making my research\nrepl./repr. for others",
           "Find it easy to document\nand share code (reverse-coded)",
           "Have the knowledge to make\nmy research repl./repr.",
           "Find it easy to document\nand share data (reverse-coded)"),
  Category = c(rep("Personal Attitude", 4), rep("Perceived Field Norms", 6),
               rep("Perceived Behavioural Control", 4)),
  reverse = c(rep(FALSE, 11), TRUE, FALSE, TRUE),
  stringsAsFactors = FALSE)

item_spec$Mean <- mapply(function(cc, rev) {
  m <- mean(ds[[cc]], na.rm = TRUE); if (rev) 6 - m else m
}, item_spec$code, item_spec$reverse)
item_spec$SD <- sapply(item_spec$code, function(cc) sd(ds[[cc]], na.rm = TRUE))
item_spec$n  <- sapply(item_spec$code, function(cc) sum(!is.na(ds[[cc]])))
print(transform(item_spec[, c("code","Category","Mean","SD","n")],
                Mean = round(Mean, 2), SD = round(SD, 2)), row.names = FALSE)

item_spec$Item <- factor(item_spec$Item, levels = item_spec$Item[order(item_spec$Mean)])

make_panel <- function(data, title, fill_color) {
  ggplot(data, aes(x = Item, y = Mean)) +
    geom_col(width = 0.65, alpha = 0.88, fill = fill_color) +
    geom_hline(yintercept = 3, color = "grey40", linewidth = 0.7) +
    geom_text(aes(label = sprintf("%.2f (%.2f)", Mean, SD)),
              hjust = -0.12, size = 5, fontface = "bold") +
    scale_y_continuous(limits = c(0, 5.7), breaks = 1:5, expand = c(0, 0)) +
    coord_flip() +
    labs(x = NULL, y = NULL, title = title) +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold", size = 18, hjust = 0),
          axis.text.y = element_text(size = 13, hjust = 1),
          axis.text.x = element_text(size = 13),
          axis.ticks.y = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major.y = element_blank(),
          plot.margin = margin(t = 15, b = 15, l = 5, r = 15))
}
fig3 <- (make_panel(filter(item_spec, Category == "Personal Attitude"),
                    "Personal Attitudes", "#1a9850") /
         make_panel(filter(item_spec, Category == "Perceived Field Norms"),
                    "Subjective Norms", "#d73027") /
         make_panel(filter(item_spec, Category == "Perceived Behavioural Control"),
                    "Perceived Behavioural Control", "#4575b4")) +
  plot_layout(heights = c(4, 6, 4)) &
  labs(x = NULL, y = "Mean agreement (1–5)") &
  theme(axis.title.x = element_text(size = 13, face = "bold", margin = margin(t = 10)))
ggsave(file.path("output", "figures", "fig3_attitudes_norms_control.png"),
       fig3, width = 9, height = 12, dpi = 300, bg = "white")

# Paragraph 4: desired vs expected replication rate
ok <- !is.na(ds$RC03_01) & !is.na(ds$RC04_01)
wt <- wilcox.test(ds$RC03_01[ok], ds$RC04_01[ok], paired = TRUE, exact = FALSE)
eff <- rb_signed_rank(ds$RC03_01[ok], ds$RC04_01[ok])
cat(sprintf(paste0("\nReplication rate (n = %d): desired M = %.1f%% (SD = %.1f), ",
                   "expected M = %.1f%% (SD = %.1f)\n",
                   "Wilcoxon signed-rank: V = %.0f, p = %.2g, r = %.3f\n"),
            sum(ok), mean(ds$RC03_01[ok]), sd(ds$RC03_01[ok]),
            mean(ds$RC04_01[ok]), sd(ds$RC04_01[ok]),
            wt$statistic, wt$p.value, eff$r))

# ============================================================
# RESULTS 5: Differences by prior reproduction or replication
#            experience (RQ3; Table 3)
# ============================================================
cat("\n=== RESULTS 5: Differences by prior reproduction or replication experience (Table 3) ===\n")

# Paragraphs 1-2 and Table 3: Mann-Whitney U tests by experience group

# Mann-Whitney U; r = 1 - 2U/(n1 n2) (rank-biserial).
# Negative r: the experienced group tends to rate higher. p uncorrected.
experience_test <- function(item, label, block, reverse = FALSE) {
  g1 <- ds[[item]][ds$experienced %in% "Experienced"]
  g2 <- ds[[item]][ds$experienced %in% "Not experienced"]
  g1 <- g1[!is.na(g1)]; g2 <- g2[!is.na(g2)]
  if (reverse) { g1 <- 6 - g1; g2 <- 6 - g2 }
  wt <- wilcox.test(g1, g2, exact = FALSE)
  n1 <- length(g1); n2 <- length(g2)
  data.frame(Block = block, Item = label,
             M_exp = mean(g1), n_exp = n1, M_nonexp = mean(g2), n_nonexp = n2,
             U = as.numeric(wt$statistic), p = wt$p.value,
             r = as.numeric(1 - (2 * wt$statistic) / (n1 * n2)))
}

tab3 <- rbind(
  experience_test("Robustness", "Robustness", "Epistemic functions"),
  experience_test("Precision",  "Precision",  "Epistemic functions"),
  experience_test("Boundary",   "Boundary",   "Epistemic functions"),
  experience_test("Extension",  "Extension",  "Epistemic functions"),
  experience_test("PB02_01", "Importance to field",         "Personal attitudes"),
  experience_test("PB02_02", "Academic recognition",        "Personal attitudes"),
  experience_test("PB02_03", "Value regardless of outcome", "Personal attitudes"),
  experience_test("PB02_04", "Importance despite effort",   "Personal attitudes"),
  experience_test("PB03_05", "Field aims to be repl./repr.",            "Subjective norms"),
  experience_test("PB03_06", "Field expects repl./repr.",               "Subjective norms"),
  experience_test("PB03_07", "Community values repl./repr.",            "Subjective norms"),
  experience_test("PB03_08", "Journals/conferences expect repl./repr.", "Subjective norms"),
  experience_test("PB03_09", "University expects repl./repr.",          "Subjective norms"),
  experience_test("PB03_10", "Funders expect repl./repr.",              "Subjective norms"),
  experience_test("PB04_03", "Capable for others", "Perceived behavioural control"),
  experience_test("PB04_02", "Code ease",          "Perceived behavioural control", reverse = TRUE),
  experience_test("PB04_04", "Knowledge",          "Perceived behavioural control"),
  experience_test("PB04_06", "Data ease",          "Perceived behavioural control", reverse = TRUE))

print(transform(tab3, M_exp = round(M_exp, 2), M_nonexp = round(M_nonexp, 2),
                p = round(p, 3), r = round(r, 3)), row.names = FALSE)
write.csv(tab3, file.path("output", "tables", "table3_experience.csv"), row.names = FALSE)

cat("\nDone. Figures in output/figures, tables in output/tables.\n")
