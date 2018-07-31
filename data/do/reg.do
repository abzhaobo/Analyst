*综合情绪回归
import delimited D:\GTA_Stata\QX_CICSI.txt, case(preserve) encoding(UTF-8) clear
gen Month=date(SgnMonth,"YM")
format Month %tdCCYY-NN
gen month=monthly(SgnMonth,"YM")
tsset month
replace TURN=f.TURN
replace NIA =f.NIA
gen lDCEF=l.DCEF
gen lIPOR=l.IPOR
drop if month<588 | month >695
pca lDCEF TURN lIPOR NIA
gen SENT1=-0.1071*lDCEF+0.6684*TURN+0.2747*lIPOR+0.6829*NIA
gen SENT2= 0.7874*lDCEF-0.157*TURN+0.595 *lIPOR+0.0377*NIA
gen SENT = 0.4595*SENT1+0.2699*SENT2

twoway (line SENT Month, sort) (lfit SENT Month, lpattern(dash)), name(SENTINX, replace) legend(off) ///
        ylabel(, labsize(vsmall) nogrid) xlabel(#19, labsize(vsmall) angle(ninety)) xsize(6) ysize(4)

merge 1:m SgnMonth using "C:\Users\se7en\Desktop\Thesis2\do&data\report.dta", ///
 keepus(SgnMonth RpNum) keep(match) nogen
merge m:1 SgnMonth using mktrtm.dta, keep(match) nogen
replace mktrtm=mktrtm*100
duplicates drop

gen year=substr(SgnMonth,1,4)
bys year: egen Rptotal=sum(RpNum)
gen Rpratio=RpNum/Rptotal

twoway (scatter RpNum Month) (lfit RpNum Month, lpattern(dash)), name(a, replace) legend(off) ///
        ylabel(, labsize(vsmall) nogrid) xtitle((a)) xtitle(, size(vsmall)) xlabel(#19, labsize(vsmall) angle(ninety)) xsize(4) ysize(4)
twoway (scatter Rpratio Month) (lfit Rpratio Month, lpattern(dash)), name(b, replace) legend(off) ///
        ylabel(, labsize(vsmall) nogrid) xtitle((b)) xtitle(, size(vsmall)) xlabel(#19, labsize(vsmall) angle(ninety)) xsize(4) ysize(4)

label var Rpratio  "Report Number"
label var SENT  "Sentiment Index"
label var mktrtm "Market Return" 
reg Rpratio SENT
outreg using "C:\Users\se7en\Desktop\Thesis2\SENT_M.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(F\r2) summtitle("F Statistics"\"R2") ctitles("Report Number","Model(1)") replace
reg Rpratio      mktrtm
outreg using "C:\Users\se7en\Desktop\Thesis2\SENT_M.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(F\r2) summtitle("F Statistics"\"R2") ctitles("Report Number","Model(2)") merge replace
reg Rpratio SENT mktrtm
outreg using "C:\Users\se7en\Desktop\Thesis2\SENT_M.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(F\r2) summtitle("F Statistics"\"R2") ctitles("Report Number","Model(3)") merge replace



*个股情绪回归
use turnover.dta, clear
merge 1:1 Stkcd SgnMonth using "C:\Users\se7en\Desktop\Thesis2\do&data\publish.dta", ///
 keepus(analyst CurRating LastRating PubNum Indcd1) keep(master match) nogen //6份报告匹配不到
gen release=1 if PubNum>0
replace release=0 if PubNum==.
gen year=substr(SgnMonth,1,4)
destring year,replace
merge m:1 Stkcd year using attention.dta, keepus(AnaAttention ReportAttention) keep(match master) nogen
replace year=year-1
merge m:1 Stkcd year using firmct.dta, keepus(ROE ROA tasset Mvt) keep(match) nogen //上年市值

bys Indcd1: egen medsize1=median(tasset)
gen Firmsize1=1 if tasset>medsize1
replace Firmsize1=0 if Firmsize1==.
bys Indcd1: egen medsize2=median(Mvt)
gen     Firmsize2=1 if Mvt>medsize2
replace Firmsize2=0 if Firmsize2==.

