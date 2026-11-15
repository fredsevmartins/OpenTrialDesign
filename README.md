# OpenTrialDesign
Scientific Clinical Trial Design, Simulation &amp; Operating Characteristics in R

## Implementation status

An installable R package implements fixed normal/binary superiority designs,
engine-specific group sequential designs, a two-stage adaptive inverse-normal
procedure, exponential survival planning, and simulation of operating
characteristics. The statistical core is independent of the optional Shiny app.

**Scientific scope:** equal-allocation two-arm superiority and the specific
procedures documented in the [user guide](vignettes/user-guide.Rmd). This release
is computationally verified against reference cases, not independently
scientifically validated for confirmatory clinical use. The original plan
specifying TD-001 through TD-030 was absent; the 30 implemented scenarios are
an explicitly **provisional** catalog pending reconciliation.

## Install

```r
install.packages(c("survival", "ggplot2", "withr"))
# From the repository root, in a terminal:
# R CMD build .
# R CMD INSTALL OpenTrialDesign_0.1.0.tar.gz

# Optional scientific engines and user interface:
install.packages(c("gsDesign", "rpact", "simsurv", "shiny", "rmarkdown"))
```

R >= 4.2 is declared; the executed baseline is R 4.5.0 on Debian Linux.
Minimum adapter versions reflect inspected APIs: gsDesign 3.11.0, rpact 4.4.0,
simsurv 1.0.1, survival 3.8-3, ggplot2 3.5.1 and withr 3.0.2.
Other R/platform combinations require their own execution evidence.
`renv.lock` captures the tested dependency graph. Restore it with
`renv::restore(lockfile = "renv.lock")`; the complete locked dependency graph and 181 package assertions were also
tested in a fresh R library on the provisioned Debian host. A fresh OS image
is a separate installation scenario. No project startup hook changes an existing R session.

## Quick start

```r
library(OpenTrialDesign)
spec <- trial_spec(endpoint = "normal", effect = 0.5, sd = 1,
                   alpha = 0.05, power = 0.8)
sample_size(spec)                   # rounded per-arm size and achieved power
trial_power(spec, n_per_arm = 64)   # analytical power
simulate_trial(spec, 64, nsim = 5000, seed = 2026, null = TRUE)

seq <- sequential_design(engine = "gsDesign", futility = "nonbinding")
plot_design(seq)
sequential_power(seq, theta = 0)
simulate_sequential(seq, nsim = 10000, seed = 2026)
conditional_power(seq, z = 1.5)

adaptive_simulation(nsim = 5000, seed = 2026)
survival_design(hazard_ratio = 0.7, median_control = 12,
                accrual = 18, followup = 12, dropout = 0.1)
simulate_survival(200, events = 240, nsim = 1000, seed = 2026)

run_example("TD-001")
run_app()
render_report(sample_size(spec), "design.html")
render_report(sample_size(spec), "design.pdf", "pdf")
```

Reporting requires Pandoc; PDF requires LaTeX. Optional engine dependencies fail
with a structured `otd_dependency_error` rather than returning fabricated output.
All result objects preserve engine, version, assumptions, estimand, method,
seed where applicable, and validation status. Monte Carlo outputs contain
rejection counts, standard errors, and exact 95% binomial intervals.

## Documentation and verification

* [Comprehensive user guide](vignettes/user-guide.Rmd)
* [Architecture](docs/ARCHITECTURE.md) and [roadmap](docs/ROADMAP.md)
* [Phase status and limitations](docs/PHASE-STATUS.md)
* [Scientific example catalog](inst/examples/catalog.csv)
* [Executed examples](validation/example-execution.csv)
* [Expected versus observed reference results](validation/scientific-reference.csv)
* [Dependency API and license audit](validation/dependency-audit.txt)
* [Release checklist](docs/RELEASE-CHECKLIST.md)

```sh
Rscript -e 'roxygen2::roxygenise()'
Rscript -e 'testthat::test_local()'
Rscript scripts/audit-dependencies.R
Rscript scripts/run-examples.R
Rscript scripts/scientific-reference.R
R CMD build .
R CMD check OpenTrialDesign_0.1.0.tar.gz
```

CI is configured for Linux, Windows and macOS. Local logs do not imply those
remote jobs have run. Binding futility cannot be ignored; nonbinding futility
can be evaluated with and without stopping. Adaptive resizing remains inside
the inverse-normal procedure. No noninferiority margin, equivalence rule,
allocation imbalance, or cross-engine compatibility is inferred.

## Contributing

Use a branch, document hypotheses and estimands, retain native engine semantics,
and add independent reference cases for statistical changes. Record observed
results and justified tolerances. Do not relabel an unexecuted check as passing.
Report issues without participant-level data or other confidential information.
This project is MIT licensed; engine licenses are recorded separately and must
be respected when distributing their code. Cite the engines used in an analysis.
