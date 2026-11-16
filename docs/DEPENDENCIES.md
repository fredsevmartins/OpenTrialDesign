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

A fresh-library source restoration also required libxml2-dev and ICU development
headers discoverable through pkg-config on the minimal Debian host. These are
OS build dependencies, separate from the R lockfile. The initial failed restore
log is retained rather than being treated as successful.


The optional browser audit uses axe-core 4.10.3 (MPL-2.0; Node >= 4), inspected
through npm metadata before use. It is a test dependency, installed with lifecycle
scripts disabled, and is not bundled into the R runtime or application. WCAG
A/AA checks cover recorded browser states, not an accessibility certification.

For 0.4.0, PowerTOST 1.5-7 (GPL >= 2), mvtnorm 1.4-2 and cubature 2.1.4-1
were checked for availability, metadata and API before integration. Its TOST
parallel/logscale=FALSE/exact interface was inspected from installed formals
and help. All three versions are added to the lockfile (112 packages total).
Native local mvtnorm compilation initially lacked BLAS/LAPACK linker aliases;
a task-specific compiler search directory resolved that managed-environment
limitation. The package/runtime does not rely on that local directory. Standard
R development BLAS/LAPACK libraries are required for source dependency builds.
