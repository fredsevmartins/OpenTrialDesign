FROM rocker/r-ver:4.5.0@sha256:f97b4944221bdc309583dfbc37dc0bf2654cfbd1f330cded047aeec4ae5df7e3
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl pandoc pkg-config libcurl4-openssl-dev libssl-dev \
    libxml2-dev libicu-dev libfontconfig1-dev libfreetype6-dev libharfbuzz-dev \
    libfribidi-dev libpng-dev libjpeg-dev libtiff-dev libnode-dev \
    texlive-latex-base texlive-latex-recommended texlive-fonts-recommended lmodern \
    && rm -rf /var/lib/apt/lists/*
ENV R_LIBS=/opt/otd-library \
    R_PROFILE=/dev/null \
    R_LIBS_USER=/opt/otd-library \
    RENV_PATHS_ROOT=/opt/renv \
    DOWNLOAD_STATIC_LIBV8=1 \
    OTD_HOST=0.0.0.0 OTD_PORT=3838 \
    XDG_CACHE_HOME=/tmp/otd-cache \
    TEXMFVAR=/tmp/otd-texmf-var TEXMFCONFIG=/tmp/otd-texmf-config
WORKDIR /opt/OpenTrialDesign
COPY renv.lock ./
RUN --mount=type=secret,id=extra_ca,required=false \
    if [ -f /run/secrets/extra_ca ]; then cat /run/secrets/extra_ca >> /etc/ssl/certs/ca-certificates.crt; fi
RUN mkdir -p /opt/otd-library && Rscript -e 'options(Ncpus=2); install.packages("renv", repos="https://cloud.r-project.org"); renv::consent(provided=TRUE); renv::restore(lockfile="renv.lock", library="/opt/otd-library", prompt=FALSE)'
COPY . .
RUN R CMD build . && R CMD INSTALL --install-tests OpenTrialDesign_0.2.0.tar.gz \
    && Rscript -e 'library(OpenTrialDesign); stopifnot(sample_size(trial_spec())$data$n_per_arm == 64)' \
    && useradd --uid 10001 --create-home otd && chmod -R a+rX /opt/otd-library /opt/OpenTrialDesign
ENV OTD_MAX_JOBS=2
USER 10001:10001
EXPOSE 3838
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
    CMD curl --fail --silent http://127.0.0.1:3838/ > /dev/null || exit 1
CMD ["Rscript", "-e", "options(OpenTrialDesign.max_jobs=as.integer(Sys.getenv('OTD_MAX_JOBS'))); OpenTrialDesign::run_app(host=Sys.getenv('OTD_HOST'), port=as.integer(Sys.getenv('OTD_PORT')), launch.browser=FALSE)"]
