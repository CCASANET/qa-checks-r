#############################################################
#
#   Program: tblVIS_checks.R
#   Project: IeDEA
# 
#   PI: Firas Wehbe, PhD
#   Biostatistician/Programmer: Meridith Blevins, MS
#   Purpose: Read in IeDEAS standard and write  
#            data queries
#
#   INPUT: "tblVIS.csv"
#   OUTPUT: 
#
#   Notes: As long as the working directory in "setwd" is
#          correctly pointing to the location of tblVIS.csv,
#          then this code should run smoothly, generating
#          a listing of data queries.
#
#   Created: 16 January 2013
#   Revisions: 
#     
#############################################################

## NAME OF TABLE FOR WRITING QUERIES
tablename <- "tblVISIT"
## NAMES EXPECTED FROM HICDEP+/IeDEAS DES
expectednames <- c("patient","visit_d","location","weight","height","cdcstage","whostage")
acceptablenames <- c(expectednames,"visit_d_a","weight_u","height_u","site","disclosure_status")

################### QUERY CHECKING BEGINS HERE ###################

## CHECK FOR EXTRA OR MISSING VARIABLES
extravar(acceptablenames,visit)
missvar(expectednames,visit)

## PRIOR TO CONVERTING DATES, CHECK THAT THE TYPE IS APPROPRIATE 
notdate(visit_d,visit)

## CHECK FOR MISSING DATA
missingvalue(center,visit)
missingvalue(visit_d,visit)
# it's okay for others to be missing 

## CONVERT DATES USING EXPECTED FORMAT (will force NA if format is incorrect)
if(exists("visit_d",visit)){visit$visit_d <- convertdate(visit_d,visit)}

## CHECK FOR DATES OCCURRING IN THE WRONG ORDER
if(exists("basic")){
	basvisit <- merge(visit,with(basic,data.frame(patient,birth_d)),all.x=TRUE)
	basvisit$birth_d <- convertdate(birth_d,visit)
	outoforder(birth_d,visit_d,basvisit,table2="tblBASIC")
}
if(exists("follow")){
        followvisit <- merge(visit,with(follow,data.frame(patient,death_d)),all.x=TRUE)
	followvisit$death_d <- convertdate(death_d,visit)
	outoforder(visit_d,death_d,followvisit,table2="tblFOLLOW")
}

## CHECK FOR DATES OCCURRING TOO FAR IN THE FUTURE
futuredate(visit_d,visit)

## CHECK FOR INCORRECT VARIABLE TYPE (prior to range checks)
notnumeric(height,visit)
notnumeric(weight,visit)

## CONVERT TO NUMERIC OR FORCE MISSING FOR NON-NUMERIC
if(exists("height",visit)){visit$height <- forcenumber(visit$height)}
if(exists("weight",visit)){visit$weight <- forcenumber(visit$weight)}
#if(exists("whostage",visit)){visit$whostage <- forcenumber(visit$whostage)}

## FORCE MISSING VALUES AS NA FOR RANGE CHECKS
if(exists("weight",visit)){visit$weight[visit$weight==999] <- NA}
if(exists("height",visit)){visit$height[visit$height==999] <- NA}

## CHECK FOR DUPLICATE PATIENT IDs + RANGE CHECKS
queryduplicates(patient,visit,date=visit_d)
upperrangecheck(weight,120,visit)
lowerrangecheck(weight,0,visit) # consider specifying lower limit for adult population
upperrangecheck(height,220,visit)
lowerrangecheck(height,0,visit) # consider specifying lower limit for adult population

## CHECK FOR UNEXPECTED CODING
badcodes(who_stage,c(1:4,9),visit)
badcodes(cdc_stage,c("A","A1","A2","A3","B","B1","B2","B3","C","C1","C2","C3","9"),visit)
badcodes(visit_d_a,c("<",">","D","M","Y","U"),visit)
badcodes(disclosure_status,c("no","ongoing","yes"),visit)

## QUERY PATIENTS WITH NO RECORD IN tblBAS (bad ID)
badrecord(patient,visit,basic)

## QUERY PATIENTS WITH MISSING RECORD IN tblVIS (has ID, but no VISIT data)
#missrecord(patient,basic,visit)

## QUERY ANY HEIGHT DECREASES FROM ONE VISIT TO THE NEXT
if(exists("height",visit)){
    qheight <- visit[with(visit,order(patient,visit_d)),]
    qheight <- qheight[!is.na(qheight$height),]
    qheight$heightdelta <- with(qheight,unsplit(lapply(split(height, patient), FUN=function(x) c(NA, diff(x))), patient))
    recerr <- which(!is.na(qheight$heightdelta) & qheight$heightdelta < 0)
    if(length(recerr)>0){
	query <- data.frame(qheight$patient[recerr],
		tablename,
		"height",
		"Logic",
		"Out of Range",
		paste(paste0("visit_d=",qheight$visit_d[recerr-1]),paste0("height=",qheight$height[recerr-1]),
		      paste0("visit_d=",qheight$visit_d[recerr]),  paste0("height=",qheight$height[recerr]),sep="&"),
		stringsAsFactors=FALSE)
	names(query) <- names(emptyquery)
	assign(paste("query",index,sep=""),query,envir=globalenv()); index <<- index + 1
    }
}
################### QUERY CHECKING ENDS HERE ###################


## QUERY CHECKS TO CODE ##
# pediatric ranges
