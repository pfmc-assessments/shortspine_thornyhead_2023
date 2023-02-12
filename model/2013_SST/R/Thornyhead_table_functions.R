####################################################################################
#
# SS_tables
# This function comes with no warranty or guarantee of accuracy
#
# Purpose: 	To create the tables required for a stock assessment report based on SS3 model input/output files
# Written: 	Kotaro Ono, SAFS, UW
# Returns: 	tables in csv format saved in a "TABLES" folder within the working model folder
# To use: 	Copy and paste the csv file values into the assessment document with some edits if needed

# Versions:
#	V1: Produces individual tables
#       V2: modifications by Ian to work with Thornyheads

# Status of the table codes
# OK: works fine but could be improved too
# need work: need work
# great: works for most cases and only minor changes might be needed
# to do

# Table 1 OK
# Table 2 OK
# Table 3 OK
# Table 4 OK
# Table 5 OK
# Table 6 OK
# Table 7 need work
# Table 8 OK
# Table 9 OK
# Table 10 OK
# Table 11 OK
# Table 12 need work
# Table 13 OK
# Table 14 OK

####################################################################################

if(FALSE){ # stuff inside these section intended for pasting rather than sourcing
  library(r4ss)
  require(gdata)
  update_r4ss_files()

  ##### Specify directory where the model runs are
  dir_folder <- "c:/SS/Thornyheads/runs/"

  ##### Specify the model runs for which to get the tables for
  dir       <- file.path(dir_folder, "SST_23_devs_fixM_block_2yr_maturityNew_4cm")
  dir.table <- file.path(dir_folder, "SST_23_tables")
  dir.create(dir.table)

  dir       <- file.path(dir_folder, "LST_SS_2013_Jun27c_block_ret_noK_devs")
  dir.table <- file.path(dir_folder, "LST_SS_2013_Jun27c_tables")
  dir.create(dir.table)
  
  ##### creates some output data that will be used below
  SSoutputs <- SS_output(dir=paste(dir), model="ss3", covar=TRUE, forecast=TRUE)
  rawrep   <- read.table(file=file.path(dir, "Report.sso"),col.names=1:200,fill=TRUE,quote="", colClasses="character",nrows=-1,comment.char="")
  Datfile  <- readLines(con=file.path(dir, "data.ss_new"))
  Forecast <- readLines(con=file.path(dir, "forecast.ss_new"))
  CTLfile  <- readLines(con=file.path(dir, "control.ss_new"))

  ##### Do some plotting of the model outputs if wanted
  # asd <- SS_plots(SSoutputs, uncertainty=T)	# put uncertainty=F if you are not estimating the covariance matrix i.e using "-nohess"

  ##### Big wrapper function that is not implemented yet
  # SS_Tables <- function(dir="C:/myfiles/mymodels/myrun/", model="ss3",
  # repfile="Report.sso", datfile="petrale11.dat",
  # ncols=200, forecast=TRUE, warn=TRUE, covar=TRUE,
  # checkcor=TRUE, cormax=0.95, cormin=0.01, printhighcor=10, printlowcor=10,
  # verbose=TRUE, printstats=TRUE,hidewarn=FALSE, NoCompOK=FALSE,
  # aalmaxbinrange=4)
  # {

} # end stuff to be edited and pasted into R manually
# the next section with file definitions can be sourced into R with the rest of the file

#################################################################################
## embedded functions: emptytest, matchfun and matchfun2
#################################################################################

emptytest <- function(x){ sum(!is.na(x) & x=="")/length(x) }

matchfun2 <- function(string1,adjust1,string2,adjust2,cols="nonblank",matchcol1=1,matchcol2=1,
                      objmatch=rawrep,objsubset=rawrep,substr1=TRUE,substr2=TRUE,header=FALSE)
    {
      # return a subset of values from the report file (or other file)
      # subset is defined by character strings at the start and end, with integer
      # adjustments of the number of lines to above/below the two strings
      line1 <- match(string1,if(substr1){substring(objmatch[,matchcol1],1,nchar(string1))}else{objmatch[,matchcol1]})
      line2 <- match(string2,if(substr2){substring(objmatch[,matchcol2],1,nchar(string2))}else{objmatch[,matchcol2]})
      if(is.na(line1) | is.na(line2)) return("absent")

      if(is.numeric(cols))    out <- objsubset[(line1+adjust1):(line2+adjust2),cols]
      if(cols[1]=="all")      out <- objsubset[(line1+adjust1):(line2+adjust2),]
      if(cols[1]=="nonblank"){
        # returns only columns that contain at least one non-empty value
        out <- objsubset[(line1+adjust1):(line2+adjust2),]
        out <- out[,apply(out,2,emptytest) < 1]
      }
      if(header && nrow(out)>0){
        out[1,out[1,]==""] <- "NoName"
        names(out) <- out[1,]
        out <- out[-1,]
      }
      return(out)
    }


################################
### EXECUTIVE SUMMARY TABLES #####


