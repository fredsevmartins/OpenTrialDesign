# Running OpenTrialDesign

## Standard local installation

Install R >= 4.5 and Pandoc. From the repository root, run
`Rscript scripts/install-product.R`. This restores the locked dependencies,
builds the vignette and installs the product. Start with
`OpenTrialDesign::run_app()` in R. The browser opens the local application.
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
