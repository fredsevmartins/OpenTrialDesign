# Validation matrix

| Workflow | Executed check | Interpretation |
|---|---|---|
| Normal sample size | Unrounded stats agreement 1e-8; integer size 64; achieved power | Adapter/reference agreement |
| Binary directional size | stats one-sided reference agreement 1e-8 | Direction and engine agreement |
| Normal empirical error | 5000 simulations; nominal .05; four-MCSE tolerance | Equality-null diagnostic |
| Binary empirical error | 5000 per nuisance probability .1/.3/.5 | Limited nuisance grid; score approximation |
| OF/Pocock spending | gsProbability null .025 at 1e-6; alternative .8 at 1e-5 | Numerical integration/reference consistency |
| Futility | Binding rule cannot be ignored; nonbinding actual error <= nominal | Stopping semantics and implementation |
| Canonical sequential simulation | Null at 10000 replications; four-MCSE tolerance | Independent increments generator diagnostic |
| rpact spending | Absolute final alpha-spent discrepancy <1e-7 | Engine tolerance, not cross-engine equivalence |
| Adaptive inverse normal | Null and alternative; 5000 null replications; fixed weights | Native inferential procedure with finite MC diagnostic |
| Schoenfeld target | Independent closed form within 1e-4 events | Formula and adapter agreement |
| Survival simulation | 2000 null replications; nominal .025; four-MCSE tolerance | Limited exponential/null scenario diagnostic |
| Event stopping/dropout | Deterministic seed; target attainment and calendar cap | Operational assumptions exercised |
| Provisional examples | All 30 at nsim=1000, seed=2026; 30 saved result objects | Executed, not individually independently validated |
| Shiny | testServer exercises all calculation families | Shared-engine server verification; separate Chromium smoke test passed |
| HTML/PDF | Actual rendered reference files | Rendering dependencies verified locally |
| Package | R CMD build, install and R CMD check Status OK | Current Linux/R/dependency baseline only |

Exact observed numerical results are in validation/scientific-reference.csv.
No test infers noninferiority/equivalence, uniform null control, general adaptive
validity, or compatibility between different engines. Monte Carlo checks have
sampling uncertainty even when they pass. The package has not undergone
independent scientific or regulatory validation.

Chromium/Playwright browser smoke verification exercised fixed sample size,
sequential design with a rendered plot, adaptive simulation, survival planning,
and HTML report download. There were no JavaScript page errors. Evidence is in
validation/browser-smoke.json and validation/shiny-browser.png. This does not
constitute exhaustive usability, mobile, or accessibility acceptance.