### Recent catch table
# takes as input the user specified N last year of catch data to show
Table1 <- function(last_n_years=10, write.csv=TRUE)
    {
      # Extract catch data
      CATCH <- matchfun2("CATCH", 1, "TIME_SERIES", -1, header = TRUE)
      if (is.null(CATCH)) print("Issues in loading the CATCH data")
      # Extract fleet characteristics
      Fleet <- unique(CATCH$Fleet)
      # Create the catch history
      Catch_history <- tapply(as.numeric(CATCH$Obs), list(as.factor(CATCH$Name), as.factor(CATCH$Yr)), I)
      # format the recent catch table
      Table1 <- as.data.frame(t(Catch_history[,(ncol(Catch_history)-last_n_years):ncol(Catch_history)]))
      Table1$Total <- apply(Table1,1,sum)
      # write the output
      if(write.csv==TRUE)
          {
            write.csv(Table1, file=paste(dir.table, "/Recent catch.csv", sep=""))
          }
      return(Table1)
    }

### Recent SPB and depletion table
# takes as input the user specified years for which to obtain this table for
Table2 <- function(First_year=2001, Last_year=2013, write.csv=TRUE)
    {
      # extract SPB time series and derived quantitities
      Sp_series = SSoutputs$sprseries
      derived_quants <- SSoutputs$derived_quants
      stdtable <- derived_quants
      #
      to_skip <- unlist(gregexpr("_", stdtable$LABEL))+1
      stdtable$Yr <- as.numeric(substring(stdtable$LABEL, to_skip))
      stdtable$CI95 <- 1.96 * stdtable[,3]
      stdtable$upper <- stdtable[,2] + 1.96 * stdtable[,3]
      stdtable$lower <- pmax(stdtable[,2] - 1.96* stdtable[,3], 0)
      stdtable <- stdtable[-c(1,2),]
      # format the recent SPB and depletion table
      Table2a <- c();   Table2b <- c()
      # extract the SPB data and its 95% CI
      Table2a$Year <- stdtable$Yr[grep("SPB_", stdtable$LABEL)]
      Table2a$SPB <- ceiling(stdtable$Value[grep("SPB_", stdtable$LABEL)])
      #Table2a$SPB_95 <- ceiling(stdtable$CI9[grep("SPB_", stdtable$LABEL)])
      Table2a$CI_SPB <- paste(trunc(stdtable$lower[grep("SPB_", stdtable$LABEL)]), " - " , trunc(stdtable$upper[grep("SPB_", stdtable$LABEL)]), sep="")
      # extract the Depletion level and its 95% CI
      Table2b$Year <- stdtable$Yr[grep("Bratio_", stdtable$LABEL)]

      #Table2b$Depletion <- paste(round(100*stdtable$Value[grep("Bratio_", stdtable$LABEL)],digits=1), "%", sep="")
      #Table2b$Depletion_95 <- paste(round(100*stdtable$CI9[grep("Bratio_", stdtable$LABEL)],digits=1), "%", sep="")
      #Table2b$CI_Depletion <- paste(round(100*stdtable$lower[grep("Bratio_", stdtable$LABEL)],digits=1), "% - " , round(100*stdtable$upper[grep("Bratio_", stdtable$LABEL)],digits=1), "%", sep="")

      # trying to replace the lines above with the use of 'format'
      Table2b$Depletion <- paste(format(100*stdtable$Value[grep("Bratio_", stdtable$LABEL)],digits=1,nsmall=1), "%", sep="")
      Table2b$CI_Depletion <- paste(format(100*stdtable$lower[grep("Bratio_", stdtable$LABEL)],digits=1,nsmall=1), "% -" , format(100*stdtable$upper[grep("Bratio_", stdtable$LABEL)],digits=1,nsmall=1), "%", sep="")

      # make them a data frame
      Table2a <- as.data.frame(Table2a)
      Table2b <- as.data.frame(Table2b)
      # keep only the specified last years
      Table2 <- cbind(Table2a[which(Table2a$Year>=First_year & Table2a$Year<=Last_year),],Table2b[which(Table2b$Year>=First_year & Table2b$Year<=Last_year),-1])
      # re-assign colomns names or change later from CSV file
      colnames(Table2) <- c("Fishing year", "Spawning biomass (mt)", "~95% confidence interval", "Estimated depletion", "~95% confidence interval")
      # write the table
      if(write.csv==TRUE)
          {
            write.csv(Table2, file=paste(dir.table, "/Recent trend SPB and depletion.csv", sep=""))
          }
      return(Table2)
    }

### Recent recruitment table
# takes as input the user specified years for which to obtain this table for
# and the unit definition of the recruitment
Table3 <- function(First_year=2001, Last_year=2013, Rec_unit="(1000s)", write.csv=TRUE)
    {
      Table3 <- c()
      # extract recruitment time series
      derived_quants <- SSoutputs$derived_quants
      stdtable <- derived_quants
      stdtable <- derived_quants[substring(derived_quants$LABEL, 1, 5) == "Recr_", ]
      stdtable <- stdtable[stdtable$LABEL != "Recr_Unfished", ]
      stdtable$Yr <- substring(stdtable$LABEL, 6)
      stdtable$Yr[1:2] <- as.numeric(stdtable$Yr[3]) -  (2:1)
      stdtable$Yr <- as.numeric(stdtable$Yr)
      stdtable = subset(stdtable, subset=c(Yr>=First_year & Yr<=Last_year))
      bioscale <- 1
      v <- stdtable$Value * 1
      std <- stdtable$StdDev * 1
      stdtable$logint <- sqrt(log(1 + (std/v)^2))
      stdtable$lower <- exp(log(v) - 1.96 * stdtable$logint)
      stdtable$upper <- exp(log(v) + 1.96 * stdtable$logint)
      # format table
      Table3$Yr <- stdtable$Yr
      Table3$Recruit <- stdtable$Value
      #Table3$CI95 <- ceiling(stdtable$upper - stdtable$lower)
      Table3$CI_recruit <- paste(ceiling(stdtable$lower), " - " , ceiling(stdtable$upper), sep="")
      Table3 <- as.data.frame(Table3)
      # reassign columns names
      colnames(Table3) <- c("Fishing year", paste("Estimated recruitment", Rec_unit, sep=""), "+-~95% confidence interval")#, "Range of states of nature")
      # write the table
      if(write.csv==TRUE)
          {
            write.csv(Table3, file=paste(dir.table, "/Recent trend in recruitment.csv", sep=""))
          }
      return(Table3)
    }

