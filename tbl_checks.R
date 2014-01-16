#############################################################
#
# Program: tbl_checks.R
# Project: CCASAnet
#
# Biostatistician/Programmer: Meridith Blevins, MS
# Purpose: Read in CCASAnet dtp and write
# data queries
#
# INPUT: "tblXXX.csv", "tblXXX_checks.R"
# OUTPUT: "tbl_query_yyyymmdd.csv"
#
# Notes: As long as the working directory structure
# matches README.md, such that the data tables,
# R-code, and resources may be sourced,
# then this code should run smoothly, generating
# a listing of data queries in /output.
#
# Created: 16 December 2013
# Revisions:
#
#############################################################
rm(list=ls()) # clear namespace

## USER -- PLEASE REVISE or CHANGE THE APPROPRIATE WORKING DIRECTORY AND SET THE APPROPRIATE DATABASE CLOSE DATE
#setwd("/home/blevinml/Projects/CCASAnet/qa-checks-r")

## IN ORDER TO ASSESS DATES OCCURRING IN THE FUTURE, WE NEED A DATABASE CLOSE DATE (YYYY-MM-DD)
databaseclose <- "2014-01-15"

## READ QUERY_FUNCTIONS.R
source("code/query_functions.R")
## INDEX NUMBER FOR QUERY FILES
index <- 1
## EMPTY MATRIX FOR ALL QUERIES and ALL CHECKS
emptyquery <- data.frame(PID=character(),Table=character(),Variable=character(),Error=character(),Query=character(),Info=character())
allcheck <- NULL
## CONVERT DATABASE CLOSE TO DATE FORMAT, IF MISSING/INCORRECT, THEN USE SYSTEM DATE (TODAY)
databaseclose <- as.Date(databaseclose,"%Y-%m-%d")
databaseclose <- ifelse(is.na(databaseclose),Sys.Date(),databaseclose)

## IDENTIFY WHICH TABLES TO EXPECT FROM DES
expectedtables <- c("basic","follow","lab_cd4","lab_rna","art","visit")
expecteddestables <- c("tblBASIC","tblFOLLOW","tblLAB_CD4","tblLAB_RNA","tblART","tblVISIT")
## CHOOSE FIRST SELECTS THE TEXT STRING OCCURING BEFORE THE SPECIFIED SEPARATER
choosefirst <- function(var,sep=".") unlist(lapply(strsplit(var,sep,fixed=TRUE),function(x) x[1]))
## DETERMINE WHICH TABLES EXIST IN '/input'
existingtables <- choosefirst(list.files("input"))
readtables <- expectedtables[match(existingtables,expectedtables)]
## READ IN ALL EXISTING TABLES
for(i in 1:length(readtables)){
  if(!is.na(readtables[i])){
     readcsv <- read.csv(paste("input/",existingtables[i],".csv",sep=""),header=TRUE,stringsAsFactors = FALSE,na.strings=c(NA,""))
     names(readcsv) <- tolower(names(readcsv))
     assign(readtables[i],readcsv)
   }
}
if(length(sort(readtables))==0){
  stop("ERROR: No tables were read from /input.  Please check that files exist and match naming convention (basic.csv lab_cd4.csv, lab_rna.csv, art.csv, follow.csv, visit.csv)")
}

################### QUERY CHECK PROGRAMS BEGIN HERE #################

if(exists("basic")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  basic$patient <- paste(basic$patient,basic$site,sep="-")
  source("code/tblBASIC_checks.R")
}
if(exists("follow")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  follow$patient <- paste(follow$patient,follow$site,sep="-")
  source("code/tblFOLLOW_checks.R")
}
if(exists("lab_cd4")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  lab_cd4$patient <- paste(lab_cd4$patient,lab_cd4$site,sep="-")
  source("code/tblLAB_CD4_checks.R")
}
if(exists("lab_rna")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  lab_rna$patient <- paste(lab_rna$patient,lab_rna$site,sep="-")
  source("code/tblLAB_RNA_checks.R")
}
if(exists("art")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  art$patient <- paste(art$patient,art$site,sep="-")
  source("code/tblART_checks.R")
}
if(exists("visit")){
  ## UNIQUE TO CCASAnet -- CREATE UNIQUE IDs 
  visit$patient <- paste(visit$patient,visit$site,sep="-")
  source("code/tblVISIT_checks.R")
}

################### QUERY CHECK PROGRAMS END HERE ###################

## COMBINE ALL QUERY FILES
allquery <- do.call(rbind,lapply(paste("query",1:(index-1),sep=""),get))

## WRITE QUERY FILES
## REORDER QUERY FILE ACCORDING TO SPECS
allquery <- allquery[,c(4:5,2:3,1,6)]
## WRITE QUERY FILES -- CREATE OUTPUT DIRECTORY (IF NEEDED)
wd <- getwd(); if(!file.exists("output")){dir.create(file.path(wd,"output"))}
write.csv(allquery,paste("output/tbl_query_",format(Sys.Date(),"%Y%m%d"),".csv",sep=""),row.names=FALSE)
