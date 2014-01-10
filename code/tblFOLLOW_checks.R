#############################################################
#
#   Program: tblBAS_checks.R
#   Project: IeDEA
# 
#   PI: Firas Wehbe, PhD
#   Biostatistician/Programmer: Meridith Blevins, MS
#   Purpose: Read in IeDEAS standard and write  
#            data queries
#
#   INPUT: "tblLTFU.csv"
#   OUTPUT: 
#
#   Notes: As long as the working directory in "setwd" is
#          correctly pointing to the location of tblBAS.csv,
#          then this code should run smoothly, generating
#          a listing of data queries.
#
#   Created: 29 March 2013
#   Revisions: 
#     
#############################################################

## NAME OF TABLE FOR WRITING QUERIES
tablename <- "tblFOLLOW"
## NAMES EXPECTED FROM HICDEP+/IeDEAS DES
expectednames <- c("patient","drop_y","drop_d","drop_rs","drop_oth","death_y","death_d","autop_y",
                   "death_r1","death_oth1","death_rc1","death_r2","death_oth2","death_rc2","death_r3","death_oth3","death_rc3",
                   "l_alive_d")
acceptablenames <- c(expectednames,"drop_d_a","death_d_a","l_alive_d_a","site",
                     "death_mother_y","death_mother_d","death_mother_d_a","death_father_y","death_father_d","death_father_d_a","other_story")

################### QUERY CHECKING BEGINS HERE ###################

## CHECK FOR EXTRA OR MISSING VARIABLES
extravar(acceptablenames,follow)
missvar(expectednames,follow)

## PRIOR TO CONVERTING DATES, CHECK THAT THE TYPE IS APPROPRIATE 
notdate(death_d,follow)
notdate(l_alive_d,follow)
notdate(drop_d,follow)

## CHECK FOR MISSING DATA
# missingvalue(death_d,follow)
missingvalue(l_alive_d,follow)
# missingvalue(drop_d,follow)
missingvalue(drop_y,follow)
missingvalue(death_y,follow)
missingvalue(autop_y,follow)
# l_alive_d is computed and discouraged in dtp, so we do not query missing
# missingvalue(l_alive_d,follow)
# check missing death_d only among those confirmed dead
isdead <- basic[basic$death_y==1,]
missingvalue(death_d,isdead)
# check missing drop_d only among those confirmed dropped
isdrop <- basic[basic$drop_y==1,]
missingvalue(drop_d,isdrop)

## CONVERT DATES USING EXPECTED FORMAT (will force NA if format is incorrect)
if(exists("death_d",follow)){follow$death_d <- convertdate(death_d,follow)}
if(exists("l_alive_d",follow)){follow$l_alive_d <- convertdate(l_alive_d,follow)}
if(exists("drop_d",follow)){follow$drop_d <- convertdate(drop_d,follow)}
if(exists("death_father_d",follow)){follow$death_d <- convertdate(death_d,follow)}
if(exists("death_mother_d",follow)){follow$death_d <- convertdate(death_d,follow)}

## CHECK FOR DATES OCCURRING IN THE WRONG ORDER
if(exists("basic")){
	basfollow <- merge(follow,with(basic,data.frame(patient,birth_d,enrol_d)),all.x=TRUE)
	basfollow$birth_d <- convertdate(birth_d,basfollow)
	outoforder(birth_d,death_d,basfollow,table2="tblBASIC")
	outoforder(birth_d,l_alive_d,basfollow,table2="tblBASIC")
	outoforder(birth_d,drop_d,basfollow,table2="tblBASIC")
	outoforder(enrol_d,death_d,basfollow,table2="tblBASIC")
	outoforder(enrol_d,l_alive_d,basfollow,table2="tblBASIC")
	outoforder(enrol_d,drop_d,basfollow,table2="tblBASIC")
}

## CHECK FOR DATES OCCURRING IN THE WRONG ORDER
outoforder(l_alive_d,death_d,follow)
outoforder(drop_d,death_d,follow)

## CHECK FOR DATES OCCURRING TOO FAR IN THE FUTURE
futuredate(death_d,follow)
futuredate(l_alive_d,follow)
futuredate(drop_d,follow)

## CHECK FOR DUPLICATE PATIENT IDs
queryduplicates(patient,follow)

## QUERY PATIENTS WITH NO RECORD IN tblBAS (bad ID)
badrecord(patient,follow,basic)

## CHECK FOR UNEXPECTED CODING
badcodes(drop_y,c(0,1,2,9),follow)
badcodes(death_y,c(0,1,2,9),follow)
badcodes(autop_y,c(0,1,2,9),follow)
badcodes(death_mother_y,c(0,1,2,9),follow)
badcodes(death_father_y,c(0,1,2,9),follow)
badcodes(drop_rs,c(1,3:9),follow)
badcodes(death_r1,c(1:10,20,90,91,92,93,99,4.1,7.1,7.2,8.1,8.2),follow)
badcodes(death_r2,c(1:10,20,90,91,92,93,99,4.1,7.1,7.2,8.1,8.2),follow)
badcodes(death_r3,c(1:10,20,90,91,92,93,99,4.1,7.1,7.2,8.1,8.2),follow)
badcodes(death_rc1,c("I","U","C","N"),follow)
badcodes(death_rc2,c("I","U","C","N"),follow)
badcodes(death_rc3,c("I","U","C","N"),follow)
badcodes(death_d_a,c("<",">","D","M","Y","U"),follow)
badcodes(l_alive_d_a,c("<",">","D","M","Y","U"),follow)
badcodes(drop_d_a,c("<",">","D","M","Y","U"),follow)
badcodes(death_father_d_a,c("<",">","D","M","Y","U"),follow)
badcodes(death_mother_d_a,c("<",">","D","M","Y","U"),follow)

################### QUERY CHECKING ENDS HERE ###################