### Recent catch and landings
# takes as input the user specified years for which to obtain this table for
Table4 <- function(First_year=2001, Last_year=2013, write.csv=TRUE)
    {
      Table4 <- c()
      # extract catch and biom time series
      Sp_series = SSoutputs$timeseries
      # extract expected catch
      landed=grep("obs_cat", colnames(Sp_series), fixed=TRUE)
      caught=grep("dead(B)", colnames(Sp_series), fixed=TRUE)
      Table4$Yr = Sp_series$Yr
      Table4$OFL = NA
      Table4$ACL = NA
      Table4$Landings = as.numeric(apply(Sp_series[landed],1,sum))
      Table4$Tot_catch = as.numeric(apply(Sp_series[caught],1,sum))
      Table4$Catch_fishing = NA
      Table4 <- as.data.frame(Table4)
      Table4 <- subset(Table4, subset=c(Yr>=First_year & Yr<=Last_year))
      # reassign columns names
      colnames(Table4) <- c("Year", "OFL (mt)", "ACL (mt)", "Commercial landings calendar year (mt)", "Estimated catch calendar year (mt)", "Estimated catch fishing year (mt)")
      # write the table
      if(write.csv==TRUE)
          {
            write.csv(Table4, file=paste(dir.table, "/Recent trend in estimated catch.csv", sep=""))
          }
      return(Table4)
    }

### Time series of discard
# takes as input the user specified years for which to obtain this table for
Table4b <- function(First_year.input=1876, Last_year.input=2012, default.input=TRUE, write.csv=TRUE)
    {
      Table4a <- c(); Table4b <- c(); Table4c = c()
      if(default.input == TRUE)
          {
            First_year = Datfile[grep("#_styr", Datfile, fixed=TRUE)]
            First_year = as.numeric(strsplit(First_year, split=" ")[[1]][1])
            Last_year = Datfile[grep("#_endyr", Datfile, fixed=TRUE)]
            Last_year = as.numeric(strsplit(Last_year, split=" ")[[1]][1])
          }
      if(default.input == FALSE)
          {
            First_year = First_year.input
            Last_year = Last_year.input
          }
      # extract catch and biom time series
      Sp_series = SSoutputs$timeseries
      N_fleet = Datfile[grep("#_Nfleet", Datfile, fixed=TRUE)]; N_fleet = as.numeric(strsplit(N_fleet, split=" ")[[1]][1])
      # extract expected catch
      Table4a = Sp_series$Yr
      Table4b = Sp_series$Yr
      Table4c = Sp_series$Yr

      for (i in 1:N_fleet)
          {
            landed=as.numeric(unlist(Sp_series[grep(paste0("retain(B):_", i), colnames(Sp_series), fixed=TRUE)]))
            caught=as.numeric(unlist(Sp_series[grep(paste0("dead(B):_",i), colnames(Sp_series), fixed=TRUE)]))
            discard=caught-landed
            discard_rate = discard/caught
            Table4a = cbind(Table4a, caught)
            Table4b = cbind(Table4b, discard)
            Table4c = cbind(Table4c, discard_rate)
          }
      # reassign columns names
      colnames(Table4a) <- c("Year", paste0("Discard_fleet", 1:N_fleet))
      colnames(Table4b) <- c("Year", paste0("Discard_fleet", 1:N_fleet))
      colnames(Table4c) <- c("Year", paste0("Discard_rate", 1:N_fleet))
      # make it a data.frame
      Table4a = as.data.frame(Table4a)
      Table4b = as.data.frame(Table4b)
      Table4c = as.data.frame(Table4c)
      # select only the data for the years we asked for
      Table4a <- subset(Table4a, subset=c(Year>=First_year & Year<=Last_year))
      Table4b <- subset(Table4b, subset=c(Year>=First_year & Year<=Last_year))
      Table4c <- subset(Table4c, subset=c(Year>=First_year & Year<=Last_year))
      # write the table
      if(write.csv==TRUE)
          {
            write.csv(Table4b, file=paste(dir.table, "/Fleet discard data.csv", sep=""))
          }
      # do the plotting
      windows()
      matplot(Table4a[,1], Table4a[,2:(N_fleet+1)], type="l", lwd=2, lty=1, col=1:N_fleet, ylab="Catch (t)", xlab="Years")
      legend("topleft", legend=paste("Fleet", seq(1,N_fleet)), col=1:N_fleet, lty=1, lwd=2, bty="n")
      windows()
      matplot(Table4b[,1], Table4b[,2:(N_fleet+1)], type="l", lwd=2, lty=1, col=1:N_fleet, ylab="Discard (t)", xlab="Years")
      legend("topleft", legend=paste("Fleet", seq(1,N_fleet)), col=1:N_fleet, lty=1, lwd=2, bty="n")
      windows()
      matplot(Table4c[,1], Table4c[,2:(N_fleet+1)], type="l", lwd=2, lty=1, col=1:N_fleet, ylab="Discard rate", xlab="Years")
      legend("topleft", legend=paste("Fleet", seq(1,N_fleet)), col=1:N_fleet, lty=1, lwd=2, bty="n")
      # return the data
      return(Table4b)
    }

