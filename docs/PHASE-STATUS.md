# Executed phase status

## Phase 1
Files: docs/ROADMAP.md, scripts/audit-dependencies.R, validation/dependency-audit.txt.
Inspected original commit 209a42f and clean Git state. No project plan or instructions found.
R absent initially; system apt install failed (filesystem permissions). A local Debian
R 4.5.0 installation now executes. CRAN network access verified. Engine installation
and audit are continuing; no dependency compatibility claim is made in advance.

## Phase 2
Files: DESCRIPTION, LICENSE, R/specification.R, R/fixed.R, R/simulation.R,
tests/testthat/test-fixed.R, generated man pages and NAMESPACE.
Executed: roxygen2::roxygenise(); testthat::test_local().
Observed: 16 passing assertions, zero failures, warnings or skips (phase2-tests.txt).
Normal standardized difference 0.5, two-sided alpha 0.05, target power 0.8:
64 per arm, matching stats with 1e-8 tolerance on unrounded size.
Equality-null Monte Carlo error assessed using 5000 replications and a predeclared
4-sigma tolerance. Directional binary API compared directly with stats.
Limitations: equal allocation superiority only; no noninferiority or equivalence
in the fixed stats adapter. Sequential, adaptive, survival and UI work follows.

## Phase 3
Files: R/sequential.R, R/adaptive.R, tests/testthat/test-engines.R.
Executed engine API probes and the combined phase 3/4 suite: 49 assertions
passed, zero failures/warnings/skips in the corrected run. An initial run
identified an incorrect Pocock export name, irrelevant rpact arguments, a
relative-versus-absolute tolerance mismatch, and vector comparison assertions;
these were corrected before the recorded successful run. OF/Pocock numerical
integration matches specified one-sided alpha and power. Adaptive resizing
uses native inverse-normal combination weights and always includes the null.
Limit: a particular two-stage normal procedure, not a general adaptation API.

## Phase 4
Files: R/survival.R, R/simulation.R and survival/canonical simulation tests.
Executed deterministic survival/event-stop tests and independent Schoenfeld
formula comparison. Dropout increases required enrollment in the reference
case. Simulation reports MCSE and exact binomial intervals for rejection.
Limit: exponential proportional hazards; independent censoring; uniform accrual.
Survival planning returns native unrounded enrollment and event targets.

## Phase 5
Files: R/presentation.R, inst/shiny/app.R, inst/report.Rmd and presentation tests.
Executed HTML and PDF rendering, plot creation, comparisons, diagnostics, and
Shiny testServer calculations. The first report attempts failed due to missing
namespace qualification and relocated Debian assets; both were repaired.
The phase-5 suite passed 148 assertions without warnings or skips. Expanded
Shiny path tests are included in final-tests.txt and final package checks.
Limit: server smoke tests do not replace interactive browser acceptance testing.

## Phase 6
Files: R/examples.R, 30 standalone example scripts, catalog.csv,
scripts/run-examples.R, scripts/scientific-reference.R and validation artifacts.
Executed all 30 examples with nsim=1000 and seed=2026; all succeeded. Saved
RDS objects and a CSV manifest contain actual outputs. All 12 prespecified
numerical/Monte Carlo reference experiments passed; expected/observed values
and method-specific tolerances are in scientific-reference.csv.
Normal null: 0.0494 (B=5000, nominal .05). Adaptive null: 0.0234 (B=5000,
nominal .025). Survival null: 0.0255 (B=2000, nominal .025). Tolerances are
four theoretical Monte Carlo standard errors; these are diagnostics and do
not prove uniform control. Binary null nuisance probabilities .1/.3/.5 were
also assessed. No failed test has been relabeled as passed.
Limit: the missing original project plan prevents verifying TD-ID mapping.
The catalog remains explicitly provisional. Execution-only example assertions
are distinct from numerical scientific reference checks.

