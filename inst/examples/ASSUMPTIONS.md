# Scientific assumptions and rationale for the provisional TD catalog

These are synthetic teaching/planning scenarios, not observed clinical data or
recommended effects for a specific indication. The chosen contrasts demonstrate
methods and have no claimed clinical evidence. Clinical use requires an
externally justified effect or margin, estimand, variance, event model,
recruitment model and missing-data strategy. No such evidence was supplied.
All examples use equal allocation. Power .8 and the illustrated alpha values
are scenario choices, not universally appropriate requirements.

## TD-001: Normal superiority

Assumptions: Independent normal observations; common SD 1; equal allocation; two-sided alpha .05; power .8.

Rationale: Standardizing SD to one makes the mean contrast interpretable in SD units and permits a direct noncentral-t reference.

## TD-002: Normal directional benefit

Assumptions: Positive treatment-control mean; one-sided alpha .025.

Rationale: Positive mean benefit and upper-tail rejection agree; alpha .025 allows comparison with the two-sided .05 planning case.

## TD-003: Normal directional reduction

Assumptions: Negative treatment-control mean; one-sided lower-tail alpha .025.

Rationale: Negative mean benefit requires a lower-tail test; this checks direction rather than changing the absolute contrast.

## TD-004: Higher target power

Assumptions: Common SD 1; two-sided alpha .05; 90 percent power.

Rationale: Increasing target power with all other assumptions fixed isolates the enrollment cost of reducing type II error.

## TD-005: Normal power at enrollment

Assumptions: 64 independent participants per arm; pooled two-sample t test.

Rationale: The rounded design from TD-001 is evaluated at its operational integer size, instead of reporting only an unrounded root.

## TD-006: Binary superiority

Assumptions: Response probabilities .30 versus .45; normal approximation; no continuity correction.

Rationale: Interior response probabilities keep the demonstration away from boundary degeneracy; asymptotic power still needs finite-sample assessment.

## TD-007: Binary reduction

Assumptions: Treatment response .35 versus control .50; lower response beneficial; one-sided alpha .025.

Rationale: Lower response is beneficial in this scenario; reversed risk difference and lower-tail testing must remain aligned.

## TD-008: Binary analytical power

Assumptions: 180 per arm; treatment .45; control .30; asymptotic power.

Rationale: A prespecified integer enrollment is used to demonstrate achieved power, separate from target-power sample-size solving.

## TD-009: gsDesign OF spending

Assumptions: Upper efficacy alpha .025; three information looks; no futility; canonical normal model.

Rationale: Three prespecified information looks illustrate conservative early OF spending without an optional stopping ambiguity.

## TD-010: gsDesign Pocock spending

Assumptions: Two looks at .5 and 1; Lan-DeMets Pocock spending; upper efficacy alpha .025.

Rationale: Pocock spending demonstrates a different prespecified allocation of efficacy error across looks.

## TD-011: rpact OF spending

Assumptions: Engine-specific OF spending; two looks; one-sided alpha .025; no futility.

Rationale: Retaining the rpact native design tests the adapter without assuming its OF approximation equals another engine.

## TD-012: rpact Pocock spending

Assumptions: rpact asP spending; two looks; no futility.

Rationale: The engine-native Pocock procedure is retained so spending semantics are not transferred between packages.

## TD-013: gsDesign binding futility

Assumptions: Binding lower beta-spending boundary; upper alpha .025; futility must be followed.

Rationale: Binding beta-spending permits alpha calibration conditional on following futility; ignoring that rule would change inference.

## TD-014: gsDesign nonbinding futility

Assumptions: Upper alpha control ignores lower futility; actual power assumes lower stopping.

Rationale: Nonbinding calibration illustrates that actual rejection and expected information depend on whether lower stopping is followed.

## TD-015: rpact nonbinding futility

Assumptions: rpact Hwang-Shih-DeCani beta spending gamma -2; nonbinding futility.

Rationale: Explicit gamma -2 and nonbinding beta spending make the native rpact futility assumptions inspectable.

## TD-016: Interim conditional power

Assumptions: Interim Z 1.5 at half information; future drift at prespecified design alternative.

Rationale: A fixed interim Z value illustrates conditional continuation probability; no adaptation is inferred from this calculation.

## TD-017: Sequential analytical null

Assumptions: Numerical integration under zero canonical drift; one-sided alpha .025.

Rationale: Zero canonical drift is the equality null for the upper-tail efficacy test and directly assesses the intended alpha.

## TD-018: Sequential Monte Carlo null

Assumptions: Independent canonical normal increments; zero drift; exact Monte Carlo interval.

Rationale: Independent normal increments match the canonical engine model, allowing simulation and integration to be compared.

## TD-019: Sequential Monte Carlo power

Assumptions: Canonical drift from native design alternative; prespecified information times.

Rationale: Using the native alternative drift avoids incorrectly interpreting normalized information as a patient-level effect.

## TD-020: Adaptive inverse normal

Assumptions: Independent normal stages; fixed combination weights; native conditional-power resizing; null and alternative.

Rationale: Independent stage data and fixed combination weights are the inferential basis for native inverse-normal resizing; both hypotheses are assessed.

## TD-021: Adaptive capped enrollment

Assumptions: Stage-two total enrollment limited to 40--120; fixed inverse-normal weights; both hypotheses simulated.

Rationale: Changing only the enrollment cap isolates an operational constraint while retaining the same combination-test inference.

## TD-022: Survival planning

Assumptions: Treatment/control HR .7; exponential control median 12; uniform accrual 18; additional follow-up 12; no dropout.

Rationale: Exponential proportional hazards and uniform accrual permit an independent Schoenfeld event-target comparison.

## TD-023: Survival dropout planning

Assumptions: Independent exponential dropout with 10 percent probability by month 12; proportional hazards.

Rationale: Dropout is modeled independently with an explicit time-specific probability, so its enrollment consequence can be isolated.

## TD-024: Longer survival follow-up

Assumptions: Additional follow-up 24 after accrual 18; exponential proportional hazards; equal allocation.

Rationale: Additional follow-up changes event yield without changing the required proportional-hazards event contrast.

## TD-025: Survival simulated power

Assumptions: Exponential HR .7; uniform entry; administrative cutoff at 30; one-sided logrank alpha .025.

Rationale: Patient-level exponential events match the planning model; censoring and signed logrank analysis are specified separately.

## TD-026: Survival equality null

Assumptions: HR 1 equality null; independent censoring; one-sided lower-tail logrank test.

Rationale: HR one is the equality null; the analysis retains the same one-sided benefit rejection rule as the alternative scenario.

## TD-027: Survival event stopping

Assumptions: Stop at event 240 or administrative cap 30; independent dropout; target attainment explicitly reported.

Rationale: An administrative cap and event target are both stated, and target attainment is measured rather than assumed.

## TD-028: Binary simulated power

Assumptions: Uncorrected Pearson score test; .30 control and .45 treatment; finite-sample power may differ from planning.

Rationale: The actual score test is simulated because a discrete finite-sample test can differ from asymptotic planning power.

## TD-029: Binary equality null

Assumptions: Both response probabilities .30; two-sided uncorrected score test; empirical equality-null error.

Rationale: Equal binary probabilities evaluate the appropriate null; a limited nuisance grid is assessed separately in reference experiments.

## TD-030: Normal simulated power

Assumptions: Independent normal observations; common SD 1; pooled t test; two-sided alpha .05.

Rationale: Normal pooled-t simulation matches the analytical model and supplies an independent Monte Carlo view of achieved power.