### Recent trend in SPR and F
# takes as input the user specified years for which to obtain this table for
Table5 <- function(First_year=2001, Last_year=2013, write.csv=TRUE)
    {
      Table5 <- c()
      # extract recruitment time series
      derived_quants <- SSoutputs$derived_quants
      stdtable <- derived_quants
      to_skip <- unlist(gregexpr("_", stdtable$LABEL))+1
      stdtable$Yr <- substring(stdtable$LABEL, to_skip)
      stdtable$CI95 <- 1.96 * stdtable[,3]
      stdtable$upper <- stdtable[,2] + 1.96 * stdtable[,3]
      stdtable$lower <- pmax(stdtable[,2] - 1.96* stdtable[,3], 0)
      # format table
      Table5a <- c(); Table5b <- c();
      stdtable_a <- stdtable[grep("SPRratio_", stdtable$LABEL),]
      Table5a$Yr <- as.numeric(stdtable_a$Yr)
      #Table5a$SPR <- round(stdtable_a$Value, 2)
      Table5a$CI_SPR <- paste(round(stdtable_a$lower, 2), " - " , round(stdtable_a$upper, 2), sep="")
      stdtable_b <- stdtable[grep("F_", stdtable$LABEL),]
      Table5b$Yr <- as.numeric(stdtable_b$Yr)
      Table5b$F <- round(stdtable_b$Value,2)
      #Table5b$CI_F <- paste(round(stdtable_b$lower, 2), " - " , round(stdtable_b$upper, 2), sep="")
      # make them a data frame
      Table5a <- as.data.frame(Table5a)
      Table5b <- as.data.frame(Table5b)
      # keep only the specified last years
      Table5 <- cbind(Table5a[which(Table5a$Yr>=First_year & Table5a$Yr<=Last_year),], Table5b[which(Table5b$Yr>=First_year & Table5b$Yr<=Last_year),-1])
      # reassign columns names
      colnames(Table5) <- c("Year", "Estimated 1-SPR%", "F")# "Range of states of nature")
      # write the table
      if(write.csv==TRUE)
          {
            write.csv(Table5, file=paste(dir.table, "/Recent trend in SPR and F.csv", sep=""))
          }
      return(Table5)
    }

### Projection Catch and Biomass
# This function either takes the user specified input years for the projection years: First_year.input and Last_year.input
# or the default values based on the forecast file and data if default.input=TRUE
# returns and saves a csv file if write.csv=TRUE
Table6 <- function(First_year.input=2013, Last_year.input=2022, default.input=TRUE, write.csv=TRUE)
    {
      if(default.input == TRUE)
          {
            First_year = Datfile[grep("#_endyr", Datfile, fixed=TRUE)]
            First_year = as.numeric(strsplit(First_year, split=" ")[[1]][1])+1
            Last_year = Forecast[grep("# N forecast years", Forecast, fixed=TRUE)]
            Last_year = First_year+as.numeric(strsplit(Last_year, split=" ")[[1]][1])-1
          }
      if(default.input == FALSE)
          {
            First_year = First_year.input
            Last_year = Last_year.input
          }

      Table6 <- c()
      # extract catch and biom time series
      Sp_series = SSoutputs$timeseries
      derived_quants <- SSoutputs$derived_quants
      stdtable <- derived_quants
      to_skip <- unlist(gregexpr("_", stdtable$LABEL))+1
      stdtable$Yr <- substring(stdtable$LABEL, to_skip)
      # format table
      Table6a <- subset(stdtable, subset=c(Yr>=First_year & Yr<=Last_year))
      Table6b <- subset(Sp_series, subset=c(Yr>=First_year & Yr<=Last_year))
      Table6$Year <- as.numeric(Table6a[grep("OFLCatch_", Table6a$LABEL),]$Yr)
      Table6$OFL <- ceiling(Table6a[grep("OFLCatch_", Table6a$LABEL),]$Value)
      Table6$ACL <- ceiling(Table6a[grep("ForeCatch_", Table6a$LABEL),]$Value)
      Table6$Bio3 <- ceiling(Table6b$Bio_smry)
      Table6$SPB <- ceiling(Table6a[grep("SPB_", Table6a$LABEL),]$Value)
      Table6$Depletion <- round(Table6a[grep("Bratio_", Table6a$LABEL),]$Value, 2)
      # make them a data frame
      Table6 <- as.data.frame(Table6)
      # reassign columns names
      colnames(Table6) <- c("Year", "OFL (mt)", "ACL (mt)", "Age 2+ biomass (mt)", "Spawning biomass (mt)", "Depletion")
      # write the table
      if(write.csv==TRUE)
          {
            write.csv(Table6, file=paste(dir.table, "/Projection catch and biomass.csv", sep=""))
          }
      return(Table6)
    }


