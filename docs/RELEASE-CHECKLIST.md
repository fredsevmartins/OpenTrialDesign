# Release acceptance checklist

- [ ] Reconcile provisional TD catalog against the original project plan (not supplied).
- [ ] Confirm the repository author's GitHub noreply address is appropriate for release maintenance.
- [ ] Independent clinical/statistical review of intended use and limitations.
- [ ] Review null scenario grids and simulation precision for each target study.
- [ ] Review rpact installation qualification if GxP use is intended.
- [x] Restore locked dependencies in a fresh R library and run all package tests.
- [x] Browser smoke tests for fixed/sequential/adaptive/survival planning and HTML download.
- [ ] Confirm multi-platform CI for the final event-stopping correction.
- [ ] Approve release metadata and scientific validation status.
- [ ] Publish documentation website and release artifacts when authorized.

Local execution evidence is in validation/. This checklist intentionally does not
claim acceptance of unresolved review or remote CI gates.
