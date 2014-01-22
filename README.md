# CCASAnet-DTP QA Checks

Please see the [downloads](https://github.com/CCASAnet/qa-checks-r/downloads) section for documentation of the exceptions that are currently implemented. 

The major directions for running these scripts:

1. Click on the cloud button with the words `Download ZIP` to download a zip archive of the most current version of the scripts.  Alternatively, you can clone this repository if you are familiar with Git and GitHub.
2. Extract the downloaded files to your desired location.
3. Following extraction, place the tables that correspond to the CCASAnet Data Transfer Protocol (`basic.csv` `lab_cd4.csv`, `lab_rna.csv`, `art.csv`, `follow.csv`, `visit.csv`) as csv files in the `input` folder.  
4. Download and install [R](http://www.r-project.org).
5. Download and install [RStudio](http://www.rstudio.com).
6. Open RStudio and install the `latticeExtra` and `brew` packages ( _Tools -> Install Packages -> Type case-sensitive package name -> Install_ ). 
7. Open `tbl_checks.R` with RStudio.
8. In the `tbl_checks.R` program, revise `databaseclose <- "2014-01-15"` to the database closure date (_Using the yyyy-mm-dd convention_).  This date is necessary for querying dates which occur in the future.
9. In RStudio, change working directory to source of files/data ( _Session -> Set Working Directory -> To Source File Location_ ).
10. Click on `Source` or `CTRL+SHIFT+S`. This will traverse all the csv files in the `input` directory and capture every exception (error) that these scripts look for.
11. If successful, a very large file with a table that includes all the exceptions will also be created in the `output` folder.
12. To generate a summary report of all the exceptions that were captured in that file, you will need to open the file `summarize_exceptions.R` and also source it.
13. If successful, a few other files will be created in the `output` directory. The html file `output/summary_report.html` and `output/patient_report.html` will give you nice views that you can read in your browser.