### Decision table	- INCOMPLETE
Table7 <- function(List.models.folder.to.compare, Param.to.compare=c("Bratio", "SPB"), First_year.input=2013, Last_year.input=2024, default.input=TRUE, getcovariance=FALSE, write.csv=TRUE)
    {
      if(default.input == TRUE)
          {
            First_year = Datfile[grep("#_endyr", Datfile, fixed=TRUE)]
            First_year = as.numeric(strsplit(First_year, split=" ")[[1]][1])+1
            Last_year = Forecast[grep("# N forecast years", Forecast, fixed=TRUE)]
            Last_year = First_year+as.numeric(strsplit(Last_year, split=" ")[[1]][1])-1
          }
      if(default.input == FALSE)
          {
            First_year = First_year.input
            Last_year = Last_year.input
          }
      models = SSgetouput(List.models.folder.to.compare, getcovar=getcovariance)
      SSsummary <- SSsummarize(biglist=models)
      Params=sapply(1:length(Param.to.compare), function(x) paste(Param.to.compare[x], First_year:Last_year, sep="_"))
      TABLE=c()
      for (i in 1:(Last_year-First_year))
          {
            asd = SStableComparisons(SSsummary, likenames=c("TOTAL_like"), names=Params[i,])
            qwe = as.matrix(t(asd))[-1,]
            new = as.numeric(unmatrix(qwe, byrow=TRUE))
            TABLE=rbind(TABLE,new)
          }
      # colnames(TABLE)=rep(
      rownames(TABLE)=First_year:Last_year
    }

### Summary reference points
# takes as input the value for the SPRMSYproxy
# needs depletion for 2013 and
Table8 <- function(SPRMSYproxy=0.5, SBtarg="40%", write.csv=TRUE)
    {
      # Note: the SPR and Btarget values could be made automatic based on info in the model
      
      Table8 <- c()
      Last_year = Datfile[grep("#_endyr", Datfile, fixed=TRUE)]
      Last_year = as.numeric(strsplit(Last_year, split=" ")[[1]][1])+1

      # extract reference points
      derived_quants <- SSoutputs$derived_quants
      Table8a <- derived_quants[c(grep("SSB_Unfished",derived_quants$LABEL, fixed=TRUE),grep("SmryBio_Unfished",derived_quants$LABEL, fixed=TRUE),grep("Recr_Unfished",derived_quants$LABEL, fixed=TRUE), grep(paste0("Bratio_", Last_year),derived_quants$LABEL, fixed=TRUE)),]
      Table8b <- derived_quants[c(grep("SSB_Btgt",derived_quants$LABEL, fixed=TRUE):grep("TotYield_Btgt",derived_quants$LABEL, fixed=TRUE)),]
      Table8c1 <- derived_quants[c(grep("SSB_SPRtgt",derived_quants$LABEL, fixed=TRUE)),]
      Table8c2 <- c(0,SPRMSYproxy,0)
      Table8c3 <- derived_quants[c(grep("Fstd_SPRtgt",derived_quants$LABEL, fixed=TRUE), grep("TotYield_SPRtg",derived_quants$LABEL, fixed=TRUE)),]
      Table8d <- derived_quants[c(grep("SSB_MSY",derived_quants$LABEL, fixed=TRUE):grep("TotYield_MSY",derived_quants$LABEL, fixed=TRUE)),]
      Table8 <- rbind(Table8a, rep(NA,3), Table8b, rep(NA,3), Table8c1, Table8c2, Table8c3, rep(NA,3), Table8d)
      Table8$CI95 <- 1.96 * Table8$StdDev
      Table8[-c(4,7,8,12,13,17,18),2:4] <- ceiling(Table8[-c(4,7,8,12,13,17,18),2:4])
      Table8[c(4,7,8,12,13,17,18),2:4] <- round(Table8[c(4,7,8,12,13,17,18),2:4],3)
      # format table
      Table8 <- as.data.frame(Table8[,-3])
      Table8$LABEL = c("Unfished Spawning biomass (SB0, mt)",
        "Unfished age 2+ biomass (mt)",
        "Unfished recruitment (R0, thousands)",
        paste("Depletion", Last_year),
        paste("Reference points based on SB",SBtarg,sep=""),
        paste("MSY Proxy spaning biomass (SB",SBtarg,")",sep=""),
        paste("SPR resulting in SB",SBtarg," (SPRSB",SBtarg,")",sep=""),
        paste("Exploitation rate resulting in SB",SBtarg,sep=""),
        paste("Yield with SPR",SPRMSYproxy," at SB",SBtarg," (mt)",sep=""),
        "Reference points based on SPR proxy for MSY",
        "Spawning stock biomass at SPR (SPRSPR) (mt)",
        "SPRMSY-proxy",
        "Exploitation rate corresponding to SPR",
        "Yield with SPRMSY-proxy at SBSPR (mt)",
        "Reference points based on estimated MSY values",
        "Spawning Stock Biomass at MSY (SBMSY) (mt)",
        "SPRMSY",
        "Exploitation Rate corresponding to SPRMSY",
        "MSY (mt)")
      colnames(Table8) = c("Quantity", "Estimate", "+-95% confidence interval")
      # write the table
      if(write.csv==TRUE)
          {
            write.csv(Table8, file=paste(dir.table, "/Summary Reference Points.csv", sep=""))
          }
      return(Table8)
    }

