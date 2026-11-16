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
| Version-1 examples | All 30 at nsim=1000, seed=2026; 30 saved result objects; synthetic assumptions and rationales documented | Executed, not individually independently validated |
| Shiny | testServer exercises all calculation families | Shared-engine server verification; separate Chromium smoke test passed |
| HTML/PDF | Actual rendered reference files | Rendering dependencies verified locally |
| Package | R CMD build, install, fresh-library tests and R CMD check Status OK | Current Linux/R/dependency baseline only |

The event-stopping floating-point defect and its correction are recorded in
validation/event-stop-defect.txt. A deterministic reached-event regression
requires exactly 40 events; event-driven null error with dropout is assessed
separately. Exact observed numerical results are in validation/scientific-reference.csv.
No test infers noninferiority/equivalence, uniform null control, general adaptive
validity, or compatibility between different engines. Monte Carlo checks have
sampling uncertainty even when they pass. The package has not undergone
independent scientific or regulatory validation.

Chromium/Playwright browser smoke verification exercised fixed sample size,
sequential design with a rendered plot, adaptive simulation, survival planning,
and HTML report download. There were no JavaScript page errors. Evidence is in
validation/browser-smoke.json and validation/shiny-browser.png. This does not
constitute exhaustive usability, mobile, or accessibility acceptance.


## Version 0.3.0 additional verification

The executed stress suite in validation/stress-validation.csv covers 40
prespecified scenarios with 2000 replications each (per adaptive scenario).
All critical matched-reference gates passed locally. Six sparse binary cases
fell outside the prespecified five-theoretical-MCSE diagnostic band; these are
retained as approximation limitations, not release gates or fabricated passes.
Each row includes its seed, estimate, MCSE, exact 95% interval and classification.

Scientific review and real-user usability protocols in docs/review are pending
external execution. Automated browser acceptance adds seven workflows and axe
WCAG A/AA checks for three states, retaining incomplete/manual-review items.
This is not an independent scientific or accessibility certification.


## 0.4.0 method extensions

The new reference script runs 14 prespecified comparisons with 5000 replications
per scenario. NI is checked at the actual positive/negative loss margin and
alternative; asymmetric unequal TOST is compared with exact PowerTOST rejection
probability; sparse Fisher checks permit conservatism but screen excess null
error; native non-PH logrank null checks vary baseline profile and allocation.
Seeds, observed estimates, MCSE, exact intervals and tolerances are retained in
method-reference.csv. The finite null grid is not uniform-error certification.
Native non-PH incomplete event analyses abort rather than alter the denominator.
