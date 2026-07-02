*! version 1.1.0  2026-07-02
cap program drop descrtab
program define descrtab, rclass

	syntax [if] [in] [, Continuous(varlist numeric) CATegorical(varlist) ///
		ORDER(varlist) USING(string) SHEET(string) REPLACE ROW(integer 2) ///
		DECForm(string) INTForm(string) LABels(string asis) ///
		FORMat(string asis) ]

	if `"`using'"' == "" {
		di as error "using() is required -- specify the Excel filename to write to"
		exit 198
	}
	if "`continuous'" == "" & "`categorical'" == "" {
		di as error "must specify continuous() and/or categorical()"
		exit 198
	}
	if `"`sheet'"' == "" local sheet "Table1"
	if `"`decform'"' == "" local decform ".000"
	if `"`intform'"' == "" local intform "0"

	* default order: continuous vars (in the order listed), then categorical
	if "`order'" == "" local order `continuous' `categorical'

	* parse labels(varname "display text" varname "display text" ...)
	local displayrest `"`labels'"'
	while `"`displayrest'"' != "" {
		gettoken lname displayrest : displayrest
		gettoken ltext displayrest : displayrest
		local custlbl_`lname' `"`ltext'"'
		local incontin : list lname in continuous
		local incat : list lname in categorical
		if !`incontin' & !`incat' {
			di as error "`lname' in labels() must also appear in continuous() or categorical()"
			exit 198
		}
	}

	* parse format(varname stat "numformat" varname stat "numformat" ...)
	* stat is one of mean/sd/min/max (continuous) or pct/n (categorical);
	* overrides decform()/intform() for that one cell only. Any valid Excel
	* number format string is allowed, e.g. "0.???" or "# ?/?".
	local fmtrest `"`format'"'
	while `"`fmtrest'"' != "" {
		gettoken fname fmtrest : fmtrest
		gettoken fstat fmtrest : fmtrest
		gettoken fnum  fmtrest : fmtrest
		local fstat = lower(`"`fstat'"')

		local incontin : list fname in continuous
		local incat : list fname in categorical
		if !`incontin' & !`incat' {
			di as error "`fname' in format() must also appear in continuous() or categorical()"
			exit 198
		}
		if `incontin' {
			if !inlist(`"`fstat'"', "mean", "sd", "min", "max") {
				di as error "format() stat for `fname' must be mean, sd, min, or max (`fname' is in continuous())"
				exit 198
			}
		}
		else {
			if !inlist(`"`fstat'"', "pct", "n") {
				di as error "format() stat for `fname' must be pct or n (`fname' is in categorical())"
				exit 198
			}
		}
		local custfmt_`fname'_`fstat' `"`fnum'"'
	}

	foreach v of local order {
		local incontin : list v in continuous
		local incat : list v in categorical
		if `incontin' & `incat' {
			di as error "`v' cannot appear in both continuous() and categorical()"
			exit 198
		}
		if !`incontin' & !`incat' {
			di as error "`v' in order() must also appear in continuous() or categorical()"
			exit 198
		}
	}

	local ifin `if' `in'

	* Set up the workbook / header row
	if "`replace'" != "" {
		putexcel set `"`using'"', sheet(`"`sheet'"') replace
		putexcel B1 = "Mean/%"
		putexcel C1 = "SD/n"
		putexcel D1 = "Min"
		putexcel E1 = "Max"
	}
	else {
		putexcel set `"`using'"', sheet(`"`sheet'"') modify
	}

	local r = `row'

	* ---- Write each variable in order(), as continuous or categorical ----
	foreach v of local order {
		local incontin : list v in continuous

		if `incontin' {
			quietly estpost summarize `v' `ifin'
			tempname mn sd mn2 mx
			matrix `mn'  = e(mean)'
			matrix `sd'  = e(sd)'
			matrix `mn2' = e(min)'
			matrix `mx'  = e(max)'

			local vlab : variable label `v'
			if `"`custlbl_`v''"' != "" local vlab `"`custlbl_`v''"'
			else if `"`vlab'"' == "" local vlab "`v'"
			matrix rownames `mn' = `"`vlab'"'

			local fmt_mean `"`decform'"'
			if `"`custfmt_`v'_mean'"' != "" local fmt_mean `"`custfmt_`v'_mean'"'
			local fmt_sd `"`decform'"'
			if `"`custfmt_`v'_sd'"' != "" local fmt_sd `"`custfmt_`v'_sd'"'
			local fmt_min `"`intform'"'
			if `"`custfmt_`v'_min'"' != "" local fmt_min `"`custfmt_`v'_min'"'
			local fmt_max `"`intform'"'
			if `"`custfmt_`v'_max'"' != "" local fmt_max `"`custfmt_`v'_max'"'

			putexcel A`r' = matrix(`mn'), rownames nformat(`fmt_mean')
			putexcel C`r' = matrix(`sd'), nformat(`fmt_sd')
			putexcel D`r' = matrix(`mn2'), nformat(`fmt_min')
			putexcel E`r' = matrix(`mx'), nformat(`fmt_max')

			local ++r
		}
		else {
			local vlab : variable label `v'
			if `"`custlbl_`v''"' != "" local vlab `"`custlbl_`v''"'
			else if `"`vlab'"' == "" local vlab "`v'"

			putexcel A`r' = `"`vlab'"', bold
			local ++r

			quietly estpost tabulate `v' `ifin'
			tempname pct b
			matrix `pct' = e(pct)'
			matrix `b'   = e(b)'
			local nrows = e(r)
			matrix `pct' = `pct'[1..`nrows',1]
			matrix `b'   = `b'[1..`nrows',1]

			local fmt_n `"`intform'"'
			if `"`custfmt_`v'_n'"' != "" local fmt_n `"`custfmt_`v'_n'"'

			if `"`custfmt_`v'_pct'"' != "" {
				putexcel A`r' = matrix(`pct'), rownames nformat(`custfmt_`v'_pct'')
			}
			else {
				putexcel A`r' = matrix(`pct'), rownames nformat(`decform'"%")
			}
			putexcel C`r' = matrix(`b'), nformat(`fmt_n')

			local r = `r' + `nrows'
		}
	}

	return scalar nextrow = `r'

end
