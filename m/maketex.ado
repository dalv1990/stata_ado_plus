**************************************
*This is maketex.ado beta version
*24 Aug 2001
*Questions, comments and bug reports : 
*terracol@univ-paris1.fr
*************************************
cap prog drop maketex
prog define maketex
version 7.0

syntax using/ ,[CLASS(string)] [CLASSOPTions(string)] [PACKages(string)] [TITle(string)] [AUTHor(string)] [DATE(string)]

*****************
* Checking OS
*****************

if "$S_OS"!="Windows" & "$S_OS"!="Unix" {
            di as error "Sorry, this will not work for Macs"
            exit 198
}


***********************
*setting file extension
***********************
tokenize "`using'", parse(.)
local file="`1'.tex"
if "`3'"=="" {
			local using="`1'.tex"
		}

cap confirm file `using'
if _rc==601 {
		di as error "file `using' not found"
		exit
		}
tempfile header
tempname header
tempfile footer
tempname footer
tempfile mid
tempname midh



**********************
*setting file path
**********************
tokenize "`file'" ,parse(/)
local file2=""
while "`1'"!="" {
		 if "`2'"!=""{
				local file2="`file2'"+"`1'"+"\"
					}
		 if "`2'"==""{
				local file2="`file2'"+"`1'"
					}
		 mac shift
		 mac shift
		}



tokenize "`using'" ,parse(/)
local using2=""
while "`1'"!="" {
		 if "`2'"!=""{
					local using2="`using2'"+"`1'"+"\"
				}
		 if "`2'"==""{
					local using2="`using2'"+"`1'"
				}
		 mac shift
		 mac shift
		}


***********************************
*Document class and class options
***********************************
if "`class'"=="" {
			local class="article"
			}
if "`classoptions'" !="" {
					tokenize "`classoptions'"
					while "`1'"!="" {
								local clsopt="`clsopt'"+"`1'"
								mac shift
								}
					local clsopt="["+"`clsopt'"+"]"
					}


file open `header' using `header' ,write text
file write `header' "%file generated by maketex on $S_DATE at $S_TIME %"_n 
file write `header' "\documentclass`clsopt'{`class'}"_n 


*************
*Packages 
*************
tokenize "`packages'"
local nbpack=0
while "`1'"!="" {
			local nbpack=`nbpack'+1
			mac shift
			}
local i=1
local j=`i'+2
while `i'<=`nbpack' {
				tokenize "`packages'"
				tokenize "``i''",parse(":")
				

				if "`3'"!="" {
					 		local packopt="[`1']"
						      file write `header' "\usepackage`packopt'{`3'}"_n 
							}
				if "`3'"=="" {
							file write `header' "\usepackage{`1'}"_n 
						}
						
			local i=`i'+1
			}

file write `header' "\begin{document}"_n

*******************
*Title
******************
if "`title'"!="" {
			file write `header' "\title{`title'}"_n 
			}
if "`author'"!="" {
			file write `header' "\author{`author'}"_n 
			}
if "`date'"!="" {
			file write `header' "\date{`date'}"_n 
			}
	
if ("`title'"!="" | "`author'"!="" | "`date'"!="") {
									file write `header' "\maketitle"_n 
									}


file close `header'

if "$S_OS" == "Unix" {
            !cat `using2'  > `mid' 
    }

    else if "$S_OS" == "Windows" {
            !type `using2' > `mid'
    }
    else {
            di as error "Sorry, this will not work for Macs"
            exit 198
    }


file open `footer' using `footer', write text
file write `footer' _n"\end{document}"_n 
file close `footer'


    if "$S_OS" == "Unix" {
            !cat `header' `mid' `footer' > `file' 
    }

else if "$S_OS"=="Windows" {
					!type `header'> `file2'
					!type `mid' >> `file2'
					!type `footer'>> `file2'
				}
    else {
            di as error "Sorry, this will not work for Macs"
            exit 198
    }


erase `header'
erase `footer'
erase `mid'

di `"file {view "`file'"} saved"'
end