## Phase 7
Files: appended README (original introduction preserved), user-guide vignette,
NEWS.md, CITATION.cff, MIT license, pkgdown configuration, cross-platform CI,
renv.lock, dependency/architecture documents and release checklist.
Executed package build (including vignette), installation, isolated-library
installation and standard R CMD check: Status OK, zero errors/warnings/notes.
The initial --as-cran check had two environment tool warnings (qpdf and
inconsolata) and environment notes; its original log is preserved separately.
The required tools were supplied locally before the successful standard check.
Unresolved: fresh dependency restoration, remote multi-platform CI, independent
scientific/protocol review, interactive browser acceptance, maintainership
contact confirmation and original TD project-plan reconciliation. No release,
GxP qualification or independent scientific validation is claimed.

Final verification update: the expanded complete suite passed 154 assertions,
zero failures/warnings/skips. Shiny testServer exercises fixed, sequential,
adaptive, survival, comparison and example workflows. HTML rendering also
checks an extensionless download destination, with reports rendered from a
temporary workspace so an installed library need not be writable. The final
source tarball was rebuilt and R CMD check again returned Status OK, including
manual PDF, installed examples, tests and vignette reconstruction.


Extended verification: the local suite now passes 159 assertions. Expected
sample size, information, event count and duration summaries include approximate
t-based Monte Carlo intervals. Stopping and event-target probabilities have
marginal exact binomial intervals, without simultaneous-coverage claims.
The expanded suite, all 30 examples and reference experiments were rerun;
R CMD check again returned Status OK. Chromium/Playwright smoke tests passed
for fixed sample size, sequential design/plot, adaptive simulation, survival
planning and HTML report download, with zero JavaScript page errors. The first
browser attempt was blocked by local socket permissions; the permitted local
server then passed. The first remote CI attempt failed before package checking
because the action's error-on expression was incorrectly quoted; corrected to
an R string expression. No remote passing status is inferred from local tests.


Final scientific correction: calendar cutoff subtraction initially caused a
triggering survival event to be censored by floating-point rounding. The
original deterministic 40-event experiment averaged 39.7 recorded events;
calendar-scale comparisons now preserve exactly 40. The defect, regression
and superseded evidence are documented in validation/event-stop-defect.txt.
Negative dropout probabilities, including -1e-16, are rejected. The updated
local and fresh-library installed-package suites each passed 181 assertions,
with zero failures/warnings/skips. The corrected source package passed the
full standard R CMD check with Status OK. Earlier 12-case reference and
remote CI passes predate this event correction and do not validate it.

Locked dependency restoration completed after local OS-header configuration:
92 separately installed packages plus six recommended packages supplied with
R match all 98 locked versions. The first two failed restoration attempts are
retained. The package installs with the original development/site libraries
excluded, and all 181 installed-package assertions pass in that fresh library.
This is an independent R library on the same provisioned OS, not a new OS image.

Final reference extension: all 14 reference experiments passed. In addition to
exact event-target preservation, 2000 independent event-driven equality-null
trials with dropout gave rejection 0.0245 versus nominal one-sided alpha .025,
within the predeclared four-MCSE tolerance 0.01396424. This is one diagnostic
scenario, not proof of uniform error control. Full results are in the final
scientific-reference CSV/text. Original TD mapping and independent scientific
review remain unresolved; the pull request remains a draft.

## Product release 0.2.0

Added schema-versioned JSON projects with frozen defaults/software version,
whitelisted replay, CSV and reproducibility ZIP exports, background simulation
processes, cancellation/error recovery and worker capacity control. All example
jobs are cancellable. Added runtime minimum-version enforcement, native rpact
integer-enrollment planning with recalibrated spending, event-target UI controls,
project snapshots, PDF controls, a downloadable full guide and responsive UI.

Execution evidence: product-tests.txt records 227 passing expectations, no
failures/warnings/skips. Product R CMD check completed Status OK. All 30 examples
were re-executed, along with 14 baseline and two new sequential reference cases.
The new sequential MC estimates were .0282 under the equality null (nominal
.025) and .8008 under the alternative (analytical .80603577), B=5000 each;
both passed predeclared four-theoretical-MCSE tolerances. These are diagnostics,
not uniform-error-control or protocol-qualification claims.

