# OpenTrialDesign
Scientific Clinical Trial Design, Simulation &amp; Operating Characteristics in R

A reproducible R package and browser application for clinical trial planning
and simulation, version 0.2.0. The statistical core is independent of Shiny.
It delegates calculations to stats, gsDesign, rpact, survival and simsurv.

## Start the product

With Docker: `docker compose up --build -d`, then open **http://localhost:3838**.
The default deployment stays on your computer; it does not expose a public site.

With R: install R >= 4.5 and Pandoc, run `Rscript scripts/install-product.R`, then
`OpenTrialDesign::run_app()`. The installer restores locked dependencies,
builds the guide and installs the package. PDF additionally requires LaTeX.
See [deployment and recovery instructions](deployment/README.md).

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

Supported adapters assume equal-allocation two-arm superiority, and the specific
models described in the [user guide](vignettes/user-guide.Rmd). Sequential alpha
is one-sided. Adaptive resizing remains inside the inverse-normal procedure.
Noninferiority, equivalence, nonproportional hazards, cluster and competing-risk
methods are outside this version's adapters; no compatibility across engines
is inferred. Monte Carlo estimates are distinguished from analytical results.

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
R CMD check OpenTrialDesign_0.2.0.tar.gz
```

[Architecture](docs/ARCHITECTURE.md) · [Readiness scope](docs/PRODUCT-READINESS.md)
· [Reference matrix](docs/VALIDATION-MATRIX.md) · [Dependency audit](validation/dependency-audit.txt).
Generate the local documentation site with `pkgdown::build_site()`; output is
`docs/site/`. CI covers Linux, Windows and macOS, with a separate container
smoke test. Lockfile restoration captures the supported dependency graph.

The software is MIT licensed. Underlying engines retain their own licenses;
cite them when using their methods. Report reproducible issues through this
repository's GitHub Issues without confidential participant data.