### Total catch observation
# takes as input the Season defition in the model
# and the area definition in the model
Table9 <- function(write.csv=TRUE, Seasons=c("Summer", "Winter"), Areas=NULL)
    {
      # override the Seasons input if it's present unnecessarily
      if(SSoutputs$nseasons==1) Seasons <- NULL
      # override the Areas input if it's present unnecessarily
      if(SSoutputs$nareas==1) Areas <- NULL
      
      error=0
      # Extract catch data
      CATCH <- matchfun2("CATCH", 1, "TIME_SERIES", -1, header = TRUE)
      if (is.null(CATCH)) print("Issues in loading the CATCH data")
      # Extract fleet characteristics
      Fleet <- unique(CATCH$Fleet)
      # Create the catch history
      Catch_history <- tapply(as.numeric(CATCH$Obs), list(as.factor(CATCH$Name), as.factor(CATCH$Yr)), I)
      # format the recent catch table
      Table9 <- as.data.frame(t(Catch_history))
      Table9$Year = rownames(Table9)
      # Formating
      Table9 = Table9[,c(ncol(Table9), 1:(ncol(Table9)-1))]
      # Do some conditional sum for a specific season or area
      # for season
      seas.division <- list()
      if(length(Seasons)>0)
          {
            for (iii in 1:length(Seasons))
                {
                  new.div=grep(Seasons[iii], colnames(Table9), fixed=TRUE)
                  if(length(new.div)==0) {print("The spelling of the 'seasons' categories is not right. Please refer to the .dat file and correct it"); error=1}
                  seas.division[[iii]]=new.div
                  if(length(new.div)>0)
                      {
                        val=apply(Table9[,seas.division[[iii]]],1,sum)
                        Table9 = cbind(Table9, val)
                      }
                }
          }
      # for areas
      area.division <- list()
      if(length(Areas)>0)
          {
            for (iii in 1:length(Areas))
                {
                  new.div=grep(Areas[iii], colnames(Table9), fixed=TRUE)
                  if(length(new.div)==0) { print("The spelling of the 'Areas' categories is not right. Please refer to the .dat file and correct it"); error=1}
                  area.division[[iii]]=new.div
                  if(length(new.div)>0)
                      {
                        val=apply(Table9[,area.division[[iii]]],1,sum)
                        Table9 = cbind(Table9, val)
                      }
                }
          }
      # Final formatting
      colnames(Table9) = c("Year", rownames(Catch_history), Seasons, Areas)
      # write the output
      if(write.csv==TRUE)
          {
            write.csv(Table9, file=paste(dir.table, "/Landings history.csv", sep=""))
          }
      if(error>0) print("WARNINGS! there was at least one error while creating this table")
      return(Table9)
    }

### Length composition sample sizes
# specify as an input how gender is modeled one of: "All", "Male", "Female"
Table10 <- function(write.csv=TRUE, Gender="All")
    {
      starting= grep("_N_Length_obs", Datfile)
      ending= grep("_N_age_bins", Datfile)
      colnam = c(strsplit(Datfile[(starting+1)],' ')[[1]][1:6], rep(strsplit(Datfile[(starting-1)],' ')[[1]][-1],2))
      N = length(strsplit(Datfile[(starting+2)],' ')[[1]])-1
      Fleetname=strsplit(Datfile[(1+grep("_N_areas", Datfile))],'%')[[1]]
      Lengthdata <- c()
      for (i in (starting+2):(ending-1))
          {
            Lengthdata.new = as.numeric(strsplit(Datfile[i],' ')[[1]][-1])
            Lengthdata=rbind(Lengthdata, Lengthdata.new)
          }
      Lengthdata = as.data.frame(Lengthdata)
      colnames(Lengthdata)=colnam
      rownames(Lengthdata)=seq(1:nrow(Lengthdata))

      if(Gender=="All")
          {
            NSampbyfleet = tapply(Lengthdata$"Nsamp", list(factor(Lengthdata$"#Yr", levels=seq(min(Lengthdata$"#Yr"), max(Lengthdata$"#Yr"))), Lengthdata$"Flt/Svy"), sum)
          }

      ## Gender option not implemented
      # if(Gender=="Male")
      # {
      # NSampbyfleet = tapply(Lengthdata$"Nsamp", list(factor(Lengthdata$"#Yr", levels=seq(min(Lengthdata$"#Yr"), max(Lengthdata$"#Yr"))), Lengthdata$"Flt/Svy"), sum)
      # }

      colnames(NSampbyfleet)=Fleetname

      # write the output
      if(write.csv==TRUE)
          {
            write.csv(NSampbyfleet, file=paste(dir.table, "/Length comp samples.csv", sep=""))
          }

      return(Table10)

    }

