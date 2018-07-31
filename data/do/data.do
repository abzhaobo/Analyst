clear
cd "D:\Res_Stata"
unicode analyze *.txt
unicode encoding set "GB18030"
unicode retranslate *.txt, transutf8

*收益率
import delimited D:\GTA_Stata\TRD_Cnmont.txt, case(preserve) encoding(UTF-8) clear
rename Trdmnt SgnMonth
rename Cmretwdos mktrtm
gen month=monthly(SgnMonth,"YM")
save mktrtm.dta, replace  //考虑再投资的综合月市场回报率(流通市值加权平均)
import delimited D:\GTA_Stata\TRD_Cndalym.txt, case(preserve) encoding(UTF-8) clear
rename Cdretwdos mktrt
save mktrt.dta, replace   //考虑再投资的综合日市场回报率(流通市值加权平均)
import delimited D:\GTA_Stata\TRD_Dalyr1.txt, case(preserve) encoding(UTF-8) stringcols(1) clear
save dalyr1.dta, replace
import delimited D:\GTA_Stata\TRD_Dalyr2.txt, case(preserve) encoding(UTF-8) stringcols(1) clear
save dalyr2.dta, replace
import delimited D:\GTA_Stata\TRD_Dalyr3.txt, case(preserve) encoding(UTF-8) stringcols(1) clear
save dalyr3.dta, replace
import delimited D:\GTA_Stata\TRD_Dalyr4.txt, case(preserve) encoding(UTF-8) stringcols(1) clear
append using dalyr1.dta dalyr2.dta dalyr3.dta
rename Dretwd stkrt      //考虑再投资的日个股回报率
merge m:1 Trddt using mktrt.dta, keep(match) nogen
sort Stkcd Trddt
gen date=date(Trddt,"YMD")
save "C:\Users\se7en\Desktop\Thesis2\do&data\return.dta", replace

*公司控制变量
import delimited D:\GTA_Stata\TRD_Year.txt, case(preserve) encoding(UTF-8) stringcols(1) clear
rename Trdynt year
rename Ysmvosd Mvl
rename Ysmvttl Mvt
save firmct.dta, replace
import delimited D:\GTA_Stata\FS_Combas.txt, case(preserve) encoding(UTF-8) stringcols(1) clear
rename A001000000 tasset
gen year=substr(Accper,1,4)
destring year,replace
merge 1:1 Stkcd year using firmct.dta, nogen
save firmct.dta, replace
infile  str6 Stkcd str10 Enddt str24 ROE str24 ROA str24 Dbastrt using D:\Res_Stata\FINRATIO_AE5F9D1D9E1_1.txt,clear
destring ROE,replace
destring ROA,replace
destring Dbastrt,replace
gen year=substr(Enddt,1,4)
destring year,replace
merge 1:1 Stkcd year using firmct.dta, nogen
save firmct.dta, replace

*关注度
import delimited D:\GTA_Stata\AF_CfeatureProfile.txt, case(preserve) encoding(UTF-8) stringcols(1) clear
gen year=substr(Accper,1,4)
destring year,replace
save attention.dta, replace
*行业代码
infile  str6 Stkcd str20 Indcd1 str100 IndNm1 using D:\Res_Stata\INDCLS_BA1FBB2721B_1.txt,clear
save ind.dta,replace

*月度换手率
import delimited D:\GTA_Stata\SRFR_Amnthlyr.txt, case(preserve) encoding(UTF-8) stringcols(1) clear
rename Trdmnt SgnMonth

gen Month=monthly(SgnMonth,"YM")
destring Stkcd, g(Stk)
xtset Stk Month
tsfill
replace Stkcd=Stkcd[_n-1] if Stkcd==""
gen month2=date(SgnMonth,"YM")
format month2 %tdCCYY-NN
replace month2=l.month2+31 if month2==.
replace month2 = date("01nov2012","DMY") in 10173
replace month2 = date("01dec2012","DMY") in 10174
replace month2 = date("01jan2013","DMY") in 10175
tostring month2, force usedisplayformat replace
replace SgnMonth=month2 if SgnMonth==""
drop month2

replace Dturn=0 if Dturn==.
gen AbTURN=l.Dturn/l2.Dturn
replace AbTURN=0 if AbTURN==. & l.Dturn==0
replace AbTURN=1 if AbTURN==. & l.Dturn!=0
drop if Month<588

save turnover.dta, replace


*新财富
infile  str10 AwdDt str4 year str12 ReDirCd str6 Ranking str12 OrgCd str40 OrgNm str140 AnaName using D:\Res_Stata\RRAGEAWD_F6E59AD532E_1.txt,clear
destring year,replace
destring ReDirCd,replace
destring Ranking,replace
destring OrgCd,replace
replace AnaName=subinstr(AnaName,"研究小组","",.)
replace AnaName=subinstr(AnaName,"研究团队","",.)
replace AnaName=subinstr(AnaName,"等","",.)
replace AnaName=subinstr(AnaName,"(","",.)
replace AnaName=subinstr(AnaName,")","",.)
replace AnaName=subinstr(AnaName,"（","",.)
replace AnaName=subinstr(AnaName,"）","",.)
drop if AnaName == ""
split AnaName, p(/)
duplicates drop AnaName1 year,force
replace AnaName2=AnaName1
replace AnaName3=AnaName1
replace AnaName4=AnaName1
replace AnaName5=AnaName1
replace AnaName6=AnaName1
gen AnaName7=AnaName1
save awd.dta, replace

