# Scientific scope of the 0.4.0 method extensions

## Sparse binary data

Expected cell counts below five trigger a visible descriptive warning, not a
claim that five is sufficient for calibration. The result, diagnostics API,
scientific review, report and project exports retain the chosen analysis.
Historical 0.3.0 score-test evidence (10 nuisance/sample-size cases, six outside
the original screen) is downloadable with its origin explicitly identified.

`simulate_trial(..., binary_test="fisher")` calls stats::fisher.test on the
2x2 table. Its equality-null conditional odds-ratio test has the same equality
and directional ordering as the risk-difference superiority hypotheses here.
It is discrete and can be conservative; it is not a noninferiority or
risk-difference-margin test. The sample-size planner continues to use
stats::power.prop.test's approximation. Selecting Fisher never silently changes
sample sizing or promises exact unconditional power. Evaluate actual enrollment
under both null and alternative and retain Monte Carlo uncertainty. More
replications improve precision but cannot repair a miscalibrated test.

## Unequal allocation and normal margin tests

The new means_design adapter supports independent parallel normal groups with
common SD, arbitrary positive planned treatment/control ratio, and integer
realized group sizes. No binary, sequential or adaptive NI/equivalence extension
is claimed. Clinical justification and prespecification of margins are required;
the illustrative margin .3 is synthetic, not a clinical recommendation.

- Superiority: effect = treatment minus control, greater/less/two-sided. Alpha
  is total for two-sided superiority and one-sided otherwise.
- Noninferiority, higher is better: H0 delta <= -margin, H1 delta > -margin.
- Noninferiority, lower is better: H0 delta >= margin, H1 delta < margin.
- Equivalence: H0 delta <= lower OR delta >= upper; H1 lower < delta < upper.
  Both one-sided component tests must reject at alpha. The intersection-union
  test's level is alpha, not 2*alpha. The CI interpretation uses 1-2*alpha.
  A nonsignificant superiority result is never interpreted as equivalence.

rpact 4.4.0 getSampleSizeMeans/getPowerMeans use fixed t-approximation planning
for superiority/NI. Native sample sizing supports upper-direction alternatives;
for a lower-direction question this adapter inverts BOTH outcome difference and
null margin, preserving variance, allocation and the original reported estimand.
Tests compare transformed sizing with native lower-direction power and with
stats pooled-t simulation on the original scale. This establishes compatibility
for that transformation; no other engine boundaries are transferred.

PowerTOST 1.5-7 power.TOST, design="parallel", logscale=FALSE, method="exact"
uses Owen Q for common-variance TOST. In this mode CV is the SD of the response,
not a geometric CV. sampleN.TOST supplies a balanced bracket; an integer search
uses native exact unequal-n power for every candidate. Final reported power is
recomputed at the actual integer arms. This is not the product of two separate
one-sided powers, nor a noncentral-t approximation substituted for exact TOST.

Supplying both arm counts evaluates analytical rejection probability at the
specified effect. Under a null/boundary effect, achieved_power is NA and the
probability is labelled null/boundary. The simulation workflow evaluates the
proper NI boundary or both equivalence boundaries, plus the named alternative.
A finite boundary grid does not prove uniform composite-null control.

## Nonproportional survival hazards

simulate_nonph calls native rpact getSimulationSurvival with explicit interval
starts and lambda1/lambda2 vectors, allocation block counts, accrual, independent
dropout and a final event target. Hazard intervals refer to subject follow-up,
not study calendar time; the final interval is unbounded. Delayed and crossing
profiles are supported. No constant HR is reported as the estimand. The chosen
ordinary one-sided logrank decision targets lower treatment hazards; with
crossing hazards it can have poor power and rejection is not uniform survival
dominance. This is not an RMST or weighted/max-combo logrank procedure.

There is no additional administrative follow-up cap in this native workflow.
Sample-size planning under non-PH is performed by explicit simulation scenario
comparisons, not the PH Schoenfeld formula. The older PH planner remains separate.

An API probe showed that native getData omits analyses whose event target cannot
be reached. The adapter therefore requires a full nsim terminal record set and
native rejection-count agreement. If any target is unreached it aborts rather
than changing the denominator or inventing an analysis rule. Revise enrollment,
event target or dropout and run a new complete experiment. Rejection intervals
are exact binomial; mean analysis-time intervals use an approximate t-based
Monte Carlo interval. Equal-curve null checks do not establish control for every
composite non-PH null.

## Executed computational evidence

scripts/method-reference.R prespecifies 5000 replications per scenario, deterministic
seeds and four theoretical-MCSE tolerances. It checks NI in both directions,
unequal/asymmetric TOST against exact PowerTOST, sparse Fisher null error (an
upper-error screen permits conservatism), and native equal-curve logrank nulls
across baseline hazard profiles and allocation ratios. Observed estimates,
MCSE, exact intervals and tolerances are in validation/method-reference.csv.
Unit/boundary tests and real Chromium flows are separate. Computational checks
are not independent scientific or regulatory qualification.