winsor ROE, g(ROE1) p(0.01)
winsor ROA, g(ROA1) p(0.01)
winsor tasset, g(tasset1) p(0.01)
replace tasset1=tasset1/1000000000 //十亿元
winsor Mvt, g(Mvt1) p(0.01)
replace Mvt1=Mvt1/1000000 //百万元
winsor AbTURN, g(AbTURN1) p(0.01)

bys release: summarize AbTURN1 AnaAttention ReportAttention ROE1 ROA1 tasset1 Mvt1, format separator(0)

label var AbTURN1 "Abnormal Turnover"
label var ROA1 "ROA"
label var ROE1 "ROE"
label var AnaAttention "Analyst Attention"
label var ReportAttention "Report Attention"
label var Firmsize1 "Total Asset"
label var Firmsize2 "Market Value"

logit release AbTURN1 AnaAttention    ROA1 Firmsize1, robust
outreg using "C:\Users\se7en\Desktop\Thesis2\SENT_I.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(chi2\p) summtitle("Wald Chi2"\"Prob.") ctitles("release","Model(4)") replace
logit release         AnaAttention    ROA1 Firmsize1, robust
outreg using "C:\Users\se7en\Desktop\Thesis2\SENT_I.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(chi2\p) summtitle("Wald Chi2"\"Prob.") ctitles("release","Model(5)") merge replace
logit release AbTURN1 ReportAttention ROE1 Firmsize2, robust
outreg using "C:\Users\se7en\Desktop\Thesis2\SENT_I.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(chi2\p) summtitle("Wald Chi2"\"Prob.") ctitles("release","Model(6)") merge replace
logit release         ReportAttention ROE1 Firmsize2, robust
outreg using "C:\Users\se7en\Desktop\Thesis2\SENT_I.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(chi2\p) summtitle("Wald Chi2"\"Prob.") ctitles("release","Model(7)") merge replace


*同步性变化
use "C:\Users\se7en\Desktop\Thesis2\do&data\report.dta", clear
merge m:1 Stkcd SgnMonth using turnover.dta, keepus(Dturn AbTURN) keep(match) nogen
gen id=_n
gen date=date(InfoPubDt,"YMD")
format date %tdCCYY-NN-DD
expand 120
bys id: gen dif=_n-90
replace date=date+dif
merge m:1 Stkcd date using "C:\Users\se7en\Desktop\Thesis2\do&data\return.dta", keep(match) nogen
sort id date
bys id: gen diff=_n
bys id: gen target=diff if dif>-1
bys id: egen td=min(target)
replace dif=diff-td
drop if dif==. | dif<-30 | dif>11
replace diff=dif+10 //10对应day(0)
codebook id //看删了几个报告样本
save "C:\Users\se7en\Desktop\Thesis2\do&data\description.dta", replace

bys id (diff): gen t=_n
rangestat (reg) stkrt mktrt, interval(t -20 -1) by(id) 
drop if reg_nobs<20 | reg_nobs==.
forvalues i=0(1)21{
   qui bys id: gen r2_`i'=reg_r2 if diff==`i'
   }
xtset id t
forvalues i=0(1)21{
   qui bys id: replace r2_`i'=sum(r2_`i')
   }
keep if t==42
drop date-td reg_nobs-se_cons

gen rating=1 if CurRating==3
replace rating=0 if rating==.
gen dr2=r2_12-r2_9
egen meandr2=mean(dr2)
gen info1=1 if dr2<meandr2
replace info1=0 if info1==.
egen meddr2=median(dr2)
gen info2=1 if dr2<meddr2
replace info2=0 if info2==.
gen year=substr(SgnMonth,1,4)
gen Cycle=1 if year=="2009" | year=="2013" | year=="2014" | year=="2015" | year=="2017"
replace Cycle=0 if Cycle==.
xtile SENT = AbTURN, nq(5) //按照异常换手率分五组，5表示情绪最高，1表示最低

save "C:\Users\se7en\Desktop\Thesis2\do&data\sync.dta", replace


