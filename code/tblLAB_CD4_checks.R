#############################################################
#
#   Program: tblCD4_checks.R
#   Project: IeDEA
# 
#   PI: Firas Wehbe, PhD
#   Biostatistician/Programmer: Meridith Blevins, MS
#   Purpose: Read in IeDEAS standard and write  
#            data queries
#
#   INPUT: "tblCD4.csv"
#   OUTPUT: 
#
#   Notes: As long as the working directory in "setwd" is
#          correctly pointing to the location of tblCD4.csv,
#          then this code should run smoothly, generating
#          a listing of data queries.
#
#   Created: 9 November 2012
#   Revisions: 
#     
#############################################################

## NAME OF TABLE FOR WRITING QUERIES
tablename <- "tblLAB_CD4"
## NAMES EXPECTED FROM HICDEP+/IeDEAS DES
expectednames <- c("patient","cd4_d","cd4_v","cd4_per")
acceptablenames <- c(expectednames,"cd4_d_a","site")

################### QUERY CHECKING BEGINS HERE ###################

## CHECK FOR EXTRA OR MISSING VARIABLES
extravar(acceptablenames,lab_cd4)
missvar(expectednames,lab_cd4)

## PRIOR TO CONVERTING DATES, CHECK THAT THE TYPE IS APPROPRIATE 
notdate(cd4_d,lab_cd4)

## CHECK FOR MISSING DATA
missingvalue(cd4_d,lab_cd4)
missingvalue(cd4_v,lab_cd4)
missingvalue(cd4_per,lab_cd4)

## CONVERT DATES USING EXPECTED FORMAT (will force NA if format is incorrect)
if(exists("cd4_d",lab_cd4)){lab_cd4$cd4_d <- convertdate(cd4_d,lab_cd4)}

## CHECK FOR DATES OCCURRING IN THE WRONG ORDER
if(exists("basic")){
	bascd4 <- merge(lab_cd4,with(basic,data.frame(patient,birth_d)),all.x=TRUE)
	bascd4$birth_d <- convertdate(birth_d,bascd4)
	outoforder(birth_d,cd4_d,bascd4,table2="tblBASIC")
}
if(exists("follow")){
       followcd4 <- merge(lab_cd4,with(follow,data.frame(patient,death_d)),all.x=TRUE)
	followcd4$death_d <- convertdate(death_d,followcd4)
	outoforder(cd4_d,death_d,followcd4,table2="tblFOLLOW")
}

## CHECK FOR DATES OCCURRING TOO FAR IN THE FUTURE
futuredate(cd4_d,lab_cd4)

## CHECK FOR INCORRECT VARIABLE TYPE (prior to range checks)
notnumeric(cd4_v,lab_cd4)
notnumeric(cd4_per,lab_cd4)

## CONVERT TO NUMERIC OR FORCE MISSING FOR NON-NUMERIC
if(exists("cd4_v",lab_cd4)){lab_cd4$cd4_v <- forcenumber(lab_cd4$cd4_v)}
if(exists("cd4_per",lab_cd4)){lab_cd4$cd4_per <- forcenumber(lab_cd4$cd4_per)}

## CHECK FOR DUPLICATE PATIENT IDs + RANGE CHECKS
queryduplicates(patient,lab_cd4,date=cd4_d)
upperrangecheck(cd4_v,3000,lab_cd4)
lowerrangecheck(cd4_v,0,lab_cd4)
upperrangecheck(cd4_per,100,lab_cd4)
lowerrangecheck(cd4_per,0,lab_cd4)

## CHECK FOR UNEXPECTED CODING
badcodes(cd4_d_a,c("<",">","D","M","Y","U"),lab_cd4)

## QUERY PATIENTS WITH NO RECORD IN tblBAS
badrecord(patient,lab_cd4,basic)


################### QUERY CHECKING ENDS HERE ###################
