# Product acceptance: 0.2.0

The supported product is reproducible clinical-trial planning and simulation
with the documented equal-allocation superiority adapters. It does not promise
qualification for every clinical protocol or regulated use.

Engineering gates (evidence in validation/product-* and Docker logs):
- [x] Package API, reference and boundary cases have executable tests.
- [x] Portable JSON projects freeze defaults and reject executable imports.
- [x] Sequential integer enrollment is recalibrated using the same rpact engine.
- [x] Cancellable background workers preserve seeds and recover from errors.
- [x] Per-session and server-wide worker limits are implemented.
- [x] CSV/ZIP exports, replay, checksums and methodological reports are implemented.
- [x] Responsive browser workflows and local batch execution have been exercised.
- [x] Runtime diagnostics identify absent/incompatible optional capabilities.
- [x] Version-1 example catalog and per-example rationales are defined.
- [x] Complete user guide and navigable documentation are generated.
- [ ] Final package check, clean-container tests and multi-platform CI for 0.2.0.

Use-specific decisions, rather than universal software-installation blockers:
- An actual deployment destination is required for institutional/public hosting.
  Default delivery is local, with a loopback-bound Compose port.
- Review effect sizes, estimands, margins, nuisance grids and simulation precision
  for the actual study. Effects in the example catalog are synthetic.
- Independent protocol review and rpact GxP qualification are not conferred by
  computational checks; no such qualification is claimed by this product.
- The repository's issues page is the configured maintainer contact. The
  original external TD plan was absent; its mapping is not claimed or invented.

Publishing a public endpoint or changing repository visibility is not part of
local installation. No external clinical data or shared database are required.
