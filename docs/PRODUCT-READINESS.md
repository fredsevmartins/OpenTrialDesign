# Product scope and release criteria

OpenTrialDesign supports reproducible clinical trial planning and simulation
through a browser application, an R package, and a command-line runner.
The criteria below describe software acceptance. Review designs and analyses
against the specific study protocol and applicable requirements.

| Area | Acceptance criterion |
| --- | --- |
| Supported methods | Document each model, statistical engine, and interpretation limit. Use the same rpact procedure for sequential normal enrollment and power. |
| Reproducibility | Validate versioned JSON projects, preserve resolved inputs, and replay calculations through the shared engine. |
| Results | Export project settings, results, and provenance independently of HTML and PDF rendering. |
| Background execution | Expose job state, support cancellation, and provide actionable errors. |
| Browser experience | Keep relevant inputs identifiable and distinguish current controls from the settings used for a stored result. |
| Operations | Document installation, runtime diagnostics, health checks, and command-line execution. |
| Verification | Record the tested revision, platforms, methods, and outcomes for package, browser, scientific, and distribution checks. |

The versioned example catalog documents the assumptions for 30 synthetic
designs. See the [catalog](../inst/examples/catalog.csv),
[method specifications](METHOD-EXTENSIONS.md), and
[validation matrix](VALIDATION-MATRIX.md).

Deployment and release verification have separate records. The
[operations guide](../deployment/README.md) describes installation and hosting.
The [0.4.1 verification record](../dist/v0.4.1/verification.json) records the
checks run for that release.
