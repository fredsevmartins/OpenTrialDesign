# Independent scientific review protocol

Status: **not performed**. Automated results are computational evidence, not
an independent review. A reviewer must be independent of implementation and
record their identity, expertise, conflicts, source revision and review date.
No named reviewer or endorsement is fabricated.

## Reproducible review packet

1. Obtain the release source, SHA256SUMS, dependency lock and CI artifact logs.
2. Run `Rscript scripts/audit-dependencies.R`, the installed package tests,
   `scripts/run-examples.R`, `scripts/scientific-reference.R`,
   `scripts/product-scientific-reference.R` and `scripts/stress-validation.R`.
3. Inspect each public adapter against the documented engine interface and
   references in the user guide. Reproduce selected cases independently.
4. Record findings in findings.csv, with severity, affected workflows, evidence,
   proposed resolution, disposition and independent closure evidence.
5. Sign a review record with the reviewed commit, scope, unresolved findings
   and explicit acceptance/rejection. A software maintainer does not self-sign
   the independent approval column.

## Required scientific questions

- Are the estimand, null/alternative, alpha tail definitions, equal allocation,
  normal variance assumptions and binary score approximations consistent?
- Do integer sequential information, spending, futility semantics and actual
  stopping rules match the same native inferential procedure?
- Are inverse-normal weights fixed before resizing and stage data independent?
  Do resizing bounds and null checks match the intended use?
- Do survival enrollment, calendar stopping, dropout, event counting and signed
  logrank direction preserve the exponential proportional-hazards assumptions?
- Are Monte Carlo precision and intervals reported without implying simultaneous
  coverage or global type I error control? Are sparse/low-event departures visible?
- Are every TD example's assumptions justified? The repository version-1 catalog
  is explicit; its mapping to the absent original external plan remains unresolved.

Independent review cannot be completed by running this protocol automatically.
