# Executed verification evidence

- dependency-audit.txt: installed versions, licenses and API signatures.
- dependency-lock.txt: actual renv snapshot output; clean restore unexecuted.
- phase2-tests.txt: initial foundation tests, 16 passed.
- phase3-4-tests.txt: corrected engine suite, 49 passed.
- examples-tests.txt: package tests including 30 examples, 139 passed.
- phase5-tests.txt: shared-engine UI and HTML-report tests, 148 passed.
- final-tests.txt: expanded complete local suite.
- all-examples.txt / example-execution.csv: all 30 actual example runs, seed
  2026, nsim 1000. TD-*.rds preserve their returned objects.
- scientific-reference.csv / .txt: 12 expected-versus-observed reference cases;
  deterministic numerical tolerances and four-MCSE statistical tolerances.
- install.txt / isolated-install.txt: package installation and isolated library
  smoke test (same provisioned machine, not a fresh OS or dependency restore).
- build.txt / R-CMD-check.log: successful final source build and package check.
- initial-as-cran-check.log: retained initial warnings/notes, not a pass.
- reference-report.html / .pdf: executed methodological report artifacts.

Monte Carlo rejection estimates are not analytical results. Package/adapter
agreement is not independent scientific validation. Expected enrollment, information, event counts and duration means use
approximate t-based Monte Carlo intervals; binomial estimates use marginal
exact intervals without simultaneous coverage claims.
Chromium/Playwright browser smoke tests passed for five workflows, including
a real HTML report download; JSON, screenshot and downloaded report are saved.
Remote CI was started; its first run exposed a check-action quoting defect,
which is corrected. Current results must be read from the remote workflow.


Final event-stop correction supersedes the earlier event-driven results; see
event-stop-defect.txt. The full local and fresh-library suites each pass 181
assertions, and the corrected source R CMD check returns Status OK. Fresh
restore logs preserve failures and the successful OS-header-configured retry.
fresh-lock-comparison.txt verifies all 98 locked versions against 92 restored
packages and six recommended packages supplied by the R installation. The
original development and site libraries were excluded from the fresh test.
The c31d1b2 remote CI snapshot is historical and predates the event correction.

The final reference table now contains 14 executed cases, including the exact
40-event regression and event-driven/dropout equality-null error (0.0245 from
2000 replications, nominal .025). Current event-driven result objects were
regenerated after the correction. All 30 current examples executed successfully.

## Product 0.2.0 evidence

Current release evidence uses product-* files: 227 local expectations, package
check Status OK, 30 executed examples, 14 baseline plus two integer sequential
reference experiments, batch CLI success/nonzero-error behavior, generated
pkgdown documentation and 14 browser workflows. The container is run as UID
10001 with a read-only filesystem. product-container-lock.txt verifies every
locked runtime version; product-container-tests.txt records installed tests and
PDF behavior. product-image.txt identifies the actual local runtime image.
The documentation archive is OpenTrialDesign-docs-0.2.0.zip. The old v0.1 logs
are historical. See product-container-initial-observation.txt and runtime-layer
logs for the initial container failure, VFS storage limitation and final fixes.


Final source update: product-tests.txt has 235 passing expectations and
product-browser.json has 16 passing workflows, including click-time snapshots
with hidden outputs and normal-only endpoint guards. The native R server is
used in the managed environment after its VFS Docker storage limit was reached.
product-final-docker-build.txt records a successful image build; local VFS start
failures are retained and are not passing tests. The definitive final container
execution is the clean CI run linked in the PR, which checks every locked
version, installed-package tests and browser workflows.

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

Current 0.3.0 local acceptance: 262 passing expectations, R CMD check Status OK,
all 16 prior product browser workflows plus seven new sensitivity/review/keyboard
workflows, and zero axe WCAG A/AA violations/incomplete items in three audited
states. See improvements-* and accessibility-audit.json. Older product-* hashes
refer to the 0.2.0 source baseline; improvements-SHA256SUMS covers 0.3.0.

The container's ps/processx disappearing-process race is corrected without
hiding permission failures; worker termination is confirmed before marking
cancellation. Four deterministic assertions cover this path. The corrected
suite has 266 passing expectations. Initial failures remain in
improvements-container-initial-failure.txt and improvements-cancellation-race.txt.
