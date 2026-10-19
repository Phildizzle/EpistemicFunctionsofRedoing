# Installs the package versions the analysis was verified with.
# Uses a dated snapshot of CRAN (Posit Public Package Manager), so the
# same versions are installed regardless of when this is run.
#
# Verified versions (see output/logs/sessionInfo_verified_run.txt):
#   R 4.3.3, dplyr 1.1.4, tidyr 1.3.1, ggplot2 3.4.4,
#   patchwork 1.2.0, colorspace 2.1-0

SNAPSHOT <- "2024-02-01"

# Linux binaries if available, otherwise source packages
if (Sys.info()[["sysname"]] == "Linux" && file.exists("/etc/os-release") &&
    any(grepl("jammy", readLines("/etc/os-release")))) {
  repo <- sprintf("https://packagemanager.posit.co/cran/__linux__/jammy/%s", SNAPSHOT)
} else {
  repo <- sprintf("https://packagemanager.posit.co/cran/%s", SNAPSHOT)
}
options(repos = c(CRAN = repo))

pkgs <- c("dplyr", "tidyr", "ggplot2", "patchwork", "colorspace")
install.packages(pkgs)

expected <- c(dplyr = "1.1.4", tidyr = "1.3.1", ggplot2 = "3.4.4",
              patchwork = "1.2.0", colorspace = "2.1.0")
got <- sapply(names(expected), function(p) as.character(packageVersion(p)))
print(data.frame(package = names(expected), expected = expected, installed = got))
if (any(got != expected)) warning("Installed versions differ from the verified run.")
