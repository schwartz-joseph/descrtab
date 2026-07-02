{smcl}
{* *! version 1.1.0  2026-07-02}{...}
{title:Title}

{phang}
{bf:descrtab} {hline 2} Write a descriptives table (mean/SD/min/max for
continuous variables, %/n for categorical variables) directly to Excel.

{title:Syntax}

{p 8 17 2}
{cmd:descrtab} {ifin} {cmd:,}
[{cmd:continuous(}{it:varlist}{cmd:)}]
[{cmd:categorical(}{it:varlist}{cmd:)}]
[{cmd:order(}{it:varlist}{cmd:)}]
[{cmd:labels(}{it:varname} {cmd:"}{it:text}{cmd:"} {it:varname} {cmd:"}{it:text}{cmd:"} {it:...}{cmd:)}]
{cmd:using(}{it:filename}{cmd:)}
[{cmd:sheet(}{it:sheetname}{cmd:)}]
[{cmd:replace}]
[{cmd:row(}{it:#}{cmd:)}]
[{cmd:decform(}{it:string}{cmd:)}]
[{cmd:intform(}{it:string}{cmd:)}]
[{cmd:format(}{it:varname} {it:stat} {cmd:"}{it:numfmt}{cmd:"} {it:varname} {it:stat} {cmd:"}{it:numfmt}{cmd:"} {it:...}{cmd:)}]

{p 4 4 2}
At least one of {cmd:continuous()} / {cmd:categorical()} must be given.
By default, continuous variables are written first (in the order listed),
then categorical variables. Use {cmd:order()} to control the exact row
order instead.

{title:Description}

{pstd}
{cmd:descrtab} automates the loop-and-matrix workflow used to build a
publication-style descriptives table in Excel: for each continuous variable
it reports the mean, SD, min, and max; for each categorical variable it
reports the percent and n in each category, preceded by a bolded row
showing the variable's label. Row labels use each variable's
{cmd:variable label} when one is defined, falling back to the variable
name otherwise.

{title:Options}

{phang}{cmd:continuous(varlist)} numeric variables to summarize with
mean/SD/min/max.

{phang}{cmd:categorical(varlist)} variables to tabulate with %/n per
category (the "Total" row is dropped automatically).

{phang}{cmd:order(varlist)} controls the row order of the table. Must
contain exactly the variables given in {cmd:continuous()} and
{cmd:categorical()} (each variable in one or the other, not both). If
omitted, defaults to continuous variables first, then categorical.

{phang}{cmd:labels(varname "text" varname "text" ...)} overrides the row
label shown for specific variables, taking priority over that variable's
{cmd:variable label} (and over the variable name). Only variables that
need a custom display name need to be listed; every other variable still
falls back to its variable label, or its name if no label exists.

{phang}{cmd:using(filename)} required. Excel file to write to (passed to
{helpb putexcel}).

{phang}{cmd:sheet(sheetname)} worksheet name. Default is {cmd:Table1}.

{phang}{cmd:replace} start a new sheet with the header row (B1:E1 =
"Mean/%", "SD/n", "Min", "Max") and overwrite any existing sheet of the
same name. Omit this option to append below an existing sheet (uses
{cmd:putexcel ... modify}).

{phang}{cmd:row(#)} spreadsheet row to start writing at. Default is 2 (row
1 is the header). Use this together with the {cmd:r(nextrow)} return value
to chain multiple {cmd:descrtab} calls into one table -- e.g. run a
{cmd:categorical()} block, then a further {cmd:continuous()} block starting
at {cmd:row(`r(nextrow)')}.

{phang}{cmd:decform(string)} number format for means/SDs and percents.
Default is {cmd:.000} (percents automatically get a trailing {cmd:%}).

{phang}{cmd:intform(string)} number format for min/max/n. Default is
{cmd:0}.

{phang}{cmd:format(varname stat "numfmt" ...)} overrides {cmd:decform()}/
{cmd:intform()} for one specific cell of one specific variable, taking
priority over the defaults. {it:stat} is one of {cmd:mean}, {cmd:sd},
{cmd:min}, or {cmd:max} for a variable in {cmd:continuous()}, or {cmd:pct}
or {cmd:n} for a variable in {cmd:categorical()}. {it:numfmt} can be any
valid Excel number-format string, including custom formats such as
{cmd:"0.???"} or fraction formats like {cmd:"# ?/?"} -- it is passed
through to {helpb putexcel}'s {cmd:nformat()} as-is. Only the cells you
list are overridden; every other cell still uses {cmd:decform()}/
{cmd:intform()}. Example:
{cmd:format(mpg mean "0.???" weight max "#,##0")}.

{title:Stored results}

{pstd}
{cmd:descrtab} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(nextrow)}}next unused spreadsheet row (pass to {cmd:row()}
on a subsequent call to continue the table){p_end}

{title:Examples}

{phang}{cmd:. sysuse auto, clear}{p_end}

{phang}{cmd:. descrtab, continuous(price mpg trunk weight length) ///}{p_end}
{phang2}{cmd:categorical(rep78 foreign) using(descriptive_table) ///}{p_end}
{phang2}{cmd:sheet(table_1) replace}{p_end}

{phang}{cmd:. local nr = r(nextrow)}{p_end}

{phang}{cmd:. descrtab, continuous(turn displacement gear_ratio) ///}{p_end}
{phang2}{cmd:using(descriptive_table) sheet(table_1) row(`nr')}{p_end}

{title:Author}

{pstd}Joseph A. Schwartz{p_end}
{pstd}Website: {browse "https://josephaschwartz.com":josephaschwartz.com}{p_end}
{pstd}GitHub: {browse "https://github.com/schwartz-joseph":github.com/schwartz-joseph}{p_end}
