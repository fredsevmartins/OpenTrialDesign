# Installation and operations

Choose Docker Compose to run the browser application locally, or install
natively for R and command-line workflows. Both builds resolve the committed
`renv.lock`. The local application binds to loopback on port 3838.

## Docker Compose

From the repository root, with Docker and Compose v2 installed, run:

```sh
docker compose up --build -d
docker compose ps
```

Open [localhost:3838](http://localhost:3838) once the service is healthy. Use
`docker compose logs --tail=100 opentrialdesign` for startup diagnostics and
`docker compose down` to stop the service. The container runs as UID 10001
with a read-only filesystem, writable temporary storage, and CPU and memory
limits. The Dockerfile pins the R base image and includes Pandoc and LaTeX.

The build needs access to the base image, Ubuntu package repositories, and
CRAN. If an organizational proxy inspects TLS, provide its trusted CA bundle
using BuildKit's `extra_ca` secret:

```sh
docker build --secret id=extra_ca,src=/path/to/trusted-ca-bundle.pem \
  -t opentrialdesign:0.4.1 .
```

For a VFS Docker host, allow space for full copies of image layers and container
filesystems. If a build succeeds but the container cannot start because of
disk space, use a host with adequate storage or the native installation.

## Native R installation

Install R 4.5 or later and Pandoc. For source packages, use a C/C++/Fortran
toolchain and the required system headers. On Linux, see the [Dockerfile](../Dockerfile)
for the dependency list. On macOS use matching command-line tools and
Fortran, and on Windows use matching Rtools. Install LaTeX to generate PDFs.

From the repository root, run:

```sh
Rscript scripts/install-product.R
Rscript scripts/start-product.R --check
Rscript scripts/start-product.R
```

The installer restores dependencies into a versioned library outside the
checkout and installs the package, tests, and rendered guide. Set
`OTD_R_LIBRARY` to select a different isolated library. Use the same value
for installation and startup.

- `Rscript scripts/start-product.R --diagnostics` reports library selection and available engines and report tools.
- `Rscript scripts/start-product.R --test` runs the installed package tests.

## Install a versioned source package

The [0.4.1 release directory](../dist/v0.4.1) contains the source archive,
generated documentation, evidence archive, and dependency lockfile. With all
listed files present in one directory, verify them before installing:

```sh
sha256sum -c SHA256SUMS
R CMD INSTALL OpenTrialDesign_0.4.1.tar.gz
```

Source installation requires the package dependencies to be available in R.
Use the native installer from the corresponding source revision for a locked
dependency restore. The 0.4.1 release was verified locally on Linux and
includes no prebuilt container image. Build it from source for Docker use.

## Run a saved design from the command line

Save a project as JSON in the application or with
`write_project(trial_project(), "design.json")`. From the repository root:

```sh
Rscript exec/opentrialdesign.R --project design.json --output results.zip
```

The runner uses the installed product library and exits with a nonzero status
if the input is invalid or an engine fails. The bundle includes the replayable
project, result tables, provenance, and file-integrity checks. Import only JSON
projects into the application. Treat serialized R objects from outside your
trust boundary as untrusted.

## Operate the application

- **Save work before a restart.** Sessions and running jobs are temporary.
  Download the JSON and result bundle to retain the project and outputs.
- **Reproduce with a pinned version.** JSON freezes defaults and records the
  schema and originating package version. A replay records the versions it
  actually used. Keep the corresponding lockfile or container image.
- **Monitor job capacity.** The application permits one simulation per session.
  The R option `OpenTrialDesign.max_jobs` controls total worker capacity.
  The Docker image uses `OTD_MAX_JOBS` and defaults to two workers. Cancelled
  and failed simulations never appear as completed estimates.
- **Restart after upgrading.** Stop the running process before reinstalling
  its package library. Restart and verify a calculation after installation.

For institutional hosting, put Shiny behind a TLS reverse proxy that forwards
WebSocket connections and enforces the institution's access policy. Keep the
application port private. Projects contain design assumptions and simulation
settings. Use synthetic assumptions in shared testing and avoid patient-level
or confidential information in uploads and feedback. The application has no
persistent project database.

## Release engineering

The [tag workflow](../.github/workflows/release.yaml) verifies the tag before
building source and documentation, publishing the container, and attaching
checksums and the image digest. Use `container-image.txt` to select the exact
image for releases that publish one.

For a locally verified prerelease, run the
[local release builder](../scripts/prepare-local-release.py) from a clean
checkout with locked R dependencies, Pandoc, LaTeX, Chromium, Playwright, and
axe-core 4.10.3. It builds artifacts and records the actual verification
scope. See the [release checklist](../docs/RELEASE-CHECKLIST.md) for the
manual release procedure.
