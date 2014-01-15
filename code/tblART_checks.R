#############################################################
#
#   Program: tblART_checks.R
#   Project: CCASAnet
# 
#   PI: Firas Wehbe, PhD
#   Biostatistician/Programmer: Meridith Blevins, MS
#   Purpose: Read in CCASAnet standard data and write  
#            data queries
#
#   INPUT: "tblART.csv"
#   OUTPUT: 
#
#   Notes: As long as the working directory in "setwd" is
#          correctly pointing to the location of tblART.csv,
#          then this code should run smoothly, generating
#          a listing of data queries.
#
#   Created: January 2 2013
#   Revisions: 
#     
#############################################################
## NAME OF TABLE FOR WRITING QUERIES
tablename <- "tblART"
## READ TABLE
## NAMES EXPECTED FROM CCASAnet
expectednames <- c("patient","art_id","art_sd","art_ed","art_rs_start","art_rs_start_oth","art_rs_stop","art_rs_stop_oth",
                   "art_do","art_fr")
acceptablenames <- c(expectednames,"art_sd_a","art_ed_a","site")

################### QUERY CHECKING BEGINS HERE ###################

## CHECK FOR EXTRA OR MISSING VARIABLES
extravar(acceptablenames,art)
missvar(expectednames,art)

## PRIOR TO CONVERTING DATES, CHECK THAT THE TYPE IS APPROPRIATE 
notdate(art_sd,art)
notdate(art_ed,art)

## CHECK FOR MISSING DATA
missingvalue(art_id,art)
missingvalue(art_sd,art)

## CONVERT DATES USING EXPECTED FORMAT (will force NA if format is incorrect)
if(exists("art_sd",art)){art$art_sd <- convertdate(art_sd,art)}
if(exists("art_ed",art)){art$art_ed <- convertdate(art_ed,art)}

## CHECK FOR DATES OCCURRING IN THE WRONG ORDER
if(exists("basic")){
	basart <- merge(art,with(basic,data.frame(patient,birth_d)),all.x=TRUE)
	basart$birth_d <- convertdate(birth_d,basart)
	outoforder(birth_d,art_sd,basart,table2="tblBASIC")
	outoforder(birth_d,art_ed,basart,table2="tblBASIC")
}
if(exists("follow")){
        followart <- merge(art,with(follow,data.frame(patient,death_d)),all.x=TRUE)
	followart$death_d <- convertdate(death_d,followart)
	outoforder(art_sd,death_d,followart,table2="tblFOLLOW")
	outoforder(art_ed,death_d,followart,table2="tblFOLLOW")
}

## CHECK FOR DATES OCCURRING IN THE WRONG ORDER
outoforder(art_sd,art_ed,art)

## CHECK FOR DATES OCCURRING TOO FAR IN THE FUTURE
futuredate(art_sd,art)
futuredate(art_ed,art)

## CHECK FOR DUPLICATE PATIENT IDs 
for(i in unique(art$art_id)[!is.na(unique(art$art_id))]){
  art_sub <- art[art$id %in% i,]
  queryduplicates(patient,art_sub,date=art_sd,subsettext=paste("&art_id=",i,sep=""))
}

## CHECK FOR INCORRECT VARIABLE TYPE (prior to range checks, if applicable)
notnumeric(art_rs_stop,art)
notnumeric(art_rs_start,art)
notnumeric(art_do,art)
notnumeric(art_fr,art)

## CONVERT TO NUMERIC OR FORCE MISSING FOR NON-NUMERIC
if(exists("art_do",art)){art$art_do <- forcenumber(art$art_do)}
if(exists("art_fr",art)){art$art_fr <- forcenumber(art$art_fr)}

## RANGE CHECKS
lowerrangecheck(art_do,0,art)
lowerrangecheck(art_fr,0,art)  

## CHECK FOR UNEXPECTED CODING
art_id_codebook <- read.csv("resource/art_id_codebook.csv",header=TRUE,stringsAsFactors = FALSE,na.strings="")
art_rs_codebook <- read.csv("resource/art_rs_codebook.csv",header=TRUE,stringsAsFactors = FALSE,na.strings="")
badcodes(art_id,art_id_codebook$code,art)
badcodes(art_rs_stop,art_rs_codebook$code,art)
badcodes(art_rs_start,art_rs_codebook$code,art)
badcodes(art_sd_a,c("<",">","D","M","Y","U"),art)
badcodes(art_ed_a,c("<",">","D","M","Y","U"),art)


## TRANSPOSE ART STRINGS TO BE 1 DRUG PER ROW
id.list <- strsplit(art$art_id, ',', fixed=TRUE)
art$rec_id <- seq_len(nrow(art))
art_ids <- data.frame(rec_id=rep(art$rec_id, times=vapply(id.list, FUN=length, FUN.VALUE=integer(1))),
                      art_id=unlist(id.list))
art$art_id <- NULL
newart <- merge(art_ids, art, by='rec_id', all=TRUE)
newart <- newart[order(newart$patient,newart$art_sd,newart$art_ed),]

## QUERY SAME ART_ID WITH OVERLAPPING INTERVALS -- GAPS ARE NOT ERRORS SO DON'T QUERY
query <- emptyquery
for(i in unique(newart$art_id)){
  data <- newart[newart$art_id==i,]
  for(j in unique(data$patient)){
     pdata <- data[data$patient==j,]
     if(nrow(pdata) > 1){
        for(k in 2:nrow(pdata)){
           if(pdata$art_ed[k] < pdata$art_sd[k-1] & !is.na(pdata$art_ed[k]) & !is.na(pdata$art_sd[k-1])){
              query <- rbind(query,data.frame(PID=pdata$patient[k],Table=tablename,Variable="art_ed&art_sd",
                                              Error="Logic",Query="Overlapping Interval",Info=paste0("art_ed=",pdata$art_ed[k],"&","art_sd=",pdata$art_ed[k-1])))
              }
          }
       }
    }
 }
assign(paste("query",index,sep=""),query,envir=globalenv())
index <<- index + 1




# ## NEED TO PROGRAM:
# Double reporting - records reported for both combination drugs and their components
# Periods of overlap of contra-indicated drugs


################### QUERY CHECKING ENDS HERE ###################



