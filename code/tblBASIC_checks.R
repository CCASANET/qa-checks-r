#############################################################
#
#   Program: tblBAS_checks.R
#   Project: CCASAnet
# 
#   PI: Firas Wehbe, PhD
#   Biostatistician/Programmer: Meridith Blevins, MS
#   Purpose: Read in CCASAnet data and write  
#            data queries
#
#   INPUT: "tblBAS.csv"
#   OUTPUT: 
#
#   Notes: As long as the working directory in "setwd" is
#          correctly pointing to the location of tblBAS.csv,
#          then this code should run smoothly, generating
#          a listing of data queries.
#
#   Created: 31 December 2013
#   Revisions: 
#     
#############################################################

## NAME OF TABLE FOR WRITING QUERIES
tablename <- "tblBASIC"
## NAMES EXPECTED FROM CCASAnet DTP -- vresion 0.9.6.20121218 
expectednames <- c("patient","birth_d","site","center","male_y",
		   "mode","mode_oth","hivdiagnosis_d","firstvis_d","enrol_d","recart_y","recart_d","recart_id",
                   "aids_y","aids_d","educationyears","education_oth","employed_y","marital_status")
acceptablenames <- c(expectednames,"birth_d_a","hivdiagnosis_d_a","firstvis_d_a","enrol_d_a","recart_d_a","aids_d_a","birth_mode")

################### QUERY CHECKING BEGINS HERE ###################

## CHECK FOR EXTRA OR MISSING VARIABLES
extravar(acceptablenames,basic)
missvar(expectednames,basic)

## PRIOR TO CONVERTING DATES, CHECK THAT THE TYPE IS APPROPRIATE 
notdate(birth_d,basic)
notdate(firstvis_d,basic)
notdate(hivdiagnosis_d,basic)
notdate(enrol_d,basic)
notdate(recart_d,basic)
notdate(aids_d,basic)

## CHECK FOR MISSING DATA
missingvalue(patient,basic)
missingvalue(birth_d,basic)
missingvalue(site,basic)
missingvalue(male_y,basic)
missingvalue(mode,basic)
missingvalue(hivdiagnosis_d,basic)
missingvalue(firstvis_d,basic)
missingvalue(enrol_d,basic)
missingvalue(recart_y,basic)
missingvalue(aids_y,basic)
# check missing aids_d only among those confirmed with aids
hasaids <- basic[basic$aids_y==1,]
missingvalue(aids_d,hasaids)

## CONVERT DATES USING EXPECTED FORMAT (will force NA if format is incorrect)
if(exists("birth_d",basic)){basic$birth_d <- convertdate(birth_d,basic)}
if(exists("firstvis_d",basic)){basic$firstvis_d <- convertdate(firstvis_d,basic)}
if(exists("hivdiagnosis_d",basic)){basic$hivdiagnosis_d <- convertdate(hivdiagnosis_d,basic)}
if(exists("enrol_d",basic)){basic$enrol_d <- convertdate(enrol_d,basic)}
if(exists("recart_d",basic)){basic$recart_d <- convertdate(recart_d,basic)}
if(exists("aids_d",basic)){basic$aids_d <- convertdate(aids_d,basic)}

## CHECK FOR DATES OCCURRING IN THE WRONG ORDER
outoforder(birth_d,firstvis_d,basic)
outoforder(birth_d,hivdiagnosis_d,basic)
outoforder(birth_d,enrol_d,basic)
outoforder(birth_d,recart_d,basic)
outoforder(birth_d,aids_d,basic)
outoforder(hivdiagnosis_d,enrol_d,basic)
outoforder(hivdiagnosis_d,aids_d,basic)
outoforder(hivdiagnosis_d,haart_d,basic)

## CHECK FOR DATES OCCURRING TOO FAR IN THE FUTURE
futuredate(birth_d,basic)
futuredate(firstvis_d,basic)
futuredate(hivdiagnosis_d,basic)
futuredate(enrol_d,basic)
futuredate(recart_d,basic)
futuredate(aids_d,basic)

## CHECK FOR DUPLICATE PATIENT IDs
queryduplicates(patient,basic)

## CHECK FOR UNEXPECTED CODING
badcodes(male_y,c(0,1,2,9),basic)
badcodes(recart_y,c(0,1,2,9),basic)
badcodes(aids_y,c(0,1,2,9),basic)
badcodes(birth_mode,c("Caesarian","Vaginal"),basic)
badcodes(birth_d_a,c("<",">","D","M","Y","U"),basic)
badcodes(firstvis_d_a,c("<",">","D","M","Y","U"),basic)
badcodes(hivdiagnosis_d_a,c("<",">","D","M","Y","U"),basic)
badcodes(enrol_d_a,c("<",">","D","M","Y","U"),basic)
badcodes(recart_d_a,c("<",">","D","M","Y","U"),basic)
badcodes(aids_d_a,c("<",">","D","M","Y","U"),basic)

## TRANSPOSE MODE STRINGS TO BE 1 TRANSMISSION PER ROW
newbasic <- concatTranspose(mode,basic,sep="+")
badcodes(mode,c(1,2,4,5,6,8,9,10,90,99),newbasic)

################### QUERY CHECKING ENDS HERE ###################
