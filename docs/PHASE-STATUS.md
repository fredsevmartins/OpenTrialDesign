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
