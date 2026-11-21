# OpenTrialDesign 0.4.1

* Fixed-sample planning now checks achieved power at adjacent integer arm sizes
  to select the smallest supported size meeting the requested power.
* Sequential normal planning preserves exact integer interim looks when the
  product of enrollment and an information fraction rounds upward in floating
  point arithmetic.

* Published the source package, documentation, dependency lockfile, and
  Linux verification record for this version.

# OpenTrialDesign 0.4.0

* Added expected-count diagnostics, visible sparse-binary guidance, downloadable
  historical calibration evidence and explicit Fisher exact simulation.
* Added unequal normal allocation, directional noninferiority and exact TOST
  equivalence through rpact and PowerTOST, with actual integer-arm power.
* Added native piecewise-exponential non-PH simulation, including delayed/crossing
  profiles, equal-curve nulls and full-denominator event-target safeguards.
* Extended JSON, scenario grids, cancellable jobs, reports, scientific review and
  Shiny with the same underlying engine APIs.
* Added 14 new prespecified scientific reference experiments and method-specific
  boundary, regression and browser tests; PowerTOST dependency graph is frozen.

# OpenTrialDesign 0.3.0

* Added pre-execution scientific review of frozen project specifications.
* Added reproducible sensitivity grids, cancellable scenario workers and complete
  batch exports with per-scenario JSON, errors and provenance.
* Added 40 prespecified stress scenarios with MC uncertainty and explicit
  separation of critical reference gates from approximate-test diagnostics.
* Improved keyboard navigation, document language/title, native labelled controls,
  live job status and contrast; added axe WCAG A/AA browser checks.
* Added independent scientific review and real-user usability protocols, with
  honest not-performed status and no invented external-plan mapping.
* Added gated GitHub source/documentation/checksum and GHCR image publication.

# OpenTrialDesign 0.2.0

* Added portable JSON projects with frozen defaults, replay and schema validation.
* Added isolated cancellable jobs, worker limits and error recovery.
* Added integer sequential enrollment with same-engine rpact recalibration.
* Added runtime compatibility diagnostics, CSV/ZIP exports and batch execution.
* Redesigned the responsive app with project import, exports, event targets,
  worker status, reporting capabilities and a downloadable complete guide.
* Added a pinned-base nonroot container, Compose health/resource controls,
  generated documentation site and product acceptance tests.
* Defined the version-1 example specification without claiming an external-plan mapping.

# OpenTrialDesign 0.1.0

* Introduced explicit equal-allocation superiority specifications and stats adapters.
* Added separate gsDesign and rpact spending adapters with explicit futility rules.
* Added native rpact inverse-normal adaptive simulations with null scenarios.
* Added Schoenfeld survival planning and simsurv/logrank operating characteristics.
* Added Monte Carlo standard errors, exact binomial intervals and provenance.
* Added optional shared-engine Shiny interface, HTML/PDF reporting, user guide,
  tests, CI and a provisional 30-scenario example library.
* TD catalog remains provisional pending the absent original project plan.
