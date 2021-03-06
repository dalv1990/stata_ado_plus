{smcl}
{* *! version 1.5.0 7 September 2016}{...}
{boottest:help boottest}
{hline}{...}

{title:Title}

{pstd}
Test linear hypotheses using wild or score bootstrap or Rao or Wald test for OLS, 2SLS, LIML, Fuller, k-class, linear GMM, or general ML estimation with classical, heteroskedasticity-robust, 
or (multi-way-) clustered standard errors{p_end}

{title:Syntax}

{phang}
{cmd:boottest} [{it:indeplist}] [, {it:options}]

{phang}
where {it:indeplist} is one of

{phang2}
{it:jointlist}

{phang2}
{cmd:[}{it:jointlist}{cmd:]} [{cmd:[}{it:jointlist}{cmd:]} ...]

{phang}
{it:jointlist} is one of

{phang2}
{it:test}

{phang2}
{cmd:(}{it:test}{cmd:)} [{cmd:(}{it:test}{cmd:)} ...]

{phang}
and {it:test} is

{phang2}
{it:{help exp}} {cmd:=} {it:{help exp}} | {it:{help test##coeflist:coeflist}}

{pstd}
In words, {it:indeplist} is a list of hypotheses to be tested separately; if there is more than one, then each must be enclosed in brackets. Each independent hypothesis
in turn consists of one or more jointly tested constraint expressions, linear in parameters; if there is more than one, then each must be enclosed in parantheses. Finally, each 
individual constraint expression must conform to the syntax for {help constraint:constraint define}.

{synoptset 38 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{cmdab:weight:type(}{it:rademacher} {cmd:|}}specify weight type for bootstrapping; default is {it:rademacher}{p_end}
{synopt:{space 12} {it:mammen} {cmd:|} {it:webb} {cmd:|} {it:normal}{cmd:)}}{p_end}
{synopt:{opt boott:type(wild | score)}}specify bootstrap type; after ML and GMM estimation, {it:score} is default and only option{p_end}
{synopt:{opt r:eps(#)}}specifies number of replications for bootstrap-based tests; deafult is 1000; set to 0 for Rao or Wald test{p_end}
{synopt:{opt nonul:l}}suppress imposition of null before bootstrapping{p_end}
{synopt:{opt madj:ust(bonferroni | sidak)}}specify adjustment for multiple hypothesis tests{p_end}
{synopt:{opt l:evel(#)}}override default confidence level used for confidence set{p_end}
{synopt:{opt svm:at}}request the bootstrapped quasi-t/z distribution be saved in return value {cmd:r(dist)}{p_end}
{synopt:{opt sm:all}}request finite-sample corrections, overriding estimation setting {p_end}
{synopt:{opt r:obust}}request tests robust to heteroskedasticity only, overriding estimation setting{p_end}
{synopt:{opt cl:uster(varlist)}}request tests robust to (multi-way) clustering, overriding estimation setting{p_end}
{synopt:{opt bootcl:uster(varname)}}sets cluster variable to boostrap on; allowed and required only with multi-way clustering{p_end}
{synopt:{opt ar}}request Anderson-Rubin test{p_end}
{synopt:{opt seed(#)}}initialize random number seed to {it:#}{p_end}
{synopt:{opt qui:etly}}suppress display of null-imposed estimate; relevant after ML estimation{p_end}
{synopt:{cmd:h0}({it:{help estimation options##constraints():constraints}}{cmd:)}}({it:deprecated}) specify linear hypotheses expressed as constraints; default is "1" if {it:indeplist} empty{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
In addition, these options are relevant when testing a single hypothesis after OLS/2SLS/GMM/LIML, when by default a confidence set is derived and plotted:

{synoptset 38 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt gridmin(#)}}set lower end of confidence set search range{p_end}
{synopt:{opt gridmax(#)}}set upper end of search range{p_end}
{synopt:{opt gridpoints(#)}}set number of equally space points to compute rejection confidence{p_end}
{synopt:{opt graphopt(string)}}formatting options to pass to graph command{p_end}
{synopt:{opt noci}}prevent derivation of confidence set from inverted bootstrap test{p_end}
{synopt:{cmd:graphname(}{it:name}[{cmd:, replace}]{cmd:)}}name graph; for multiple independent hypotheses, uses {it:name} as stub{p_end}
{synopt:{opt nogr:aph}}allow derivation of confidence set but don't graph confidence function{p_end}
{synopt:{opt p:type(equaltail | symmetric)}}set whether p value is derived from {it:t}/{it:z} statistic ({it:equaltail}) or its square ({it:symmetric}); latter is default{p_end}
{synoptline}
{p2colreset}{...}

{phang}
{cmd:waldtest} [, {it:options}]

{phang}
{cmd:scoretest} [, {it:options}]

{phang}
{cmd:artest} [, {it:options}]

{pstd}
{cmd:waldtest}, {cmd:artest}, and {cmd:scoretest} accept all options listed above except {cmdab:weight:type()}, {cmdab:boot:type()}, {opt r:eps(#)}, {opt svm:at}, and {opt seed(#)}.

{marker description}{...}
{title:Description}

{pstd}
{cmd:boottest} is a post-estimation command that tests linear hypotheses about parameters. It offers several bootstraps--algorithms for generating simulated data sets--and
several tests to run on the data sets. The bootstraps are:

{p 4 6 0}
* The wild bootstrap (Wu 1986), available after (constrained) OLS estimation.

{p 4 6 0}
* The wild restricted efficient bootstrap (WRE; Davidson and MacKinnon 2010), which extends the wild bootstrap to instrumental variables estimators including
2SLS, LIML, Fuller LIML, and k-class estimation.

{pstd}
* The "score bootstrap" developed by Kline and Santos (2012) as an adaptation of the wild bootstrap to the general extremum estimator, including 2SLS, LIML, ML, and GMM. In 
estimators such as probit and logit, residuals are not well-defined, which prevents application of the wild bootstrap. As its name suggests, the score bootstrap 
works with a generalized analog of residuals, scores. Also, the score bootstrap does not require re-estimation on each replication, which would be 
computationally prohibitive with many ML-based estimators.

{pstd}
{cmd:boottest} uses the first two to bootstrap the empirical distribution of a Wald test of the null hypothesis. For instrumental variables models, the 
WRE may also be used to bootstrap the Anderson-Rubin (1949) test, which is itself a Wald test based on an auxilliary OLS regression 
(Baum, Schaffer, and Stillman 2007, p. 491). The score bootstrap, as its name suggests, is best seen as bootstrapping the Rao score/LM test.

{p 4 6 0}
If one instructs {cmd:boottest} to generate zero bootstrap replications ({cmd:reps(0)}), then, depending on the bootstrap chosen and whether {cmd:ar} is specified, it will default to:

{p 4 6 0}
* The classical Wald (1943) test.

{p 4 6 0}
* The classical Anderson-Rubin (1949) test.

{p 4 6 0}
* The classical Rao (1948) score/Lagrange multiplier test.

{pstd}
{cmd:waldtest}, {cmd:artest}, and {cmd:scoretest} are wrappers for {cmd:boottest} to facilitate access to these classical tests. The Wald test should be the same as that 
provided by {help test}. {cmd:waldtest} adds value by allowing you to incorporate finite-sample corrections and (multi-way) clustering 
after estimation commands that do not support those adjustments.

{pstd}
In general, the tests are available after OLS, constrained OLS, 2SLS, LIML, and GMM estimation performed with {help regress}, {help cnsreg}, {help ivreg}, {help ivregress}, or 
{stata ssc describe cmp:ivreg2}. The
program works with Fuller LIML and k-class estimates done with {stata ssc describe cmp:ivreg2} (WRE bootstrap only). And it works after most Stata 
ML-based estimation commands, including {help probit}, {help glm}, {stata ssc describe cmp:cmp}, and, in Stata 14.0 or later, 
{help sem} and {help gsem} (score bootstrap only). A 
notable ML exception is {help tobit}. (To work with {cmd:boottest}, an iterative optimization command must accept
the {opt const:raints()}, {opt iter:ate()}, {opt from()}, and {opt sc:ore} options.)

{pstd}
{cmd:boottest} is designed in partial analogy with {help test}. Like {help test}, {cmd:boottest} can jointly or separately test multiple hypotheses expressed as linear constraints on 
parameters. {cmd:boottest} deviates in syntax from {help test} in the specification of the null hypothesis. In fact, it offers two syntaxes for specifying hypotheses, both
different from the syntax of {help test}. In the first syntax, now deprecated, one first expresses the null in 
one or more {help estimation options##constraints():constraints}, which are then listed by number in {cmd:boottest}'s {opt h0()} option. All constraints are tested 
jointly. In the second, modern syntax one places the constraint expressions directly in the {cmd:boottest} command line before the comma. Each expression must conform to the syntax
of {help constraint:constraint define}, meaning a list of parameters (all of which are implicitly hypothesized to equal zero) or an equation in the form 
{it:{help exp}} {cmd:=} {it:{help exp}}. To jointly test several such expressions, list them all, placing each in parentheses. To independently test several such hypotheses, or joint groups
of hypotheses, list them all, placing each in brackets. Omitting both syntaxes implies {cmd:h0(1)}, unless {opt ar} is specified, in which case {cmd:boottest}
tests the hypothesis that all coefficients on instrumented variables are zero.

{pstd}
When testing multiple independent hypotheses, the {opt madj:ust()} option requests the Bonferroni or Sidak correction for multiple hypothesis tests.

{pstd}
{cmd:boottest} supports multi-way clustering (Cameron, Gelbach, and Miller 2006), in which case the user must choose which clustering variable to {it:bootstrap}
on. When multiway clustering is combined with {cmd:small}, 
the finite-sample correction multiplier is a component-specific (G/(G-1)*(N-1)/(N-k), as described in Cameron, Gelbach, and Miller (2006, pp. 8-9) and simulated therein. In
contrast, {stata ssc describe ivreg2:ivreg2} uses one multiplier for all components, based on the clustering variable with the lowest G. Thus after estimation with
{cmd:ivreg2} with multi-way clustering, {cmd:waldtest} produces slightly different results from {cmd:test}, which relies purely on ivreg2's computed covariance matrix.

{pstd}
Because {cmd:boottest} has its own {opt r:obust}, {opt cl:uster()}, and {opt sm:all} options, you can override the choices made in running the 
original estimate. In particular, you can perform inference with multi-way clustered errors after all the estimation commands that are compatible with
{cmd:boottest}, even though few can themselves multi-way cluster. They include many ML-based estimators, after which {cmd:boottest} uses the score bootstrap.

{pstd}
By default, the null is imposed before bootstrapping (Davidson and MacKinnon 1999; Cameron, Gelbach, and Miller 2008; Cameron and Miller 2015). The {opt nonul:l} option overrides this behavior. After 2SLS
estimation, the null is imposed only on the second-stage equation. Thus, after {cmd:ivregress 2sls Y X1 (X2 = Z)}, imposing the null of X1 = 0 results in 
{cmd:ivregress 2sls Y (X2 = X1 Z)}, not {cmd:ivregress 2sls Y (X2 = Z)}.

{pstd}
After GMM estimation, {cmd:boottest} bootstraps only with the final weight matrix. It does not replicate the process for computing that matrix.

{pstd}{cmd:boottest}'s bootstrap-based tests are generally fast, though the WRE runs substantially slower than the others. The code is optimized for clustered standard errors and 
runs most efficiently in Stata version 13 or later.

{pstd}
The wild and score bootstraps multiply residuals or scores by weights drawn randomly for each replication. {cmd:boottest} offers four weight distributions:

{p 4 6 0}
* The default Rademacher 
weights are +/-1 with equal probability. In the wild bootstrap, that means that in each replication, and in each cluster (or each observation in non-clustered
estimation), the synthetic dependent variable is XB +/- E, where XB and E are the fitted values and residuals from the base regression. Since
Rademacher weights have mean 0 and variance 1, multiplying E by them preserves the variance of the base regression's residuals.

{p 4 6 0}
* Mammen (1993)
weights improve theoretically on Rademacher weights by having a third moment of 1, thus preserving skewness. They are--letting phi=(1+sqrt(5))/2, the 
golden mean--1-phi with probability phi/sqrt(5) and phi otherwise.

{p 4 6 0}
* A disadvantage of the Rademacher and Mammen distributions is that 
they have only two mass points. So, for instance, an estimate with 5 clusters can only have 2^5 = 32 possible combinations of weight draws. Performing more than 32 replications in this 
case, as in some Cameron, Gelbach, and Miller (2008) examples,
creates spurious precision, since some replications will be duplicates. Webb (2014) weights greatly reduce this problem with a uniform 6-point distribution that closely matches Rademacher
in the first four moments. The 6 values are +/-sqrt(3/2), +/-1, +/-sqrt(1/2).

{p 4 6 0}
* {cmd:boottest}'s fourth weight type is the normal distribution.

{pstd}
The {opt r:eps(#)} option sets the number of bootstrap replications. 1000 is the default but values of 10000 and higher are often feasible. Since bootstrapping
involves drawing pseudorandom numbers, the exact results depend on the starting value of the random number generator and the version of the generator. See 
{help set_seed:set seed}.

{pstd}
When testing a single-constraint hypothesis after OLS, 2SLS, or LIML, {cmd:boottest} by default derives and plots a confidence curve and a confidence set for the 
left-hand-side of the hypothesis. (This adds greatly to run time and can be prevented with the {opt noci} option.) For example,
if the hypothesis is "X + Y = 1", meaning that the coefficients on X and Y sum to 1, then {cmd:boottest} will estimate the set of all potential values for this sum that cannot be rejected
at, say, p = 0.05. In some cases, this set will consist of multiple disjoint pieces. The standard {opt l:evel(#)} option controls the coverage of the confidence set. By default, p value 
computation is symmetric; {opt ptype(equaltail)} overrides. For instance, if the level is 95, then the symmetric p value is less than 0.05 if the square (or 
absolute value) of the test statistic is in the top 5 centiles of the corresponding bootstrapped distribution. The equal-tail p value is less than 0.05 if the test statistic is in the top or
bottom 2.5 centiles of the (un-squared) distribution. Davidson and MacKinnon (2010) find that in estimation with weak instruments, when the estimator is often asymmetrically 
distributed, equal-tail p values are more reliable.

{pstd}
To find the confidence set, {cmd:boottest} starts by choosing lower and upper bounds for the search range, which can be overriden by the {opt gridmin(#)} and {opt gridmax(#)} 
options. Then it tests potential values at equally spaced intervals within this range--by default 25, but this too is subject to override, via
{opt gridpoints(#)}. If it discovers that, for example X + Y = 2 is rejected at 0.04 and X + Y = 3 is rejected at 0.06, it then seeks to zero in on the value in between
that is rejected at 0.05, in order to bound the confidence set. The confidence curve is then plotted, at all the grid points as well as the detected crossover points and the
original point estimate. The graph may look coarse with only 25 grid points, but the confidence set bounds will nevertheless be computed precisely.  Specifying 
{opt level(100)} suppresses this entire search process while still requesting a plot of the confidence function.


{marker options}{...}
{title:Options}

{phang}{opt weight:type(rademacher | mammen | webb | normal)} specifies the type of random weights to apply to the residuals or scores from the base regression, when
bootstrapping. The default is {it:rademacher}. However if the number of replications exceeds 2^(# of clusters)--that is, the number of possible
Rademacher draws--{cmd:boottest} will take each possible draw once. It will not do that with Mammen weights even though the same issue arises. In all such cases,
Webb weights are probably better.

{phang}{opt r:eps(#)} sets the number of bootstrap replications. The default is 1000. Especially when clusters are few, increasing this number costs little in run 
time. {opt r:eps(0)} requests a Wald test or--if {opt boottype(score)} is also specified and {opt nonul:l} is not--a Rao test. The wrappers {cmd:waldtest}
and {cmd:scoretest} facilitate this usage.

{phang}{opt nonul:l} suppresses the imposition of the null before bootstrapping. This is rarely a good idea.

{phang}{opt madj:ust(bonferroni | sidak)} requests the Bonferroni or Sidak adjustment for multiple hypothesis tests. The Bonferroni correction is
min(1, n*p) where p is the unadjusted probability and n is the number of hypotheses. The Sidak correction is 1 - (1 - p) ^ n.

{phang}{opt noci} prevents computation of a confidence interval for the constant term of a single constraint. For example, if the 
confidence level is 95% and the null is expressed in a constraint as X + Y = 1, 
{cmd:boottest} will iteratively search for the high and low values U and L such that the bootstrapped two-tailed p values of the 
hypotheses X + Y = U and X + Y = L are 0.05. See Cameron and Miller (2015, section VIC.2). This option is only relevant when testing a 
one-costraint hypothesis after OLS/2SLS/GMM/LIML, for only then is the confidence interval derived anyway. 

{phang}{opt l:evel(#)} specifies the confidence level, in percent, for the confidence interval; see {help level:help level}. The
default is controlled by {help level:set level} and is usually 95. Setting it to 100 suppresses computation and plotting of the confidence 
set while still allowing plotting of the confidence curve.

{phang}{opt gridmin(#)}, {opt gridmax(#)}, {opt gridpoints(#)} over-ride the default lower and upper bounds and the resolution of the initial grid search
that begins the process of determining bounds for confidence sets, as described above. By default, {cmd:boottest} estimates the lower and upper bounds by working
with the bootstrapped distribution, and uses 25 grid points.

{phang}{opt graphopt(string)} allows the user to pass formatting options to the {help graph} command, in order to control the appearance of the confidence plot.

{phang}{cmd:graphname(}{it:name}[{cmd:, replace}]{cmd:)} names any resulting graphs. If testing multiple independent hypotheses, {it:name} will be used as a stub,
producing {it:name}_1, {it:name}_2, etc.

{phang}{opt nogr:aph} prevents graphing of the confidence function but not the derivation of confidence sets.

{phang}{opt p:type(equaltail | symmetric)} sets whether the p value is derived from {it:t}/{it:z} statistic ({it:equaltail}) or its square ({it:symmetric}). The
latter is the default. For example, if the confidence level is 95, then the symmetric p value is less than 0.05 if the square (or 
absolute value) of the test statistic is in the top 5 centiles of the corresponding bootstrapped distribution. The equal-tail p value is less than 0.05 if the 
test statistic is in the top or bottom 2.5 centiles.

{phang}{opt svm:at}} request that the bootstrapped quasi-t/z distribution be saved in return value {cmd:r(dist)}. This can be diagnostically useful,
since it allows scrutiny of the simulated distribution that is inferred from. An example is below.

{phang}{opt sm:all} requests finite-sample corrections even after estimates that did not make them, which includes essentially all ML-based Stata 
commands. Its impact on bootstrap-based tests is merely cosmetic because it scales the test statistic and all the replicated test statistics by the same
value, such as N/(N-1), so that the place of the test statistic in the simulated distribution does not change. It substantively affects Rao and Wald tests.

{phang}{opt r:obust} and {opt cl:uster(varlist)} have the traditional meanings, but serve an nontraditional function, which is to override the settings
used in the estimation.

{phang}{opt bootcl:uster(varname)} specifies which clustering variable to boostrap on. It is allowed and required only with multi-way clustering. Normally
it should be the variable with the fewest clusters.

{phang}{opt ar} requests the Anderson-Rubin test. It applies only to instrumental variables estimation. If the null is specified explicitly, it must fix
all parameters on instrumented variables, and no others.

{phang}{opt seed(#)} sets the initial state of the random number generator. See {help set seed}.

{phang}{opt qui:etly}, with Maximum Likelihood-based estimation, suppresses display of initial re-estimation with null imposed.

{phang}
{cmd:h0}({it:{help estimation options##constraints():constraints}}{cmd:)} (deprecated) specifies the numbers of the stored constraints that jointly express
the null. The argument is a {help numlist}, so it can look like "1 4" or "2/5 6 7". The default is "1". 


{title:Stored results}

{pstd}
{cmd:boottest} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(reps)}}number of bootstrap replications{p_end}
{synopt:{cmd:r(F)}}test statistic if making small-sample correction{p_end}
{synopt:{cmd:r(chi2)}}test statistic if not making small-sample correction{p_end}
{synopt:{cmd:r(t)}}appropriately signed square root of {cmd:r(F)}, if testing one null constraint{p_end}
{synopt:{cmd:r(z)}}appropriately signed square root of {cmd:r(chi2)}, if testing one null constraint{p_end}
{synopt:{cmd:r(df)}}test degrees of freedom{p_end}
{synopt:{cmd:r(df_r)}}residual degrees of freedom if making small-sample correction{p_end}
{synopt:{cmd:r(null)}}indicates whether null imposed{p_end}
{synopt:{cmd:r(level)}}statistical signficance level for confidence interval, if any{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(seed)}}value of {opt seed(#)} option, if any{p_end}
{synopt:{cmd:r(bootttype)}}bootstrapping type{p_end}
{synopt:{cmd:r(weighttype)}}bootstrapping weight type{p_end}
{synopt:{cmd:r(robust)}}indicates robust/clustered test{p_end}
{synopt:{cmd:r(clustvars)}}clustering variables for test, if any{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(CI)}}bounds of confidence sets, if any{p_end}
{synopt:{cmd:r(plot)}}data for confidence plot, if any{p_end}
{synopt:{cmd:r(dist)}}t/z distribution, if requested with {opt svm:at}{p_end}

{title:Donate?}

{pstd}
Has {cmd:boottest} improved your career or marriage? Consider
giving back through a {browse "http://j.mp/1iptvDY":donation} to support the work of its author, {browse "http://davidroodman.com":David Roodman}.


{title:Examples}

{phang}. {stata "use http://web.archive.org/web/20150802214527/http://faculty.econ.ucdavis.edu/~dlmiller/statafiles/collapsed"}{p_end}

{phang}. {stata regress hasinsurance selfemployed post post_self, cluster(year)}{p_end}
{phang}. {stata boottest post_self=.04, graphopt(xtitle("Coefficient on tenure"))} // wild bootstrap, Rademacher weights, null imposed, 1000 replications{p_end}
{phang}. {stata boottest post_self=.04, weight(webb) noci}{space 24} // wild bootstrap, Webb weights, null imposed, 1000 replications, no graph or CI{p_end}
{phang}. {stata scoretest post_self=.04}{space 42} // Rao score/Lagrange multipler test of same{p_end}

{phang}. {stata boottest (post_self) (post), reps(100000) weight(webb)} // wild bootstrap test of joint null, Webb weights, null imposed, 100,000 replications{p_end}
{phang}. {stata boottest{space 2}post_self{space 3}post , reps(100000) weight(webb)} // same, because multiple coefficients can be listed in single constraint{p_end}
{phang}. {stata boottest (post_self=.04) (post)} // joint test{p_end}
{phang}. {stata boottest [post_self=.04] [post]} // separate tests, no correction for multiple hypotheses{p_end}
{phang}. {stata boottest [(post) (post_self=.04)] [(post) (post_self=.08)], madj(sidak)} // separate tests, Sidak correction for multiple hypotheses{p_end}

{phang}. {stata webuse nlsw88}{p_end}

{phang}. {stata regress wage tenure ttl_exp collgrad, cluster(industry)}{p_end}
{phang}. {stata boottest tenure, svmat}{space 8} // wild bootstrap test of joint null, Rademacher weights, null imposed, saving simulated distribution{p_end}
{phang}. {stata mat dist = r(dist) }{p_end}
{phang}. {stata svmat dist}{p_end}
{phang}. {stata histogram dist1, xline(`r(t)')} // histogram of bootstrapped t statistics{p_end}

{phang}. {stata constraint 1 ttl_exp = .2} {p_end}
{phang}. {stata cnsreg wage tenure ttl_exp collgrad, constr(1) cluster(industry)}{p_end}
{phang}. {stata boottest tenure} // wild bootstrap test of tenure=0, conditional on ttl_exp=2, Rademacher weights, null imposed, 1000 replications{p_end}

{phang}. {stata ivregress 2sls wage ttl_exp collgrad (tenure = union), cluster(industry)}{p_end}
{phang}. {stata boottest tenure, ptype(equaltail) seed(987654321)} // Wald test, wild restricted efficient bootstrap, Rademacher weights, null imposed, 1000 reps{p_end}
{phang}. {stata boottest, ar} // same bootstrap, but Anderson-Rubin test (much faster){p_end}
{phang}. {stata scoretest tenure} // Rao/LM test of same{p_end}
{phang}. {stata waldtest tenure} // Wald test of same{p_end}

{phang}. {stata ivregress liml wage collgrad (tenure = collgrad ttl_exp), cluster(industry)}{p_end}
{phang}. {stata boottest tenure, noci} // WRE bootstrap, Rademacher weights, 1000 replications{p_end}
{phang}. {stata cmp (wage = tenure collgrad) (tenure = collgrad ttl_exp), ind(1 1) qui nolr cluster(industry)}{p_end}
{phang}. {stata boottest tenure} // reasonable match on test statistic and p value{p_end}

{phang}. {stata ivreg2 wage collgrad (tenure = collgrad ttl_exp), cluster(industry) fuller(1)}{p_end}
{phang}. {stata boottest tenure, nograph} // Wald test, WRE bootstrap, Rademacher weights, 1000 replications{p_end}
{phang}. {stata boottest tenure, nograph ar} // same, but Anderson-Rubin (much faster){p_end}

{phang}. {stata regress wage ttl_exp collgrad tenure, cluster(industry)}{p_end}
{phang}. {stata boottest tenure, cluster(industry age) bootcluster(industry) gridmax(1)} // multi-way-clustered test after estimation command not offering such{p_end}

{phang}. {stata probit c_city tenure wage ttl_exp collgrad, cluster(industry)}{p_end}
{phang}. {stata boottest tenure}{space 25} // score bootstrap, Rademacher weights, null imposed, 1000 replications{p_end}
{phang}. {stata boottest tenure, cluster(industry age) bootcluster(industry) small} // multi-way-clustered, finite-sample-corrected test with score bootstrap{p_end}

{phang}. {stata gsem (c_city <- tenure wage ttl_exp collgrad), vce(cluster industry) probit} // same probit estimate as previous{p_end}
{phang}. {stata boottest tenure}{space 67} // requires Stata 14.0 or later {p_end}
{phang}. {stata boottest tenure, cluster(industry age) bootcluster(industry) small}{space 16} // requires Stata 14.0 or later{p_end}

{title:References}

{p 4 8 2}Anderson, T.W., and H. Rubin. 1949. Estimation of the parameters of a single equation
in a complete system of stochastic equations. {it:Annals of Mathematical Statistics} 20: 46–63.{p_end}
{p 4 8 2}Baum, C.F., M.E. Schaffer, and S. Stillman. 2007. Enhanced routines for instrumental variables/GMM estimation and 
testing. {it:Stata Journal} 7(4): 465-506.{p_end}
{p 4 8 2}Cameron, A.S., J.B. Gelbach, and D.L. Miller. 2006. Robust inference with multi-way clustering. NBER technical working paper 327.{p_end}
{p 4 8 2}Cameron, A.C., J.B. Gelbach, and D.L. Miller. 2008. Bootstrap-based improvements for inference with clustered errors.
{it:The Review of Economics and Statistics} 90(3): 414-27.{p_end}
{p 4 8 2}Cameron, A.C., and D.L. Miller. 2015. A practitioner’s gtuide to cluster-robust
inference. {it:Journal of Human Resources} 50(2): 317-72.{p_end}
{p 4 8 2}Davidson, R., and J.G. MacKinnon. 1999. The size distortion of bootstrap tests. {it:Econometric Theory} 15: 361-76.{p_end}
{p 4 8 2}Davidson, R., and J.G. MacKinnon. 2010. Wild bootstrap tests for IV regression. {it:Journal of Business & Economic Statistics} 28(1): 128-44.{p_end}
{p 4 8 2}Kline, P., and Santos, A. 2012. A score based approach to wild bootstrap 
inference. {it:Journal of Econometric Methods} 1(1): 23–41.{p_end}
{p 4 8 2}Mammen, E. 1993. Bootstrap and wild bootstrap for high dimensional linear models. {it:Annals of Statistics} 21: 255-85.{p_end}
{p 4 8 2}Rao, C.R. 1948. Large sample tests of statistical hypotheses concerning several parameters with applications to problems of
estimation. {it:Proc. Cambridge Philos. Soc.} 44: 50-57.{p_end}
{p 4 8 2}Wald, A. 1943. Tests of statistical hypotheses concerning several parameters when the number of observations is
large. {it:Transactions of the American Mathematical Society} 54: 426-82.{p_end}
{p 4 8 2}Webb, M.D. 2014. Reworking wild bootstrap based inference for clustered errors. Queen’s Economics Department Working Paper No. 1315.{p_end}
{p 4 8 2}Wu, C.F.J. 1986. Jackknife, bootstrap and other resampling methods in regression analysis (with discussions). {it:Annals of Statistics}
14: 1261–1350.{p_end}

{title:Author}

{p 4}David Roodman{p_end}
{p 4}david@davidroodman.com{p_end}
