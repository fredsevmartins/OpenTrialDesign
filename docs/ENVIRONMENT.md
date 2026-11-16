# Executed technical baseline

Date: 2026-11-15 UTC. Upstream initial commit: 209a42f. Host: Debian 13,
amd64, initially no R. Repository contained only README.md, with no AGENTS.md,
project plan, package code or tests. Work is isolated on a new branch.

A local R 4.5.0 runtime was provisioned under /workspace/r-local from Debian
snapshot packages; system files were not overwritten. R package development
and rendering tools were installed from Debian/CRAN. Additional CRAN scientific
engines were compiled locally. The local compiler required an explicit Fortran
library search path. gsDesign's gt dependency required static V8. Debian
package asset symlinks were resolved to existing JavaScript assets. qpdf and
CTAN inconsolata fonts were added locally for a full manual check.

The runtime provisioning tree is outside the source repository. For ordinary
users, a standard working R installation plus CRAN packages is sufficient;
platform dependency management belongs to that installation. renv.lock records
R/dependency versions, not an entire OS image. Fresh lockfile restoration and
multi-platform checks remain separate, unexecuted acceptance gates.

Fresh source dependency restoration required local libxml2-dev and libicu-dev
headers, with PKG_CONFIG_PATH pointing to the relocated development files.
The first transactional attempt rolled back after missing libxml2 headers;
a retry retains partial progress and uses a writable renv cache.
