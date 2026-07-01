

/**Bringing it all together--syntax to make a descriptives table**/

*	I found these issues so frustrating for so long that I relied on other 
*	methods (ones I'm not too proud of) to create my descriptives tables for a 
*	LOOOOONNNNNGGGGG time! Finally, I broke down and was determined to automate 
*	the process. That led me to what I am about to share with you. Some syntax 
*	that can easily generate descriptives tables with minimal effort and that
*	only requires a little bit of formatting once it has been created. 

*	Just a quick word of warning, the syntax is a bit complex, but I'll do my 
*	best to walk you through it. 

*	Basically, I rely on a series of loops and macros to accomplish this task. 
*	To my knowledge, there is no user-written command that can do this. Maybe 
*	one day, if I ever have time, I'll write one to expedite this process and 
*	make it more user-friendly, but for now this will get the job done.

*	Ok, on to the syntax! The way this works is that you will need to write 
*	seperate loops for your continuous variables (for which you want means and 
*	SDs) and your categorical ones (for which you want pecentages and sample 
*	sizes). Sometimes I'll break each set of variables into multiple subsets, 
*	depending on the order in which I want my variables to appear in the final 
*	table. This isn't 100% necessary, but recommended for publication ready 
*	tables which should be well-organized and easy to read. In any case, let's 
*	take a look at the syntax:


cd "[filepath]/Tables"

putexcel set descriptive_table, /// 
	sheet(table_1_new) /// 		
	replace 				
	
putexcel B1 = "Mean/%"
putexcel C1 = "SD/n"
putexcel D1 = "Min"
putexcel E1 = "Max"

local j 1 			//We need to start a count so we can tell Stata where to 
*					//put each matrix

*	We start with our loop for continuous variables (mean/SD)

foreach i of varlist price mpg trunk weight length {
	local ++j 		//Again, this if for our count, the ++ tells Stata to add 1 
					//to our `j' from above

	estpost su `i'				//Same syntax as above, but uses our local
	mat `i'mean = e(mean)' 
	mat `i'sd = e(sd)'
	mat `i'min = e(min)'
	mat `i'max = e(max)'
	
	putexcel A`j' = matrix(`i'mean), rownames nformat(.000)	//Uses `j' to tell  
	putexcel C`j' = matrix(`i'sd), nformat(.000)			//Stata where to
	putexcel D`j' = matrix(`i'min), nformat(0)				//put the matrices
	putexcel E`j' = matrix(`i'max), nformat(0)			
}
					
*	Now we move on to our categorical variables. Notice I do not have to reset 
*	`j' or the location of where we drop in the new matrices! This is all part 
*	of the loop so we don't have to keep track!

foreach i of varlist rep78 foreign {
	local ++j			//Same thing, == `j'+1 to move to the next row 
	
	estpost tab `i'		//Same syntax as we used above

	mat `i'pct = e(pct)'
	mat `i'b = e(b)'

	local rows = e(r)	//This is the magic piece! We can move down the number
						//of rows in the matrix auto-magically!
	mat `i'pct = `i'pct[1..`rows',1]	//More mata language, removes the Total
	mat `i'b = `i'b[1..`rows',1]		//row from the matrix 
	
	putexcel A`j' = matrix(`i'pct), rownames nformat(.000"%") //Same as above
	putexcel C`j' = matrix(`i'b), nformat(0)
	
	local j = `j'+(`rows'-1)	//Takes into account that we have added more 
								//than 1 row to the table so we can add more 
								//below easily
}

*	And that is pretty much it! We do have a few limitations:
*		1. The same error message persists. It's annoying, but shouldn't cause 
*			any real problems
*		2. We don't have formatted variable names
*		3. We have the variable label categories for categorical variables, 
*			but no variable name (you'll have to add this manually when you 
*			format the table)
*		4. Anytime you want to add in a new variable or make a change, you 
*			have to rerun the entire chunk of syntax since it is so dependent 
*			on locals

*	Even with these limitations, this is still a great improvment over just 
*	about any other option. Plus, it is totally modular! Once you change out 
*	the varlists in the loops, you can leave the rest of the code alone and it 
*	just works. You can also easily add new loops to modify the order of the 
*	variables presented. So let's say we want to add some more continous 
*	variables after our categorical variable loop. No problem, just add it in!


putexcel set descriptive_table, /// 
	sheet(table_1_new) /// 		
	replace				
	
putexcel B1 = "Mean/%"
putexcel C1 = "SD"
putexcel D1 = "Min"
putexcel E1 = "Max"

local j 1 			

foreach i of varlist price mpg trunk weight length {
	local ++j 		

	estpost su `i'	
	mat `i'mean = e(mean)' 
	mat `i'sd = e(sd)'
	mat `i'min = e(min)'
	mat `i'max = e(max)'
	
	putexcel A`j' = matrix(`i'mean), rownames nformat(.000)	 
	putexcel C`j' = matrix(`i'sd), nformat(.000)			
	putexcel D`j' = matrix(`i'min), nformat(0)		
	putexcel E`j' = matrix(`i'max), nformat(0)			
}
					

foreach i of varlist rep78 foreign {
	local ++j			
	
	estpost tab `i'		

	mat `i'pct = e(pct)'
	mat `i'b = e(b)'

	local rows = e(r)	
						
	mat `i'pct = `i'pct[1..`rows',1]	
	mat `i'b = `i'b[1..`rows',1]		
	
	putexcel A`j' = matrix(`i'pct), rownames nformat(.000"%") 
	putexcel C`j' = matrix(`i'b), nformat(0)
	
	local j = `j'+(`rows'-1)	
}	
								
*	Here's our new loop:

foreach i of varlist turn displacement gear_ratio {
	local ++j 		

	estpost su `i'	
	mat `i'mean = e(mean)' 
	mat `i'sd = e(sd)'
	mat `i'min = e(min)'
	mat `i'max = e(max)'
	
	putexcel A`j' = matrix(`i'mean), rownames nformat(.000)	
	putexcel C`j' = matrix(`i'sd), nformat(.000) 
	putexcel D`j' = matrix(`i'min), nformat(0) 
	putexcel E`j' = matrix(`i'max), nformat(0) 
}

*	You can keep adding and adding until your table is complete!
