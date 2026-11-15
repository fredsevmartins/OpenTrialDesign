# Dependency audit and compatibility

The actual exports, formals, versions, licenses, Depends and Imports were
inspected in validation/dependency-audit.txt before engine adapters were used.
The tested baseline is R 4.5.0, stats 4.5.0, survival 3.8-3, simsurv 1.0.1,
ggplot2 3.5.1, gsDesign 3.11.0 and rpact 4.4.0 on Debian 13 amd64.
The DESCRIPTION minima reflect these inspected interfaces, not proof that
unexecuted older/newer versions are equivalent. renv.lock pins the complete
tested graph; a fresh restore remains an explicit release gate.

stats is distributed with R; survival is LGPL (>= 2); ggplot2 is MIT;
gsDesign is GPL (>= 3); rpact is LGPL-3; simsurv is GPL (>= 3) or its file
license. See the audit for exact installed declarations and dependencies.
OpenTrialDesign is MIT licensed and calls these packages through namespaces;
it does not copy their implementation. Redistributors must separately respect
licenses of bundled engines and transitive dependencies.

Engine objects and assumptions remain isolated. No equality of OF spending
functions between gsDesign and rpact is assumed. Canonical information is not
interpreted as enrollment. Adaptive resizing uses rpact's inverse-normal
combination procedure, not the fixed stats t test. Survival planning uses the
Schoenfeld approximation with exponential enrollment/event assumptions; patient
simulation uses the matching exponential model and signed logrank analysis.

Initial limitations resolved: no system R, read-only apt directories, local
Fortran linker search path, static V8 dependency for gt/gsDesign, relocated
JavaScript assets, qpdf and inconsolata manual-build fonts. The standard package
uses ordinary R/CRAN dependencies; these local provisioning repairs are not
runtime code inside the package. rpact's GxP qualification was not performed.
