# ============================================================
# 01 — Data preparation and import: build the public data set from the raw SoSci Survey export
#
# Run this ONCE, locally, by the authors only. The raw export is NOT
# part of the public repository (see .gitignore): it contains the
# personalised invitation codes (SERIAL), invitation and response
# timestamps (MAILSENT, STARTED, LASTDATA) and open-text answers,
# which could be linked back to individual respondents.
#
# Input : data/raw/rdata_AutoFrontCCS_2026-07-08_18-21.csv  (not shared)
# Output: data/survey_public.csv                            (shared)
#
# The public file keeps only the variables used in the paper:
#   - demographics (coded): DM02 gender, DM04 education, DM06 career
#     stage, DM07 affiliation, DM08 country, DM13 employment, age
#   - ER02 reproduction/replication experience
#   - PS01-PS04 16 epistemic-function items
#   - PB02-PB04 attitudes, subjective norms, perceived behavioural control
#   - RC03_01 / RC04_01 desired and expected replication rate
# ============================================================

RAW_PATH    <- file.path("data", "raw", "rdata_AutoFrontCCS_2026-07-08_18-21.csv")
PUBLIC_PATH <- file.path("data", "survey_public.csv")

# Disclosure control. With a small, specialised sample, exact birth
# year combined with country and career stage can single out a
# respondent. Default: age is shared in 10-year bands, countries
# outside the three largest groups are pooled. Set to TRUE only if
# your consent form and ethics approval cover sharing exact values.
KEEP_EXACT_AGE     <- FALSE
KEEP_EXACT_COUNTRY <- FALSE

source_cols <- c(
  "CASE","SERIAL","REF","QUESTNNR","MODE","STARTED",
  "DM02","DM03_01","DM03_01a","DM04","DM06","DM07","DM07_06",
  "DM08","DM10_01","DM13","EO02_01","EO02_02","EO02_03",
  "EO02_05","EO02_08","EO03_01","EO04","EO04_04","EO04_15",
  "EO04_14","EO04_12","EO04_13","EO04_16","EO04_17","EO04_19",
  "EO04_20","EO04_11","EO04_11a","ER02","ER07","ER07_09",
  "ER07_10","ER07_11","ER07_12","ER07_13","ER07_14","ER07_14a",
  "ER09","ER10","ER10_08","ER10_09","ER10_10","ER10_11",
  "ER10_12","ER10_07","ER10_07a","ER11","ER11_01","ER11_02",
  "ER12","ER12_01","ER12_10","ER12_12","ER12_11","ER12_02",
  "ER12_13","ER12_09","ER12_09a","ER13","ER14","ER14_01",
  "ER14_02","ER14_03","ER14_04","ER14_05","ER14_06","ER14_08",
  "ER14_08a","ER17_01","ER18_01","ER18_01a","ER18_02","ER18_02a",
  "ER18_03","ER18_03a","ER18_04","ER18_04a","FB02","FB03","FB04",
  "FB05","FB05_04","FB05_05","FB05_06","FB05_07","FB05_08",
  "FB05_09","FB07_01","FB08","FB08_01","FB08_02","FB08_03",
  "FB08_04","FB08_05","FB08_06","FB08_06a","LP14","PB02_01",
  "PB02_02","PB02_03","PB02_04","PB03_05","PB03_06","PB03_07",
  "PB03_08","PB03_09","PB03_10","PB04_03","PB04_02","PB04_06",
  "PB04_04","PB05_01","PB05_03","PB05_04","PB05_05","PB05_06",
  "PB05_02","PS01_09","PS01_10","PS01_13","PS01_15","PS02_01",
  "PS02_02","PS02_03","PS02_04","PS03_01","PS03_02","PS03_03",
  "PS03_04","PS04_01","PS04_02","PS04_03","PS04_06","PS05_01",
  "PS07_01","PS13_01","PS13_02","PS13_03","PS13_04","RB02",
  "RB03","RB03_01","RB03_04","RB03_05","RB03_06","RB03_06a",
  "RB04","RB04_01","RB04_11","RB04_02","RB04_03","RB04_04",
  "RB04_05","RB04_06","RB04_09","RB04_10","RB04_10a","RB08_01",
  "RB08_02","RB08_03","RC01","RC02","RC03_01","RC04_01",
  "TIME001","TIME002","TIME003","TIME004","TIME005","TIME006",
  "TIME007","TIME008","TIME009","TIME010","TIME011","TIME_SUM",
  "MAILSENT","LASTDATA","STATUS","FINISHED","Q_VIEWER",
  "LASTPAGE","MAXPAGE","MISSING","MISSREL","TIME_RSI")

raw <- read.delim(
  file = RAW_PATH, encoding = "UTF-8", fileEncoding = "UTF-8",
  header = FALSE, sep = "\t", quote = '"', dec = ".",
  row.names = NULL, col.names = source_cols,
  as.is = TRUE, skip = 1, check.names = TRUE, fill = TRUE,
  strip.white = FALSE, blank.lines.skip = TRUE,
  comment.char = "", na.strings = "")

raw <- raw[raw$FINISHED == "TRUE" & !is.na(raw$FINISHED), ]

keep <- c("DM02","DM04","DM06","DM07","DM08","DM13","ER02",
          "PS01_09","PS01_10","PS01_13","PS01_15",
          "PS02_01","PS02_02","PS02_03","PS02_04",
          "PS03_01","PS03_02","PS03_03","PS03_04",
          "PS04_01","PS04_02","PS04_03","PS04_06",
          "PB02_01","PB02_02","PB02_03","PB02_04",
          "PB03_05","PB03_06","PB03_07","PB03_08","PB03_09","PB03_10",
          "PB04_02","PB04_03","PB04_04","PB04_06",
          "RC03_01","RC04_01")

pub <- raw[, keep]

# Age (survey year 2025/26; the paper uses 2026 - birth year)
birth <- suppressWarnings(as.numeric(raw$DM03_01))
birth[birth < 0] <- NA
age <- 2026 - birth
if (KEEP_EXACT_AGE) {
  pub$age <- age
} else {
  pub$age_group <- cut(age, breaks = c(-Inf, 34, 44, 54, Inf),
                       labels = c("<35", "35-44", "45-54", "55+"))
}

# Country: SoSci codes 64 = Germany, 187 = USA, 125 = Netherlands
if (!KEEP_EXACT_COUNTRY) {
  cc <- suppressWarnings(as.numeric(pub$DM08))
  pub$DM08 <- ifelse(is.na(cc) | cc < 0, -1,
              ifelse(cc %in% c(64, 187, 125), cc, 999))   # 999 = other
}

# Replication-rate sliders: SoSci stores 0% as 1 and 100% as 101,
# and -9 = no answer. Convert to percentages (0-100); keep negatives
# as missing codes.
for (v in c("RC03_01", "RC04_01")) {
  x <- suppressWarnings(as.numeric(pub[[v]]))
  pub[[v]] <- ifelse(!is.na(x) & x > 0, x - 1, x)
}

# Shuffle rows and assign a new id so row order carries no information
set.seed(20260708)
pub <- pub[sample(nrow(pub)), ]
pub <- cbind(id = sprintf("R%02d", seq_len(nrow(pub))), pub)

write.csv(pub, PUBLIC_PATH, row.names = FALSE, na = "")
cat(sprintf("Wrote %s: %d respondents, %d variables\n",
            PUBLIC_PATH, nrow(pub), ncol(pub)))
