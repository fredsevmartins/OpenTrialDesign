# OpenTrialDesign
Scientific Clinical Trial Design, Simulation &amp; Operating Characteristics in R

A reproducible R package and browser application for clinical trial planning
and simulation, version 0.4.1. The statistical core is independent of Shiny.
It delegates calculations to stats, gsDesign, rpact, survival and simsurv.

## MVP 0.4.1

This minimum viable product packages the established trial-design workflows,
reproducible projects, browser interface and version-1 example catalog. It
includes corrected fixed-sample sizing and exact sequential enrollment rounding.
See the [MVP scope and acceptance criteria](docs/PRODUCT-READINESS.md) and
[scientific scope](docs/METHOD-EXTENSIONS.md). It is an analysis aid, not a
qualified clinical system; study-specific review remains necessary.

Download the [0.4.1 package, guide, execution logs and checksums](dist/v0.4.1).
Local Linux acceptance covered 337 test assertions, 30 scientific comparisons
and 32 browser workflows. Windows, macOS and clean-container execution remain
unverified for this version.

## Start the product

With Docker: `docker compose up --build -d`, then open **http://localhost:3838**.
The default deployment stays on your computer; it does not expose a public site.

With R: install R >= 4.5 and Pandoc, run `Rscript scripts/install-product.R`, then
`Rscript scripts/start-product.R`. The installer uses an isolated project
library, restores locked dependencies, builds the guide and installs the
package. PDF additionally requires LaTeX.
See [deployment and recovery instructions](deployment/README.md).

## Included methods

* Visible sparse-binary guidance, expected-count diagnostics and an explicit
  Fisher simulation option; approximate sizing is never relabelled exact.
* Unequal-allocation normal superiority and noninferiority with clinically
  prespecified margins and verified direction handling.
* Normal equivalence via exact parallel TOST power from PowerTOST.
* Native piecewise exponential delayed/crossing survival simulation with an
  equal-curve null, event-target safeguards and no constant-HR claim.

See [method scope, assumptions and references](docs/METHOD-EXTENSIONS.md).
Version 0.4.1 also fixes smallest-supported fixed-sample sizing and floating
point rounding at integer sequential interim looks.

## New in 0.3.0

Review the hypothesis, alpha definition, estimand and stopping rules before
execution. Build sensitivity grids, run cancellable batches and export every
scenario as replayable JSON with results and provenance.

```r
library(OpenTrialDesign)
projects <- scenario_grid(trial_project(),
  list(effect = c(.3, .5), power = c(.8, .9)))
review_project(projects[[1]])
batch <- run_scenarios(projects)
export_bundle(batch, "sensitivity.zip", include_report = FALSE)
```

[Versioned releases](https://github.com/fredsevmartins/OpenTrialDesign/releases)
provide installable source, generated documentation, dependency lock, SHA256
checksums and the verified GHCR image digest. Releases preserve repository and
package access controls; a private repository is not made public.
See [release installation](deployment/README.md#versioned-release-installation).

Scientific and usability review protocols are in [docs/review](docs/review).
Independent review and real-user evaluation remain explicitly unperformed.
The extended stress screen retains sparse-data calibration departures; it does
not claim uniform error control across all possible settings.

## Workflows

* Fixed normal and binary superiority sample size and analytical power.
* Group sequential boundaries with explicit binding/nonbinding futility.
* Integer sequential normal enrollment with native rpact recalibration.
* Two-stage inverse-normal adaptation with native conditional-power resizing.
* Exponential proportional-hazards survival planning and event-driven simulation.
* Monte Carlo power and equality-null error, with uncertainty intervals.
* Scenario comparison and a defined 30-example version-1 product catalog.

The application saves frozen JSON projects, replays them through the same API,
runs simulations in separate cancellable processes, and exports CSV, complete
reproducibility ZIPs, HTML and PDF. It includes runtime diagnostics and the full
downloadable guide. Results retain the assumptions actually used even after
controls change. Closing a session cancels its active worker.

## Reproduce an analysis

```r
source("scripts/product-library.R")
activate_product_library()
library(OpenTrialDesign)
project <- trial_project("fixed_simulation",
  list(effect = 0.5, n_per_arm = 64, nsim = 5000, seed = 2026, null = TRUE),
  "Normal-trial null assessment")
write_project(project, "design.json")
result <- execute_project(read_project("design.json"))
export_bundle(result, "trial.zip", include_report = FALSE)
render_report(result, "trial.html")
```

Batch: `Rscript exec/opentrialdesign.R --project design.json --output trial.zip`.
Projects freeze default values and record a schema/software version. No R code
from imported JSON is evaluated. ZIPs include results, provenance, assumptions,
replay settings and integrity checks. Do not import untrusted RDS objects.

## Scientific scope and evidence

Adapters support the specific methods described in the [user guide](vignettes/user-guide.Rmd),
including unequal-allocation normal noninferiority, normal equivalence, sparse
binary diagnostics/Fisher simulation, and piecewise-exponential nonproportional
hazards simulation. They do not provide a general-purpose implementation of
cluster or competing-risk designs. Sequential alpha is one-sided; adaptive
resizing remains within the inverse-normal procedure. Compatibility across
engines is not inferred. Monte Carlo estimates are distinguished from analytical
results.

The installed version-1 example catalog defines TD-001 through TD-030 for this
product. Its assumptions and rationales are explicit. No equivalence to an
absent external project plan is claimed. Effects are synthetic planning
scenarios, not clinical recommendations or observed participant data.

Actual execution evidence is in [validation](validation/README.md), including
package checking, scientific references, browser workflows, background-job
recovery, exports and installation checks. Computational verification and engine
agreement do not establish qualification for a particular clinical protocol or
GxP environment. Those require study-specific review.

## Development and documentation

```sh
Rscript -e 'roxygen2::roxygenise()'
Rscript -e 'testthat::test_local()'
Rscript scripts/run-examples.R
Rscript scripts/scientific-reference.R
R CMD build .
R CMD check OpenTrialDesign_0.4.1.tar.gz
```

[Architecture](docs/ARCHITECTURE.md) · [Readiness scope](docs/PRODUCT-READINESS.md)
· [Reference matrix](docs/VALIDATION-MATRIX.md) · [Dependency audit](validation/dependency-audit.txt).
Generate the local documentation site with `pkgdown::build_site()`; output is
`docs/site/`. CI covers Linux, Windows and macOS, with a separate container
smoke test. Lockfile restoration captures the supported dependency graph.

The software is MIT licensed. Underlying engines retain their own licenses;
cite them when using their methods. Report reproducible issues through this
repository's GitHub Issues without confidential participant data.
