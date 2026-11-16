# Running OpenTrialDesign

## Standard local installation

Install R >= 4.5 and Pandoc. From the repository root, run
`Rscript scripts/install-product.R`. This restores the locked dependencies,
builds the vignette and installs the product. Start with
`Rscript scripts/start-product.R`, then open http://localhost:3838.
The versioned library is isolated in the user application cache outside the checkout; no startup hook changes other projects.
`Rscript scripts/start-product.R --check` verifies library selection;
`Rscript scripts/start-product.R --test` runs the complete installed package suite.
Use OTD_R_LIBRARY to select another isolated library location.
Use `OpenTrialDesign::runtime_diagnostics()` to inspect optional capabilities.
PDF output additionally requires a LaTeX installation.

## Container

Run `docker compose up --build -d`, then open http://localhost:3838.
Check health with `docker compose ps` and logs with `docker compose logs -f`.
Stop with `docker compose down`. The container runs as UID 10001, with a
read-only filesystem and writable temporary storage. The default port binds
only to the local machine. CPU/memory limits are set in compose.yaml.

No patient-level data are required or collected. Projects contain design
assumptions and simulation settings; downloads remain on the user's computer.
The application has no permanent server-side project database. Keep the JSON
project and reproducibility bundle to preserve work across sessions/restarts.
Running jobs are cancelled when their browser session ends.

For institutional hosting, put the application behind the institution's
reverse proxy and access controls, including TLS and WebSocket forwarding.
Do not change repository visibility or expose the local port as part of a
local installation. Set OTD_HOST/OTD_PORT for the container listener as needed.
An actual public deployment requires a selected hosting destination.

## Batch execution

Create a project using `write_project(trial_project(...), "design.json")`.
Run `Rscript exec/opentrialdesign.R --project design.json --output results.zip`.
The runner returns a nonzero exit code on an invalid project or engine failure.
The ZIP contains CSV, exact assumptions, provenance, an R archival object and
checksums. Import only JSON projects in the UI; never load untrusted RDS files.

## Upgrades and recovery

Keep existing project JSON and bundles before upgrading. Schema version and
originating software version are recorded in JSON. Unsupported schema versions
fail explicitly. Projects freeze defaults, so changing an application's default
alpha or power cannot silently change an existing saved design. Re-execution
records the versions actually used in the new result. Use the lockfile or the
same container version for numerical reproduction.

A failed simulation reports its error and does not produce partial estimates.
Correct the settings and launch a new job. Cancelled runs never appear as
completed results. The application permits one active simulation per session
and limits UI jobs to 100,000 replications; larger experiments use the R API.

For an enterprise TLS-inspecting proxy, build with
`docker build --secret id=extra_ca,src=/path/to/trusted-ca-bundle.pem -t opentrialdesign:0.2.0 .`.
Only add your trusted organizational CA bundle; certificate verification remains enabled.

The server limits concurrent workers (option `OpenTrialDesign.max_jobs`, default
4 in R; OTD_MAX_JOBS=2 in the container). Full capacity produces a recoverable
message rather than silently overcommitting resources. Worker startup does not
execute project or user R profiles.

The image sets R_LIBS explicitly so that the locked library precedes packages
bundled with the base image. R_PROFILE disables the base image's repository
profile; workers also disable startup profiles. The standard Dockerfile pins
the base-image digest and restores the committed R dependency graph.

VFS Docker storage drivers make full filesystem copies for layers/containers.
On space-constrained hosts, retire an unused previous container before creating
its replacement, and remove only your unused intermediate build artifacts.
Download projects and bundles before planned restarts. Standard overlay-based
Docker installations avoid these VFS copy costs.

In the managed 32-GB environment used during development, the VFS driver could
build the final image but exhausted disk cloning its root for another container.
The application was served with the verified native R runtime instead. Final
container acceptance is run in CI using a standard Docker storage backend.
Use the native R installation or a host with sufficient Docker storage when
VFS does not meet this requirement; do not treat a failed start as a health pass.

Native source installations need a C/C++/Fortran build toolchain and the system
headers required by the locked R dependencies (Linux: libcurl, OpenSSL, libxml2,
ICU, fontconfig/freetype, harfbuzz/fribidi and image libraries). Windows source
builds require matching Rtools; macOS requires the matching command-line tools
and Fortran compiler. The standard Dockerfile installs these requirements.

## Versioned release installation

Download OpenTrialDesign_0.3.0.tar.gz and SHA256SUMS from the GitHub release;
verify `sha256sum -c SHA256SUMS` in the directory containing all release assets.
The source package is installed with `R CMD INSTALL OpenTrialDesign_0.3.0.tar.gz`
when its documented dependencies are present. For the complete frozen product,
use the repository's native installer or the published container.

The release's container-image.txt contains an immutable GHCR digest. For a
private repository/package, authenticate with an authorized GitHub account and
registry token with read:packages; do not paste credentials into projects or
reports. Pull and run that digest, using the same read-only/tmpfs/loopback and
resource options in compose.yaml. Override Compose's `image` value with the
published digest and start with `docker compose up --no-build -d` after pulling.
Registry access does not change the repository's visibility.

The tag-triggered release workflow first reruns the full scientific and browser
verification on that tag. It then builds source/documentation, publishes the
container and creates release assets/checksums. Failed verification prevents
publication. The verification URL and source commit accompany the assets.
