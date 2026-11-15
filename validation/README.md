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
agreement is not independent scientific validation. Expected information,
expected sample size, event count and duration summaries do not yet include
uncertainty intervals; only rejection probabilities have full MC intervals.
Remote CI and browser-level UI checks have not been executed in this session.
