# OpenTrialDesign

**Clinical trial design, operating characteristics, and reproducible analysis in R.**

OpenTrialDesign helps trial statisticians and clinical researchers compare
design assumptions, calculate enrollment, and evaluate operating
characteristics. Use the Shiny application for interactive planning or the R
package and command line for scripted analysis. Each saved project records
the assumptions needed to replay the calculation.

[Get started](#get-started) · [Design methods](#design-methods) ·
[User guide](vignettes/user-guide.Rmd) · [Deployment](deployment/README.md) ·
[Version 0.4.1](dist/v0.4.1)

## Get started

### Browser application

From the repository root, build and start the application with Docker Compose.

```sh
docker compose up --build -d
docker compose ps
```

Open [localhost:3838](http://localhost:3838). In **Design configuration**, use
the default normal endpoint, effect of 0.5, standard deviation of 1,
two-sided alpha of 0.05, and target power of 0.80. Select **Calculate fixed
design**, then open **Sample size and power**. The calculation gives **64
evaluable participants per arm**, or 128 total.

In **Projects and exports**, save the calculation as JSON. Open the saved
file and select **Execute opened project** to replay the same assumptions.
Run `docker compose down` when finished.

For a native installation, install R 4.5 or later and Pandoc. Run
`Rscript scripts/install-product.R` followed by
`Rscript scripts/start-product.R` from the repository root. The installer
restores the lockfile into an isolated R library. See the
[installation and operations guide](deployment/README.md) for prerequisites,
library selection, and batch execution.

### R package

After installing the package, run this example in an R session whose library
path includes OpenTrialDesign.

```r
library(OpenTrialDesign)

design <- trial_project(
  "fixed_sample_size",
  list(endpoint = "normal", effect = 0.5, sd = 1, alpha = 0.05,
       power = 0.80, alternative = "two.sided"),
  title = "Synthetic two-arm superiority trial"
)
result <- execute_project(design)
result$data$n_per_arm
# [1] 64

write_project(design, "design.json")
export_bundle(result, "design.zip", include_report = FALSE)
```

The JSON stores the project schema, originating software version, and resolved
assumptions. The ZIP adds results, methodology, runtime provenance, and
file-integrity checks. Structured simulation results include the seed and
Monte Carlo uncertainty. Reports are available as HTML with Pandoc and as PDF
with Pandoc and LaTeX.

## Design methods

| Workflow | Supported scope |
| --- | --- |
| Fixed superiority | Equal-allocation normal and binary sample size and analytical power. Binary planning uses a large-sample approximation. |
| Normal means and margins | Unequal allocation, superiority, directional noninferiority, and equivalence via parallel TOST. Margins are supplied by the analyst. |
| Group sequential | One-sided efficacy boundaries, explicit futility rules, and integer enrollment planning for the supported normal design. |
| Adaptive sizing | Two-stage inverse-normal combination testing with conditional-power resizing. |
| Survival | Exponential proportional-hazards planning and simulation, plus piecewise-exponential simulation for nonproportional hazards. |
| Operating characteristics | Seeded Monte Carlo estimates, sensitivity grids, and a catalog of 30 reproducible synthetic examples. |

See the [user guide](vignettes/user-guide.Rmd) for worked examples and
[method specifications](docs/METHOD-EXTENSIONS.md) for assumptions,
interpretation, and engine references.

## Release evidence

Version **0.4.1** includes the source package, generated documentation,
dependency lockfile, verification record, and SHA-256 checksums. The release
record reports 337 passing test assertions, 30 scientific reference
comparisons, and 32 browser workflows on Linux. Windows, macOS, and a clean
container run were outside that verification. See the
[release files](dist/v0.4.1), [verification record](dist/v0.4.1/verification.json),
and [validation index](validation/README.md).

OpenTrialDesign is for research and planning. Assess assumptions, margins,
operating characteristics, and implementation against the study protocol
before relying on a design. Independent scientific and real-user evaluations
are pending. Use synthetic assumptions in examples, shared projects, and
issue reports.

## Project resources

- [Architecture](docs/ARCHITECTURE.md) and [dependency inventory](docs/DEPENDENCIES.md)
- [Validation matrix](docs/VALIDATION-MATRIX.md) and [review protocols](docs/review)
- [Release notes](NEWS.md), [citation](CITATION.cff), and [MIT license](LICENSE)
- [Report an issue](https://github.com/fredsevmartins/OpenTrialDesign/issues)
