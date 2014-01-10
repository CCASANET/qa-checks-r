#############################################################
#
#   Program: summarize_counts.R
#   Project: IeDEA
# 
#   Biostatistician/Programmer: Meridith Blevins, MS
#   Purpose: Get record and patient counts for each data tables
#            for inclusion in summary reports
#
#   INPUT: "tbl_XXX.csv"
#   OUTPUT: "counts_yyyymmdd.csv"
#
#   Notes: As long as the working directory structure 
#          matches README.md, such that the data tables,
#          R-code, and resources may be sourced, 
#          then this code should run smoothly, generating
#          a listing of data queries in /output.
#
#   Created: 25 January 2013
#   Revisions: 
#     
#############################################################
## USER -- PLEASE REVISE or CHANGE THE APPROPRIATE WORKING DIRECTORY AND SET THE APPROPRIATE DATABASE CLOSE DATE
#setwd("/home/blevinml/Projects/IeDEAS/qa-checks-r")
#setwd("C:/Documents and Settings/blevinml/My Documents/Projects/IeDEAS/qa-checks-r")

## IDENTIFY WHICH TABLES TO EXPECT FROM DES
expectedtables <- c("basic","follow","lab_cd4","lab_rna","art","visit")
expecteddestables <- c("tblBASIC","tblFOLLOW","tblLAB_CD4","tblLAB_RNA","tblART","tblVISIT")

## CHOOSE FIRST SELECTS THE TEXT STRING OCCURING BEFORE THE SPECIFIED SEPARATER
choosefirst <- function(var,sep=".") unlist(lapply(strsplit(var,sep,fixed=TRUE),function(x) x[1]))

## DETERMINE WHICH TABLES EXIST IN '/input'
existingtables <- choosefirst(list.files("input"))
existingtables <- existingtables[match(expectedtables,existingtables)]
existingtables <- existingtables[!is.na(existingtables)]
readtables <- expectedtables[match(existingtables,expectedtables)]


## READ IN ALL EXISTING TABLES
for(i in 1:length(readtables)){
  if(!is.na(readtables[i])){
    readcsv <- read.csv(paste("input/",existingtables[i],".csv",sep=""),header=TRUE,stringsAsFactors = FALSE,na.strings=c(NA,""))
    names(readcsv) <- tolower(names(readcsv))
    assign(readtables[i],readcsv)
  }
}

if(exists("basic")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  basic$patient <- paste(basic$patient,basic$site,sep="-")
}
if(exists("follow")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  follow$patient <- paste(follow$patient,follow$site,sep="-")
}
if(exists("lab_cd4")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  lab_cd4$patient <- paste(lab_cd4$patient,lab_cd4$site,sep="-")
}
if(exists("lab_rna")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  lab_rna$patient <- paste(lab_rna$patient,lab_rna$site,sep="-")
}
if(exists("art")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  art$patient <- paste(art$patient,art$site,sep="-")
}
if(exists("visit")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  visit$patient <- paste(visit$patient,visit$site,sep="-")
}

getrecordcounts <- function(table,unique_id="patient",subset=basic$patient){
  x1 <- nrow(get(table)[get(unique_id,get(table)) %in% subset,])
  x2 <- length(unique(get(unique_id,get(table))[get(unique_id,get(table)) %in% subset]))
  return(c(table,x1,x2))
  }




recordcounts <- t(sapply(readtables,getrecordcounts))
recordcounts <- data.frame(expecteddestables[match(existingtables,expectedtables)],recordcounts[,2:3],row.names=NULL)
names(recordcounts) <- c("tbl","records","patients")

## WRITE COUNT FILE -- CREATE OUTPUT DIRECTORY (IF NEEDED)
wd <- getwd(); if(!file.exists("output")){dir.create(file.path(wd,"output"))}
write.csv(recordcounts,paste("output/counts_",format(Sys.Date(),"%Y%m%d"),".csv",sep=""),row.names=FALSE)


