# descrtab

A Stata command that automates building a publication-style descriptives
table (mean/SD/min/max for continuous variables, %/n for categorical
variables) and writes it directly to Excel via `putexcel`.

Replaces the manual loop-and-matrix workflow in `example_descriptives.do`
with a single command.

## Installation

From within Stata:

```stata
net install descrtab, from("https://raw.githubusercontent.com/schwartz-joseph/descrtab/main/") replace
```

Or manually: copy `descrtab.ado` and `descrtab.sthlp` into a folder on
your Stata `adopath` (or just keep them in your working directory /
project folder and `cd` there before use).

## Usage

```stata
sysuse auto, clear

descrtab, continuous(price mpg trunk weight length) ///
    categorical(rep78 foreign) ///
    labels(price "Vehicle Price" mpg "Miles per Gallon" rep78 "Repair Record 1978") ///
    order(foreign price rep78 mpg trunk weight length) ///
    using(descriptive_table) sheet(table_1) replace

* Chain another block onto the same table
descrtab, continuous(turn displacement gear_ratio) ///
    using(descriptive_table) sheet(table_1) row(`r(nextrow)')
```

See `descrtab_demo.do` for a runnable example, and `descrtab.sthlp`
(`help descrtab` once installed) for full syntax and options:
`continuous()`, `categorical()`, `order()`, `labels()`, `using()`,
`sheet()`, `replace`, `row()`, `decform()`, `intform()`, `format()`.

## Author

Joseph A. Schwartz
Website: [josephaschwartz.com](https://josephaschwartz.com)
GitHub: [github.com/schwartz-joseph](https://github.com/schwartz-joseph)