### Growth parameter estimate
# this function spits out the growth param estimate of the female and male (and takes into account the different offset approach used)
# it supposedly takes into account whether the model is single sex or bisex
Table11 <- function(param=c("NatM", "L_at_Amin", "L_at_Amax", "VonBert_K", "CV_young", "CV_old"), write.csv=TRUE)
    {
      Params <- SSoutputs$parameters
      nums=c()
      for (i in 1:length(param))
          {
            nums.new = grep(param[i], Params$Label)
            nums=c(nums, nums.new)
          }
      Table11=Params[nums[order(nums)],2:3]

      if(nrow(Table11)>6)
          {
            N=(nrow(Table11)/2)
            Param_offset_approach_loc = grep("_parameter_offset_approach", CTLfile, fixed=TRUE)
            Param_offset_approach = as.numeric(strsplit(CTLfile[Param_offset_approach_loc], " ")[[1]][[1]])
            if (Param_offset_approach == 1) { Table11 = Table11 }
            if (Param_offset_approach == 2) { Male = Table11[1:N,2]*exp(Table11[(N+1):(2*N),2]); Table11[(N+1):(2*N),2]=Male }
            if (Param_offset_approach == 3) { Table11[(N+c(1,N)),2] = Table11[c(1,N),2]*exp(Table11[(N+c(1,N)),2]) }
          }
      # write the output
      if(write.csv==TRUE)
          {
            write.csv(Table11, file=paste(dir.table, "/Growth parameters.csv", sep=""))
          }

      return(Table11)
    }

### Description of the model parameters in the base-case assessment model
# this gives a table with a lot of estimated parameters from the model
Table12 <- function(write.csv=TRUE)
    {
      Table12 <- c()
      Columns = c(2, 3, 6, 7, 11, 12, 13)
      Params <- SSoutputs$parameters
      # Growth parameters
      Table12 = c("MG parameters", rep(NA,6))
      GP = grep("GP", Params[,2], fixed=TRUE)
      Table12 = rbind(Table12, Params[GP[-length(GP)], Columns])
      # SR params
      Table12 = rbind(Table12, c("Stock recruitment", rep(NA,6)))
      lnR0 = grep("SR_LN(R0)", Params[,2], fixed=TRUE)
      h = grep("SR_BH_steep", Params[,2], fixed=TRUE)
      sigmaR = grep("SR_sigmaR", Params[,2], fixed=TRUE)
      Table12 = rbind(Table12, Params[c(lnR0, h, sigmaR), Columns])
      # Indices
      Table12 = rbind(Table12, c("Indices", rep(NA,6)))
      Q = grep("Q", Params[,2], fixed=TRUE)
      Table12 = rbind(Table12, Params[Q, Columns])
      # Selectivity
      Table12 = rbind(Table12, c("Selectivity/Retention", rep(NA,6)))
      Fleet = SSoutputs$FleetNames
      for (i in Fleet)
          {
            fleet = grep(i, Params[,2], fixed=TRUE)
            Table12 = rbind(Table12, Params[fleet, Columns])
          }
      # write the output
      if(write.csv==TRUE)
          {
            write.csv(Table12, file=paste(dir.table, "/Model parameters.csv", sep=""))
          }
    }

### Time series of population estimate from the base case
# the user either inputs the initial and last year for which to get the population param estimate or uses the default (takes these values from the dat file)
Table13 <- function(First_year.input=1886, Last_year.input=2012, default.input=TRUE, write.csv=TRUE)
    {
      if(default.input == TRUE)
          {
            First_year = Datfile[grep("#_styr", Datfile, fixed=TRUE)]
            First_year = as.numeric(strsplit(First_year, split=" ")[[1]][1])
            Last_year = Datfile[grep("#_endyr", Datfile, fixed=TRUE)]
            Last_year = as.numeric(strsplit(Last_year, split=" ")[[1]][1])
          }
      if(default.input == FALSE)
          {
            First_year = First_year.input
            Last_year = Last_year.input
          }

      Table13 <- c(); Table13a = c(); Table13b = c()
      Sp_series = SSoutputs$timeseries
      derived_quants <- SSoutputs$derived_quants
      stdtable <- derived_quants
      stdtable_a <- stdtable[grep("SPRratio_", stdtable$LABEL),]
      Table13a$Yr <- as.numeric(substring(stdtable_a$LABEL, 10))
      Table13a$SPR <- round(stdtable_a$Value, 2)
      stdtable_b <- stdtable[grep("F_", stdtable$LABEL),]
      Table13b$Yr <- as.numeric(substring(stdtable_b$LABEL, 3))
      Table13b$SPR <- round(stdtable_b$Value, 2)
      landed=grep("dead(B)", colnames(Sp_series), fixed=TRUE)
      Table13$Yr = Sp_series$Yr
      Table13$Bio_all = Sp_series$Bio_all
      Table13$SpawnBio = Sp_series$SpawnBio
      Table13$Depletion = Table13$Bio_all/Table13$Bio_all[1]
      Table13$Recruit_0 = Sp_series$"Recruit_0"
      Table13$Landings = as.numeric(apply(Sp_series[landed],1,sum))
      Table13a = as.data.frame(Table13a)
      Table13b = as.data.frame(Table13b)
      Table13 = as.data.frame(Table13)
      Table13 <- cbind(Table13[which(Table13$Yr>=First_year & Table13$Yr<=Last_year),], Table13a[which(Table13a$Yr>=First_year & Table13a$Yr<=Last_year),-1], Table13b[which(Table13b$Yr>=First_year & Table13b$Yr<=Last_year),-1])
      # rename columns
      colnames(Table13) = c("Fishing year", "Total biomass (mt)", "Spawning biomass (mt)", "Depletion", "Age-0 recruits", "Total catch (mt)", "SPR", "Relative exploitation rate")
      # write the output
      if(write.csv==TRUE)
          {
            write.csv(Table13, file=paste(dir.table, "/Population time series.csv", sep=""))
          }

      return(Table13)
    }

