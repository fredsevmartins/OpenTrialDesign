# Scientific checks for the explicit new methods; no tolerance selected from output.
library(OpenTrialDesign)
rows<-list()
record<-function(case,expected,observed,tolerance,kind,nsim=NA,seed=NA,mcse=NA,lower=NA,upper=NA,criterion="absolute"){
  ok<-is.finite(observed)&&if(criterion=="upper")observed<=expected+tolerance else abs(observed-expected)<=tolerance
  rows[[length(rows)+1]]<<-data.frame(case=case,expected=expected,observed=observed,tolerance=tolerance,
    passed=ok,kind=kind,criterion=criterion,nsim=nsim,seed=seed,mcse=mcse,lower=lower,upper=upper)
  cat(case,observed,"expected",expected,"passed",ok,"\n");flush.console()
}
B<-5000
for(direction in c("greater","less")){
  plan<-means_design(allocation_ratio=2,alternative=direction)
  x<-simulate_means_design(alternative=direction,n_control=plan$data$n_control,n_treatment=plan$data$n_treatment,nsim=B,seed=4401)
  for(i in 1:2){
    d<-x$data$summary[i,];p<-if(i==1).025 else plan$data$achieved_power
    record(paste("unequal NI",direction,d$scenario),p,d$estimate,4*sqrt(p*(1-p)/B),
      "matched pooled-t Monte Carlo diagnostic",B,4401,d$mcse,d$lower,d$upper)
  }
}
plan<-means_design(hypothesis="equivalence",effect=.02,lower=-.2,upper=.4,allocation_ratio=2)
x<-simulate_means_design(hypothesis="equivalence",effect=.02,lower=-.2,upper=.4,
  n_control=plan$data$n_control,n_treatment=plan$data$n_treatment,nsim=B,seed=4402)
for(i in 1:3){
 d<-x$data$summary[i,]
 p<-means_design(hypothesis="equivalence",effect=d$effect,lower=-.2,upper=.4,n_control=plan$data$n_control,n_treatment=plan$data$n_treatment)$data$rejection_probability
 record(paste("asymmetric TOST",d$scenario),p,d$estimate,4*sqrt(p*(1-p)/B),"exact PowerTOST versus stats TOST",B,4402,d$mcse,d$lower,d$upper)
}
# Exact Fisher conditional test controls equality null; it is not nominally exact
# unconditional rejection probability. Check upper error allowance, not equality.
for(p0 in c(.01,.1,.5,.99)){
 s<-trial_spec("binary",effect=if(p0>.8)-.005 else .005,p_control=p0)
 x<-simulate_trial(s,10,B,4403,TRUE,binary_test="fisher")
 d<-x$data
 record(paste("Fisher sparse null",p0),.05,d$estimate,4*sqrt(.05*.95/B),
   "one-sided screen for excess unconditional error; conservatism permitted",B,4403,d$mcse,d$lower,d$upper,criterion="upper")
}
# Native generator's PH special case and delayed/crossing equality nulls.
profiles<-list(PH=list(control=c(.06,.06),treatment=c(.03,.03),at=1,ac=1),
 delayed=list(control=c(.03,.06),treatment=c(.03,.03),at=2,ac=1),
 crossing=list(control=c(.08,.04),treatment=c(.10,.02),at=1,ac=2))
for(i in seq_along(profiles)){
 spec<-profiles[[i]];chosen_seed<-4404+i
 x<-simulate_nonph(lambda_control=spec$control,lambda_treatment=spec$treatment,n_total=240,events=100,
   allocation_treatment=spec$at,allocation_control=spec$ac,nsim=B,seed=chosen_seed)
 d<-x$data$summary[1,]
 record(paste("piecewise logrank null",names(profiles)[i]),.025,d$estimate,
   4*sqrt(.025*.975/B),"native equal-curve null across control profiles and allocation; no composite-null claim",B,chosen_seed,d$mcse,d$lower,d$upper)
}
utils::write.csv(do.call(rbind,rows),"validation/method-reference.csv",row.names=FALSE)
writeLines(capture.output(sessionInfo()),"validation/method-reference-session.txt")
if(!all(vapply(rows,function(x)x$passed,logical(1))))stop("A prespecified method reference failed")
