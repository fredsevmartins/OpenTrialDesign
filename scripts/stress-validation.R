# Prespecified sensitivity screen, not a claim of uniform type I error control.
library(OpenTrialDesign)
dir.create("validation",showWarnings=FALSE)
B<-as.integer(Sys.getenv("OTD_STRESS_NSIM","2000"))
stopifnot(is.finite(B),B>=1000)
rows<-list();index<-0L
record<-function(label,x,expected,gate,classification){
  d<-x$data;index<<-index+1L
  # Five theoretical MCSE: diagnostic per-case tolerance, no simultaneous claim.
  tolerance<-5*sqrt(expected*(1-expected)/d$nsim)
  calibrated<-abs(d$estimate-expected)<=tolerance
  rows[[index]]<<-data.frame(case=label,expected=expected,observed=d$estimate,
    nsim=d$nsim,seed=x$provenance$seed,mcse=d$mcse,lower=d$lower,upper=d$upper,
    tolerance=tolerance,within_screen=calibrated,release_gate=gate,
    classification=classification,method=x$provenance$method)
  cat(label,":",d$estimate,"expected",expected,"screen",calibrated,"gate",gate,"\n");flush.console()
}
# Pooled t reference: small/large n, both directions, two-sided total alpha.
for(n in c(8,64))for(direction in c("two.sided","greater","less")){
  seed<-3100+length(rows)
  s<-trial_spec(effect=if(direction=="less")-.5 else .5,alternative=direction,alpha=.05)
  for(null in c(TRUE,FALSE)){
    x<-simulate_trial(s,n,B,seed,null)
    expected<-if(null).05 else trial_power(s,n)$data$power
    record(paste("normal",n,direction,if(null)"null" else "alternative"),x,expected,TRUE,"exact normal model reference")
  }
}
# Approximate binary tests: flag departures rather than force an exact claim.
for(n in c(10,100))for(p in c(.01,.1,.5,.9,.99)){
  s<-trial_spec("binary",effect=if(p>.8)-.005 else .005,p_control=p)
  x<-simulate_trial(s,n,B,3200+length(rows),TRUE)
  record(paste("binary",n,p,"null"),x,.05,FALSE,"discrete asymptotic test calibration diagnostic")
}
for(spending in c("OF","Pocock"))for(rule in c("none","binding","nonbinding")){
  d<-sequential_design(information=c(.25,.6,1),spending=spending,futility=rule)
  x<-simulate_sequential(d,theta=0,nsim=B,seed=3300+length(rows))
  record(paste("sequential",spending,rule,"enforced null"),x,
    sequential_power(d,0)$data$rejection_probability,TRUE,"matching native numerical integration reference")
  if(rule=="nonbinding"){
    x<-simulate_sequential(d,theta=0,nsim=B,seed=3300+length(rows),enforce_futility=FALSE)
    record(paste("sequential",spending,"nonbinding ignored null"),x,.025,TRUE,"nonbinding efficacy-only error reference")
  }
}
# Calendar/event stops with low events and independent censoring, diagnostic only.
for(n in c(30,100))for(drop in c(0,.25))for(target in list(NULL,20)){
  x<-simulate_survival(n,hazard_ratio=.7,accrual=12,followup=6,dropout=drop,
    events=target,nsim=B,seed=3400+length(rows),null=TRUE)
  record(paste("survival",n,drop,if(is.null(target))"administrative" else "20 events"),
    x,.025,FALSE,"asymptotic logrank under limited events/censoring")
}
# Native inverse-normal procedure under two prespecified resizing limits.
for(limit in c(120,240)){
  x<-adaptive_simulation(max_stage2=limit,nsim=B,seed=3500+length(rows))
  d<-x$data$summary[1,]
  proxy<-list(data=as.list(d),provenance=x$provenance)
  record(paste("adaptive null stage2 limit",limit),proxy,.025,TRUE,"native inverse-normal equality-null diagnostic")
}
out<-do.call(rbind,rows)
utils::write.csv(out,"validation/stress-validation.csv",row.names=FALSE)
writeLines(capture.output(sessionInfo()),"validation/stress-session.txt")
writeLines(c("Prespecified screen: see scripts/stress-validation.R.",
  "Diagnostic departures are retained, especially sparse binary and low-event asymptotic tests.",
  "A screen pass does not establish uniform null control or independent scientific validation.",
  paste("Cases:",nrow(out),"; diagnostic departures:",sum(!out$within_screen)),
  paste("Critical reference failures:",sum(out$release_gate&!out$within_screen))),"validation/stress-summary.txt")
if(any(out$release_gate&!out$within_screen))stop("A prespecified reference gate failed; investigate without widening tolerances")
