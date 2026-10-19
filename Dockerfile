# Reproducible environment for the analyses in
# "Epistemic Functions of Reengagement with Prior Findings".
#
# Build:  docker build -t reengagement-survey .
# Run:    docker run --rm -v "$(pwd)/output:/project/output" reengagement-survey
#
# Results are written to ./output on the host.

FROM rocker/r-ver:4.3.3

WORKDIR /project

# Fonts for the figures (the original figures were rendered on Windows;
# glyph widths may differ slightly, the numbers do not)
RUN apt-get update \
 && apt-get install -y --no-install-recommends fonts-dejavu-core \
 && rm -rf /var/lib/apt/lists/*

COPY install_packages.R .
RUN Rscript install_packages.R

COPY R/ R/
COPY tests/ tests/
COPY run_all.R .
COPY data/survey_public.csv data/survey_public.csv

CMD ["Rscript", "run_all.R"]
