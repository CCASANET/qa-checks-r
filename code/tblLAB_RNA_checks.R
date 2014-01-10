#############################################################
#
#   Program: tblRNA_checks.R
#   Project: IeDEA
# 
#   PI: Firas Wehbe, PhD
#   Biostatistician/Programmer: Meridith Blevins, MS
#   Purpose: Read in IeDEAS standard and write  
#            data queries
#
#   INPUT: "tblRNA.csv"
#   OUTPUT: 
#
#   Notes: As long as the working directory in "setwd" is
#          correctly pointing to the location of tblRNA.csv,
#          then this code should run smoothly, generating
#          a listing of data queries.
#
#   Created: 9 November 2012
#   Revisions: 
#     
#############################################################

## NAME OF TABLE FOR WRITING QUERIES
tablename <- "tblLAB_RNA"
## NAMES EXPECTED FROM HICDEP+/IeDEAS DES
expectednames <- c("patient","rna_d","rna_v","rna_l","rna_u","rna_t")
acceptablenames <- c(expectednames,"rna_d_a","site")

################### QUERY CHECKING BEGINS HERE ###################

## CHECK FOR EXTRA OR MISSING VARIABLES
extravar(acceptablenames,lab_rna)
missvar(expectednames,lab_rna)

## PRIOR TO CONVERTING DATES, CHECK THAT THE TYPE IS APPROPRIATE 
notdate(rna_d,lab_rna)

## CHECK FOR MISSING DATA
missingvalue(rna_d,lab_rna)
missingvalue(rna_v,lab_rna)
# it's okay for "rna_l" and "rna_t" and "rna_u" to be missing 

## CONVERT DATES USING EXPECTED FORMAT (will force NA if format is incorrect)
if(exists("rna_d",lab_rna)){lab_rna$rna_d <- convertdate(rna_d,lab_rna)}

## CHECK FOR DATES OCCURRING IN THE WRONG ORDER
if(exists("basic")){
	basrna <- merge(lab_rna,with(basic,data.frame(patient,birth_d)),all.x=TRUE)
	basrna$birth_d <- convertdate(birth_d,basrna)
	outoforder(birth_d,rna_d,basrna,table2="tblBASIC")
}
if(exists("follow")){
        followrna <- merge(lab_rna,with(follow,data.frame(patient,death_d)),all.x=TRUE)
	followrna$death_d <- convertdate(death_d,followrna)
	outoforder(rna_d,death_d,followrna,table2="tblFOLLOW")
}

## CHECK FOR DATES OCCURRING TOO FAR IN THE FUTURE
futuredate(rna_d,lab_rna)

## CHECK FOR INCORRECT VARIABLE TYPE (prior to range checks)
notnumeric(rna_v,lab_rna)
notnumeric(rna_l,lab_rna)
notnumeric(rna_u,lab_rna)
notnumeric(rna_t,lab_rna)

## CONVERT TO NUMERIC OR FORCE MISSING FOR NON-NUMERIC
if(exists("rna_v",lab_rna)){lab_rna$rna_v <- forcenumber(lab_rna$rna_v)}

## CHECK FOR DUPLICATE PATIENT IDs + RANGE CHECKS
queryduplicates(patient,lab_rna,date=rna_d)
upperrangecheck(rna_v,10000000,lab_rna)
#lowerrangecheck(rna_v,-1,lab_rna)
# can use detection limit as negative value, eg -80 means that the lowest detection limit is 80, and the result was undetectable
outoforder(rna_l,rna_v,basic)
outoforder(rna_v,rna_u,basic)


## CHECK FOR UNEXPECTED CODING
badcodes(rna_t,c(5, 10, 15, 19, 20, 21, 29, 31, 32, 33, 39, 40, 41, 50, 51, 55, 56, 65, 66, 90, 99),lab_rna)
badcodes(rna_d_a,c("<",">","D","M","Y","U"),lab_rna)

## QUERY PATIENTS WITH NO RECORD IN tblBAS
badrecord(patient,lab_rna,basic)

################### QUERY CHECKING ENDS HERE ###################





