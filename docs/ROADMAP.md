# Implementation roadmap and acceptance gates

Baseline: 2026-11-15, upstream commit 209a42f. Only README.md existed.
No AGENTS.md or TD-001--TD-030 project plan was supplied or found.
Original README preserved. Work occurs on implementation/scientific-platform.

1. Baseline: inspect Git, runtime, dependency metadata, exported signatures and licenses.
   Gate: reproducible dependency audit committed with session metadata.
2. Foundation: installable package, explicit estimands, fixed normal/binary designs.
   Gate: numerical agreement with stats, invalid input and rounded-size tests.
3. Sequential/adaptive: isolated gsDesign and rpact adapters; engine-native objects.
   Gate: documented alpha conventions, spending and futility semantics, null OC checks.
   Adaptive sample-size changes require a verified inferential procedure; no ad hoc resizing.
4. Survival/simulation: event targets, accrual, censoring, simsurv and survival analysis.
   Gate: deterministic replication, exact binomial Monte Carlo intervals and null scenarios.
5. UX: shared-engine Shiny, plots, HTML/PDF methodological reports.
   Gate: UI calls public API; rendering and UI smoke checks executed.
6. Verification: execute each example and reference/boundary tests.
   Gate: persisted observed results and method-specific numerical tolerances.
7. Release: documentation, citation, CI, dependency lock and release checklist.
   Gate: clean install and R CMD check with zero errors/warnings.

Example IDs will use a clearly identified provisional catalog until the missing project
plan is supplied. Execution does not establish independent scientific validation.