*非深度报告
infile  str10 InfoPubDt str20 OrgNm str70 AnaName str6 Stkcd str10 R_SecuCode str30 LstkNm str10 LWritDt str12 PageNum using D:\Res_Stata\RRRERE_EXT_AEE31685C0F_1.txt,clear
save rere1.dta, replace
infile  str10 InfoPubDt str20 OrgNm str70 AnaName str6 Stkcd str10 R_SecuCode str30 LstkNm str10 LWritDt str12 PageNum using D:\Res_Stata\RRRERE_EXT_CE4FFD71B85_2.txt,clear
save rere2.dta, replace
infile  str10 InfoPubDt str20 OrgNm str70 AnaName str6 Stkcd str10 R_SecuCode str30 LstkNm str10 LWritDt str12 PageNum using D:\Res_Stata\RRRERE_EXT_FF110775258_3.txt,clear
save rere3.dta, replace
infile  str10 InfoPubDt str20 OrgNm str70 AnaName str6 Stkcd str10 R_SecuCode str30 LstkNm str10 LWritDt str12 PageNum using D:\Res_Stata\RRRERE_EXT_60DBD3C41D4_4.txt,clear
save rere4.dta, replace
infile  str10 InfoPubDt str20 OrgNm str70 AnaName str6 Stkcd str10 R_SecuCode str30 LstkNm str10 LWritDt str12 PageNum using D:\Res_Stata\RRRERE_EXT_36CAD91F2AC_5.txt,clear
append using rere1.dta rere2.dta rere3.dta rere4.dta
destring PageNum,replace
duplicates drop LWritDt Stkcd OrgNm, force
gen SgnMonth=substr(InfoPubDt,1,7)
save reren.dta, replace

*深度报告
infile  str10 InfoPubDt str20 OrgNm str70 AnaName str6 Stkcd str10 R_SecuCode str30 LstkNm str10 LWritDt str12 PageNum using D:\Res_Stata\RRRERE_EXT_A1CFD251573_1.txt,clear
destring PageNum,replace
duplicates drop LWritDt Stkcd OrgNm, force
gen SgnMonth=substr(InfoPubDt,1,7)
save rered.dta, replace

*最终样本
infile str12 OrgCd str20 OrgNm str10 LWritDt str6 Stkcd str10 R_SecuCode str30 LstkNm str24 CurRating str24 LastRating using D:\Res_Stata\RRTAPRIRAT_654A293A34F_1.txt,clear
destring OrgCd,replace
destring CurRating,replace
destring LastRating,replace
duplicates drop LWritDt Stkcd OrgNm, force
merge 1:1 LWritDt Stkcd OrgNm using rered.dta, keep(match) nogen
merge m:1 Stkcd using ind.dta, keep(match) nogen
drop if Indcd1=="J"
//10-买入；13-增持；20-中性；30-减持；33-卖出；99-未评级
replace CurRating=5 if CurRating==10
replace CurRating=4 if CurRating==13
replace CurRating=3 if CurRating==20
replace CurRating=2 if CurRating==30
replace CurRating=1 if CurRating==33
replace LastRating=5 if LastRating==10
replace LastRating=4 if LastRating==13
replace LastRating=3 if LastRating==20
replace LastRating=2 if LastRating==30
replace LastRating=1 if LastRating==33
drop if CurRating==. | CurRating==99
gen RatChange="Up" if CurRating>LastRating
replace RatChange="Keep" if CurRating==LastRating
replace RatChange="Down" if CurRating<LastRating
replace RatChange="First" if LastRating==.

gen year=substr(InfoPubDt,1,4)
destring year, replace
split AnaName, p(/)
egen analyst=group(AnaName1)
drop if analyst<10 //缺少作者信息的

forvalues i=1(1)7{
   merge m:1 AnaName`i' year using awd.dta, gen(_merge`i') update
   }
drop if LWritDt==""
gen star=1 if Ranking!=.
replace star=0 if star==.
drop AwdDt ReDirCd Ranking _merge*

replace year=year-1
forvalues i=1(1)7{
   merge m:1 AnaName`i' year using awd.dta, gen(_merge`i') update
   }
drop if LWritDt==""
gen laststar=1 if Ranking!=.
replace laststar=0 if laststar==.
drop AwdDt ReDirCd Ranking AnaName* _merge* OrgNm year

bys SgnMonth: egen RpNum=count(SgnMonth) //当月发布报告总数
bys SgnMonth Stkcd: egen PubNum=count(SgnMonth) //当月发布的该公司报告总数
save "C:\Users\se7en\Desktop\Thesis2\do&data\report.dta", replace //全部报告样本

duplicates drop Stkcd SgnMonth, force
save "C:\Users\se7en\Desktop\Thesis2\do&data\publish.dta", replace //仅考虑各股每月是否有报告的数据
