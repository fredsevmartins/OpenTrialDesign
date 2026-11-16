means_contract <- function(hypothesis,effect,sd,alpha,power,alternative,margin,lower,upper) {
  hypothesis<-match.arg(hypothesis,c("noninferiority","equivalence","superiority"))
  alternative<-match.arg(alternative,c("greater","less","two.sided"))
  scalar(effect,"effect",-Inf,Inf);scalar(sd,"sd",0,Inf)
  scalar(alpha,"alpha",0,.5);scalar(power,"power",alpha,1)
  if(hypothesis=="noninferiority"){
    scalar(margin,"margin",0,Inf)
    if(alternative=="two.sided")fail("Noninferiority requires a prespecified one-sided direction")
    h0<-if(alternative=="greater")-margin else margin
  }else h0<-0
  if(hypothesis=="equivalence"){
    scalar(lower,"lower",-Inf,Inf);scalar(upper,"upper",lower,Inf)
    if(alternative!="greater")fail("Equivalence uses two one-sided tests; leave alternative='greater' (not an equivalence direction selector)")
  }
  list(hypothesis=hypothesis,effect=effect,sd=sd,alpha=alpha,power=power,
    alternative=alternative,margin=margin,lower=lower,upper=upper,thetaH0=h0,
    effect_in_alternative=if(hypothesis=="equivalence")effect>lower&&effect<upper else
      if(alternative=="greater")effect>h0 else if(alternative=="less")effect<h0 else effect!=h0,
    estimand="treatment minus control normal mean; independent groups, common variance")
}
means_native_power <- function(s,n_control,n_treatment) {
  if(s$hypothesis=="equivalence"){
    need("PowerTOST")
    return(PowerTOST::power.TOST(alpha=s$alpha,logscale=FALSE,theta0=s$effect,
      theta1=s$lower,theta2=s$upper,CV=s$sd,n=c(n_treatment,n_control),
      design="parallel",method="exact"))
  }
  need("rpact")
  args<-list(kMax=1,sided=if(s$alternative=="two.sided")2 else 1,alpha=s$alpha,beta=1-s$power)
  if(s$alternative=="two.sided")args$twoSidedPower<-TRUE
  d<-do.call(rpact::getDesignGroupSequential,args)
  orientation<-if(s$alternative=="less")-1 else 1
  args<-list(design=d,alternative=orientation*s$effect,thetaH0=orientation*s$thetaH0,
    normalApproximation=FALSE,stDev=s$sd,maxNumberOfSubjects=n_control+n_treatment,
    allocationRatioPlanned=n_treatment/n_control)
  if(s$alternative!="two.sided")args$directionUpper<-TRUE
  as.numeric(do.call(rpact::getPowerMeans,args)$overallReject)
}
#' Plan or evaluate unequal-allocation normal superiority, noninferiority or equivalence
#'
#' NI uses rpact's fixed one-sided t approximation with a nonzero thetaH0.
#' A positive margin means allowable loss: H0 delta <= -margin for greater,
#' or H0 delta >= margin for less. Equivalence uses PowerTOST's exact parallel
#' pooled-t TOST power (Owen Q), with alpha for EACH one-sided component; this
#' intersection-union test has level alpha, not 2*alpha. The confidence interval
#' interpretation is 100*(1-2*alpha) percent. Margins require clinical justification.
#' No NI/equivalence extension to binary, sequential or adaptive tests is implied.
#' @param hypothesis Noninferiority, equivalence or superiority.
#' @param effect Assumed treatment minus control mean difference.
#' @param sd Common normal standard deviation.
#' @param allocation_ratio Planned treatment/control allocation ratio for sizing.
#' @param alpha One-sided NI/TOST alpha, or total alpha for two-sided superiority.
#' @param power Target power for sizing.
#' @param alternative Greater or less; two.sided is only for superiority.
#'   Equivalence uses both directions internally; leave greater for that workflow.
#' @param margin Positive noninferiority loss margin.
#' @param lower,upper Prespecified equivalence bounds on the mean difference.
#' @param n_control,n_treatment Both NULL for sizing; both integers for power.
#' @return An otd_result with integer arms, realized ratio and achieved power.
#' @export
#' @examples
#' if (requireNamespace("rpact",quietly=TRUE)) means_design(allocation_ratio=2)
means_design <- function(hypothesis="noninferiority",effect=0,sd=1,allocation_ratio=1,
                         alpha=.025,power=.8,alternative="greater",margin=.3,
                         lower=-.3,upper=.3,n_control=NULL,n_treatment=NULL) {
  s<-means_contract(hypothesis,effect,sd,alpha,power,alternative,margin,lower,upper)
  scalar(allocation_ratio,"allocation_ratio",0,Inf)
  planning<-is.null(n_control)&&is.null(n_treatment)
  if(xor(is.null(n_control),is.null(n_treatment)))fail("Provide both integer arm sizes or neither")
  native<-NULL
  if(planning){
    if(s$hypothesis=="equivalence"){
      if(effect<=lower||effect>=upper)fail("Sizing equivalence requires the assumed effect strictly inside the margins")
      need("PowerTOST")
      native<-PowerTOST::sampleN.TOST(alpha=alpha,targetpower=power,logscale=FALSE,
        theta0=effect,theta1=lower,theta2=upper,CV=sd,design="parallel",method="exact",print=FALSE,details=FALSE)
      # Search integer arms using native exact power, without an approximate
      # unequal-allocation sizing formula. The balanced result brackets a search.
      balanced<-as.numeric(native[["Sample size"]])/2
      high<-max(2,ceiling(balanced*max(1,1/allocation_ratio)))
      if(!is.finite(high)||high>=.Machine$integer.max/max(1,allocation_ratio))fail("Planned sample size exceeds supported integer range")
      low<-2
      while(low<high){
        mid<-floor((low+high)/2)
        if(means_native_power(s,mid,max(2,ceiling(mid*allocation_ratio)))>=power)high<-mid else low<-mid+1
      }
      n_control<-low
    } else {
      if(s$alternative=="greater"&&effect<=s$thetaH0 || s$alternative=="less"&&effect>=s$thetaH0 ||
        s$alternative=="two.sided"&&effect==0)fail("Sizing effect must lie on the specified alternative side of the null margin")
      need("rpact")
      args<-list(kMax=1,sided=if(alternative=="two.sided")2 else 1,alpha=alpha,beta=1-power)
      if(alternative=="two.sided")args$twoSidedPower<-TRUE
      d<-do.call(rpact::getDesignGroupSequential,args)
      orientation<-if(alternative=="less")-1 else 1
      native<-rpact::getSampleSizeMeans(d,alternative=orientation*effect,thetaH0=orientation*s$thetaH0,
        stDev=sd,normalApproximation=FALSE,allocationRatioPlanned=allocation_ratio)
      n_control<-max(2,ceiling(as.numeric(native$nFixed2)))
    }
    if(!is.finite(n_control)||n_control>=.Machine$integer.max/max(1,allocation_ratio))fail("Planned sample size exceeds supported integer range")
    n_treatment<-max(2,ceiling(n_control*allocation_ratio))
    achieved<-means_native_power(s,n_control,n_treatment)
    steps<-0L
    while(achieved<power-1e-10){
      n_control<-n_control+1;n_treatment<-max(2,ceiling(n_control*allocation_ratio));steps<-steps+1L
      if(steps>10000)fail("Integer enrollment search did not converge", "otd_engine_error")
      achieved<-means_native_power(s,n_control,n_treatment)
    }
  } else {
    integer_count(n_control,"n_control",2);integer_count(n_treatment,"n_treatment",2)
    achieved<-means_native_power(s,n_control,n_treatment)
  }
  s$allocation_ratio_planned<-allocation_ratio;s$n_control<-n_control;s$n_treatment<-n_treatment
  s$engine_orientation<-if(alternative=="less"&&s$hypothesis!="equivalence")"Outcome sign inverted for native upper-direction sizing/power; original estimand retained" else "Original outcome orientation"
  s$operation<-if(planning)"sample size" else "analytical power"
  engine<-if(s$hypothesis=="equivalence")"PowerTOST" else "rpact"
  result("extended normal mean design",list(n_control=n_control,n_treatment=n_treatment,
    n_total=n_control+n_treatment,allocation_ratio_realized=n_treatment/n_control,
    rejection_probability=achieved,achieved_power=if(s$effect_in_alternative)achieved else NA_real_,
    evaluated_scenario=if(s$effect_in_alternative)"alternative" else "null or boundary",
    native=list(note="Initialization/reference output only: final integer arm sizes and rejection probability are the top-level results",planning_reference=native)),s,engine,
    if(engine=="PowerTOST")"exact parallel pooled-t TOST power (Owen Q)" else "native rpact fixed t-approximation with realized allocation",
    c("independent normal groups; common variance; fixed final analysis",
      "margins prespecified and clinically justified; no binary/sequential/adaptive extrapolation",
      "integer sizes checked at realized allocation; requested ratio need not be represented exactly",
      if(s$hypothesis=="equivalence")"Intersection-union TOST: each component alpha; equivalence is not inferred from nonsignificance" else
        "one-sided alpha except explicitly two-sided superiority"))
}
#' Simulate normal margin tests at the alternative and appropriate null boundaries
#' @inheritParams means_design
#' @param nsim Replications per scenario.
#' @param seed Deterministic seed.
#' @return An otd_result with exact binomial Monte Carlo intervals for each case.
#' @export
simulate_means_design <- function(hypothesis="noninferiority",effect=0,sd=1,alpha=.025,
                                  power=.8,alternative="greater",margin=.3,lower=-.3,upper=.3,
                                  n_control=100,n_treatment=100,nsim=1000,seed=2026) {
  s<-means_contract(hypothesis,effect,sd,alpha,power,alternative,margin,lower,upper)
  integer_count(n_control,"n_control",2);integer_count(n_treatment,"n_treatment",2)
  integer_count(nsim,"nsim",2);integer_count(seed,"seed",0)
  if(!s$effect_in_alternative)fail("The named alternative effect must lie strictly in the alternative region; null boundaries are evaluated separately")
  cases<-if(s$hypothesis=="equivalence")c(`lower boundary null`=lower,`upper boundary null`=upper,alternative=effect) else
    c(`boundary null`=s$thetaH0,alternative=effect)
  rows<-withr::with_seed(seed,lapply(seq_along(cases),function(i){
    rejected<-replicate(nsim,{
      c<-stats::rnorm(n_control,0,sd);t<-stats::rnorm(n_treatment,cases[i],sd)
      if(s$hypothesis=="equivalence"){
        p1<-stats::t.test(t,c,mu=lower,var.equal=TRUE,alternative="greater")$p.value
        p2<-stats::t.test(t,c,mu=upper,var.equal=TRUE,alternative="less")$p.value
        p1<=alpha&&p2<=alpha
      } else stats::t.test(t,c,mu=s$thetaH0,var.equal=TRUE,alternative=alternative)$p.value<=alpha
    })
    ci<-mc_binomial(sum(rejected),nsim)
    data.frame(scenario=names(cases)[i],effect=unname(cases[i]),nsim=nsim,rejections=sum(rejected),
      estimate=ci["estimate"],mcse=ci["mcse"],lower=ci["lower"],upper=ci["upper"],row.names=NULL)
  }))
  s$n_control<-n_control;s$n_treatment<-n_treatment
  result("normal margin-test Monte Carlo",list(summary=do.call(rbind,rows)),s,"stats",
    "pooled two-sample t tests; equivalence requires both one-sided rejections",
    c("normal independent observations; common variance; fixed arm sizes",
      "NI null is the loss margin, not equality zero; equivalence null is the union outside both bounds",
      "boundary simulations are diagnostics, not proof of uniform type I error control"),seed)
}