### Asymptotic standard deviation estimates for spawning biomass and recruitment.
# the user either inputs the initial and last year for which to get the population param estimate or uses the default (takes these values from the dat file)
Table14 <- function(First_year.input=1886, Last_year.input=2012, default.input=TRUE, write.csv=TRUE)
    {
      if(default.input == TRUE)
          {
            First_year = Datfile[grep("#_styr", Datfile, fixed=TRUE)]
            First_year = as.numeric(strsplit(First_year, split=" ")[[1]][1])
            Last_year = Datfile[grep("#_endyr", Datfile, fixed=TRUE)]
            Last_year = as.numeric(strsplit(Last_year, split=" ")[[1]][1])
          }
      if(default.input == FALSE)
          {
            First_year = First_year.input
            Last_year = Last_year.input
          }

      Table14 <- c()
      # extract recruitment time series
      derived_quants <- SSoutputs$derived_quants
      stdtable <- derived_quants
      to_skip <- unlist(gregexpr("_", stdtable$LABEL))+1
      stdtable$Yr <- substring(stdtable$LABEL, to_skip)
      stdtable$SD <- stdtable[,3]
      # format table
      Table14a <- c(); Table14b <- c();
      stdtable_a <- stdtable[grep("SPB", stdtable$LABEL),]
      Table14a$Yr <- as.numeric(stdtable_a$Yr)
      Table14a$SPB_SD <- round(stdtable_a$SD, 3)
      stdtable_b <- stdtable[grep("Recr", stdtable$LABEL),]
      Table14b$Yr <- as.numeric(stdtable_b$Yr)
      Table14b$Rec_SD <- round(stdtable_b$SD,3)
      # make them a data frame
      Table14a <- as.data.frame(Table14a)
      Table14b <- as.data.frame(Table14b)
      # keep only the specified last years
      Table14 <- cbind(Table14a[which(Table14a$Yr>=First_year & Table14a$Yr<=Last_year),], Table14b[which(Table14b$Yr>=First_year & Table14b$Yr<=Last_year),-1])
      # reassign columns names
      colnames(Table14) <- c("Fishing year", "SD spawning biomass (mt)", "SD age-0 recruit (1000s)")
      # write the table
      if(write.csv==TRUE)
          {
            write.csv(Table14, file=paste(dir.table, "/Assymptotic std estimates.csv", sep=""))
          }
      return(Table14)
    }

makeTables <- function(write.csv=TRUE){
  startyr <- SSoutputs$startyr  
  # the commands in this function could just be copy and pasted one by one,
  # after defining write.csv as true or false
  
  
  #### Run the tables
  ### Recent catch table
  # input value indicating how many years of data you want to show)
  Table1(last_n_years=10, write.csv=write.csv)

  ### Recent SPB and depletion table
  # input the first and last year for which you want this info
  Tables2 = Table2(First_year=2004, Last_year=2013, write.csv=write.csv)

  ### Recent recruitment table
  # input the first and last year for which you want this info
  # and the unit of the recruitment data
  Table3(First_year=2004, Last_year=2013, Rec_unit="(1000s)", write.csv=write.csv)

  ### Recent catch and landings
  # input the first and last year for which you want this info
  Table4(First_year=2004, Last_year=2013, write.csv=write.csv)

  ### Table of discard
  # input the first and last year for which you want this info
  Table4b(First_year.input=startyr, Last_year.input=2012, default.input=TRUE, write.csv=write.csv)

  ### Recent trend in SPR and F
  # input the first and last year for which you want this info
  Table5(First_year=2004, Last_year=2013, write.csv=write.csv)

  ### Projection Catch and Biomass
  # input the first and last year of the projection
  Table6(First_year.input=2013, Last_year.input=2022, default.input=TRUE, write.csv=write.csv)

  ### Summary reference points
  # indicate the value of the SPRMSY proxy
  Table8(SPRMSYproxy=0.5, write.csv=write.csv)

  ### Total catch observation
  # indicate the name of seasons or areas as indicated in the dat. file (as names of the fleets) to divide the catch by season or area
#  Table9(write.csv=write.csv, Seasons=c("Summer", "Winter"), Areas=NULL)
  Table9(write.csv=write.csv, Seasons=NULL, Areas=NULL)

  ## ### Length composition sample sizes
  ## # extract the length comp sample size data
  ## Table10(write.csv=write.csv, Gender="All")

  ### Growth parameter estimate
  # Name the parameters you want to extract (names should be as the one reported from SS3)
  Table11(param=c("NatM", "L_at_Amin", "L_at_Amax", "VonBert_K", "CV_young"), write.csv=write.csv)

  ### Model parameter table (BIG)
  Table12(write.csv=write.csv)

  ### Time series of population estimates from the base model
  Table13(First_year.input=startyr, Last_year.input=2013, default.input=TRUE, write.csv=write.csv)

  ### Asymptotic standard deviation estimates for spawning biomass and recruitment
  Table14(First_year.input=startyr, Last_year.input=2013, default.input=TRUE, write.csv=write.csv)


}