*同步性变化画图
use "C:\Users\se7en\Desktop\Thesis2\do&data\sync.dta", clear
collapse r2_0 r2_1 r2_2 r2_3 r2_4 r2_5 r2_6 r2_7 r2_8 r2_9 r2_10 r2_11 r2_12 r2_13 r2_14 r2_15 r2_16 r2_17 r2_18 r2_19 r2_20 r2_21
export excel using "C:\Users\se7en\Desktop\Thesis2\stata result.xlsx", sheet("ALL") sheetmodify firstrow(variables)
//根据投资者情绪
use "C:\Users\se7en\Desktop\Thesis2\do&data\sync.dta", clear
collapse r2_0 r2_1 r2_2 r2_3 r2_4 r2_5 r2_6 r2_7 r2_8 r2_9 r2_10 r2_11 r2_12 r2_13 r2_14 r2_15 r2_16 r2_17 r2_18 r2_19 r2_20 r2_21, by(SENT)
export excel using "C:\Users\se7en\Desktop\Thesis2\stata result.xlsx", sheet("bySENT") sheetmodify firstrow(variables)
//根据评级水平
use "C:\Users\se7en\Desktop\Thesis2\do&data\sync.dta", clear
collapse r2_0 r2_1 r2_2 r2_3 r2_4 r2_5 r2_6 r2_7 r2_8 r2_9 r2_10 r2_11 r2_12 r2_13 r2_14 r2_15 r2_16 r2_17 r2_18 r2_19 r2_20 r2_21, by(CurRating)
export excel using "C:\Users\se7en\Desktop\Thesis2\stata result.xlsx", sheet("byRating") sheetmodify firstrow(variables)
 //根据评级调整方向
use "C:\Users\se7en\Desktop\Thesis2\do&data\sync.dta", clear
collapse r2_0 r2_1 r2_2 r2_3 r2_4 r2_5 r2_6 r2_7 r2_8 r2_9 r2_10 r2_11 r2_12 r2_13 r2_14 r2_15 r2_16 r2_17 r2_18 r2_19 r2_20 r2_21, by(RatChange)
export excel using "C:\Users\se7en\Desktop\Thesis2\stata result.xlsx", sheet("byrevision") sheetmodify firstrow(variables)
//根据之前是否新财富
use "C:\Users\se7en\Desktop\Thesis2\do&data\sync.dta", clear
collapse r2_0 r2_1 r2_2 r2_3 r2_4 r2_5 r2_6 r2_7 r2_8 r2_9 r2_10 r2_11 r2_12 r2_13 r2_14 r2_15 r2_16 r2_17 r2_18 r2_19 r2_20 r2_21, by(laststar)
export excel using "C:\Users\se7en\Desktop\Thesis2\stata result.xlsx", sheet("bystar") sheetmodify firstrow(variables)

/* forvalues i=0(1)11{
qui gen a`i'=1 if diff<`i' & diff>`i'-21
qui statsby r2_`i'=e(r2), by(id LWritDt InfoPubDt Stkcd CurRating RatChange star laststar AbTURN) ///
    saving(r2_`i'.dta, replace): reg stkrt mktrt if a`i'==1
} */


*整体回归
use "C:\Users\se7en\Desktop\Thesis2\do&data\sync.dta", clear
//summarize dsync SENT laststar CurRating Cycle

xi: reg dr2 SENT laststar rating i.RatChange Cycle i.Indcd1, robust
outreg using "C:\Users\se7en\Desktop\Thesis2\dr2.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(F\r2) summtitle("F Statistics"\"R2") ctitles("Sync Change","Model(8)") replace
xi: reg dr2      laststar rating i.RatChange Cycle i.Indcd1, robust
outreg using "C:\Users\se7en\Desktop\Thesis2\dr2.doc", bdec(4) varlabels starlevels(5 1) sigsymbols(*,**) ///
       summstat(F\r2) summtitle("F Statistics"\"R2") ctitles("Sync Change","Model(9)") merge replace


*各分析师为样本回归
sort analyst InfoPubDt
statsby _b _se e(df_r) e(N), by(analyst) saving(AnaGroup.dta, replace): reg dr2 SENT
use AnaGroup.dta, clear
drop if _eq2_stat_2<20 | _eq2_stat_2==.
gen SENT_t=_b_SENT/_se_SENT
gen SENT_p=ttail(_eq2_stat_1,abs(SENT_t))
gen timing=1 if SENT_p<0.1 //择时的分析师
replace timing=0 if timing==.
save AnaGroup.dta, replace
