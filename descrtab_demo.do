* Demo/test script for descrtab.ado
* Reproduces the table from example_descriptives.do using the new command.

cd "[filepath]"
sysuse auto, clear

descrtab, continuous(price mpg trunk weight length) ///
	categorical(rep78 foreign) ///
	labels(price "Vehicle Price" mpg "Miles per Gallon" rep78 "Repair Record 1978") ///
	using(descriptive_table_test) sheet(table_1) replace

* Chain a second block onto the same table
descrtab, continuous(turn displacement gear_ratio) ///
	using(descriptive_table_test) sheet(table_1) row(`r(nextrow)')
