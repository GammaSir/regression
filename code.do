encode Country,gen(country)
drop Country
drop Unit

gen time=Time
drop Time

*generate a new varable to represent the change of exrate
gen dev_exrate=.
sort country time
bys country: replace dev_exrate=(ExRate-ExRate[_n-1])/ExRate[_n-1]

gen diff_er=dev_exrate
drop dev_exrate

gen m3_reserve=M3/reserve
gen m3_res_percent=.
bys country: replace m3_res_percent=(m3_reserve-m3_reserve[_n-1])/m3_reserve[_n-1]

gen export_percent=.
sort country time
bys country: replace export_percent=(export-export[_n-1])/export[_n-1]

gen diff_res=.
sort country time
bys country: replace diff_res=(reserve-reserve[_n-1])/reserve[_n-1]

gen ca=export-import

///interest deviation NOT finished
gen r_interest=interest-inflation

encode Country if country!=1 & country!=6 & country!=15,gen(new)
gen dev_r_interest=.
forvalues i=1/13 {
quietly reg r_interest time if new==`i'
quietly predict err`i' if new==`i',residuals 
replace dev_r_interest=err`i' if new==`i'
}


///detrend for exchange rate
gen dev_er_percent=.
forvalues i=1/16{
quietly reg ExRate_percent time if country==`i'
quietly predict err`i' if country==`i',residuals
quietly replace dev_er_percent=err`i' if country==`i'
}
drop err1-err16

xtprobit  crisis_24m I_dev_er p_dev_er IP_dev_er p_reserve_percent p_export_percent I_m3_reserve I_m3_reserve_percent,re
xtprobit  crisis_24m I_dev_er p_dev_er IP_dev_er p_reserve_percent p_export_percent I_m3_reserve I_m3_reserve_percent,pa