The documentation site was generated, CLI success/failure paths executed and
browser acceptance exercised 14 workflows including import/replay/checksums,
error recovery, cancellation, background adaptation/survival, HTML, PDF and
full-guide download. Mobile layout was checked for horizontal overflow.
A nonroot/read-only Compose deployment was built and started. The local VFS
driver exhausted disk on repeated builds; task-only intermediates were removed,
and final permissions/library-priority metadata applied to the tested image.
The standard Dockerfile contains the same final settings and is tested in CI.
The base image's Renviron.site initially shadowed locked lattice/mgcv versions;
explicit R_LIBS corrects precedence, and all 109 locked versions now match.
Initial failed checks remain documented rather than being treated as passes.

The version-1 product example specification is now defined in the repository;
no mapping to an absent external TD plan is claimed. Local planning/simulation
is the delivery scope. External hosting and protocol-specific/GxP qualification
are not prerequisites invented for this local software release.

A final browser audit found deferred hidden-tab calculations could use controls
edited after a Calculate click. Planning now executes eagerly in observers and
stores results/errors; it does not defer work until an output becomes visible.
The defect and regression are recorded in product-snapshot-correction.txt.


Final source verification now has 235 passing R expectations and 16 browser
workflows, including hidden-tab click-time snapshots and rejection of binary
controls by normal-only procedures. R CMD check remains Status OK. Product
installation now requires R >= 4.5, matching the frozen dependency baseline.
The final standard Dockerfile rebuilt successfully from the pinned base; the
managed 32-GB VFS host then exhausted disk cloning another container root.
No such failed start is a passing execution. The verified native R product is
served on loopback port 3838; final Docker acceptance runs in clean CI. Earlier
successful local container runs and their initial failures remain historical.

Native installation acceptance: scripts/install-product.R restored all 109
locked versions in a versioned library outside the checkout, built and installed
the package with tests. scripts/start-product.R --test passed 235 expectations;
--check and --diagnostics passed, and the starter served all 16 browser workflows.
See product-native-* logs. Dependencies were restored from a prepared local renv
cache; clean OS installation is covered separately by container CI.

The first cross-platform run after the click-time fix found a Windows test
harness race: a job could already have been harvested before the test waited
on its process. The test now accepts an already completed job and retains all
result assertions. The initial failure is retained in
product-windows-initial-failure.txt. Final CI acceptance is linked in PR #1.


## Improvements 0.3.0

Added review_project, scenario_grid, run_scenarios and cancellable
start_scenarios; per-scenario JSON exports and separate failure tables; live
scientific contracts; labelled native controls, keyboard skip link, page language,
contrast and scrollable mobile scenario results. Tests and R CMD check are in
improvements-* logs. Stress verification records 40 executed scenarios and
retains six sparse-binary calibration departures; zero critical reference gates
failed locally. Independent scientific and real-user review remain unperformed;
review packets/templates are supplied without invented endorsements.
A tag-gated workflow publishes verified source, documentation, lock/checksums
and an immutable GHCR image; final run/release URLs are recorded in the PR.


## Sparse-binary and method extensions (0.4.0)

Added binary_diagnostics and explicit Fisher simulation, normal means_design
and simulate_means_design (unequal allocation, NI, exact TOST), and native
simulate_nonph. Methods remain separate from PH/sequential/adaptive adapters.
The lower-direction NI sizing API required a verified sign transformation of
both effect and margin; native lower-direction power and original-scale pooled-t
simulation check that equivalence. Native non-PH getData omits unreached targets,
so the adapter rejects incomplete replications rather than change denominators.
Methods and API/license evidence are recorded in METHOD-EXTENSIONS.md and
method-/PowerTOST-* logs. The locked graph now contains 112 packages.
Local verification passed 321 expectations and 14 prespecified reference cases.
Nine new Chromium workflows and three WCAG A/AA states passed; independent
scientific and real-user review remain pending. Final CI/release URLs belong to
the corresponding pull request and are not inferred from local execution.

GitHub validation run 43853719622 did not start any jobs. The service annotation
states: "The job was not started because recent account payments have failed or
your spending limit needs to be increased." This is an account infrastructure
blocker, not an executed R/package failure. No macOS, Windows or clean-container
pass is claimed for 0.4.0. PR #3 contains the concrete implementation and local
evidence; integration/release remains gated on actual CI execution after the
account is unblocked. Existing v0.3.0 remains the published stable release.
