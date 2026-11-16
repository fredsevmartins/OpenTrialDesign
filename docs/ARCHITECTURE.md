# Architecture

R/specification.R owns validation, structured conditions and provenance.
R/fixed.R delegates to stats. R/sequential.R owns isolated gsDesign/rpact
adapters and canonical simulation. R/adaptive.R retains rpact's native
combination-test procedure. R/survival.R separates event planning from
simsurv generation and survival logrank analysis. R/simulation.R owns fixed
trial replication and Monte Carlo summaries. R/presentation.R contains
plotting, diagnostics, comparisons and rendering. R/examples.R is the public
example registry; inst/examples includes standalone scripts and assumptions.
inst/shiny/app.R delegates all statistical calculations to exported functions.
The statistical core never imports Shiny. Native objects remain within their
originating engines; outputs do not imply cross-engine equivalence.

otd_spec objects must be constructed with trial_spec; modified lists are rejected.
otd_result objects contain kind, data, specification and provenance. Optional
engines raise otd_dependency_error; input failures raise otd_input_error.
Simulation failures do not silently alter the replication denominator.
