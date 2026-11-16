OpenTrialDesign 0.4.0 adds visible sparse-binary diagnostics and explicit Fisher
simulation; independent normal unequal-allocation superiority/noninferiority;
exact parallel TOST equivalence through PowerTOST; and native rpact piecewise
non-PH survival simulation with full-denominator event-target safeguards.

Mean effects/margins use treatment minus control. NI tests the loss margin;
TOST requires both one-sided component rejections at alpha (global IUT level
alpha, not 2*alpha). Margins require clinical justification. Lower-direction
normal sizing explicitly reverses both outcome and null margin for the native
engine and preserves the original reported estimand.

Fisher simulation never makes the approximate binary sample-size calculation
exact. Piecewise survival evaluates a logrank decision, not a constant HR or
uniform benefit under crossing hazards. Unreached event targets abort rather
than silently omitting trials. See docs/METHOD-EXTENSIONS.md for complete scope.

This prerelease was authorized for publication without hosted CI after GitHub
blocked jobs for account billing/spending limits. Source, documentation, locked
dependencies, full local evidence, verification.json and SHA256 checksums are
provided. Local Linux validation is the acceptance evidence; Windows, macOS and
clean-container verification were not performed for 0.4.0. No new prebuilt
container image is published, and the previous 0.3.0 image is not relabelled.

Independent scientific/user evaluation remains unperformed; computational checks
do not confer protocol-specific or regulatory qualification. Existing repository
and package access controls are preserved.
