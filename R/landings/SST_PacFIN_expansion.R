library(ggplot2)
library(PacFIN.Utilities)
library(nwfscSurvey)
library(reshape2)

###############################################################################
#	PacFIN Data Expansion for Shortspine thornyhead 2023 ----------------------------------------
bds_file = "PacFIN.SSPN.bds.17.Jan.2023.RData"
load(file.path(getwd(), bds_file))
out = bds.pacfin 

# Clean data 
Pdata <- cleanPacFIN(
  Pdata = out,
  keep_age_method = c("B", "BB", 1),
  CLEAN = TRUE, 
  verbose = TRUE)

Pdata2 <- Pdata

# Check fleet structure
table(Pdata$geargroup)

# Create fleet structure in Pdata
Pdata["geargroup"][Pdata["geargroup"] == "HKL"] <- "NONTWL"
Pdata["geargroup"][Pdata["geargroup"] == "POT"] <- "NONTWL"
Pdata["geargroup"][Pdata["geargroup"] == "NET"] <- "NONTWL"
table(Pdata$geargroup)

# Assign fleet - STATE_GEAR
Pdata$fleet[Pdata$state == "CA"] = paste0("CA", "_", Pdata$geargroup[Pdata$state == "CA"])
Pdata$fleet[Pdata$state == "OR"] = paste0("OR", "_", Pdata$geargroup[Pdata$state == "OR"])
Pdata$fleet[Pdata$state == "WA"] = paste0("WA", "_", Pdata$geargroup[Pdata$state == "WA"])
table(Pdata$fleet)

# Load in sex specific growth estimates from survey data 
#LWsurvey <- read.csv("outputs/length-weight/lw_parameters_NWFSCcombo.csv")
fa = 6.550678e-06 # a param female 
# fa <- LWsurvey$alpha[LWsurvey$sex=="Female"]
fb = 3.179796 # b param female
# fb <- LWsurvey$beta[LWsurvey$sex=="Female"]
ma = 6.657707e-06
# ma <- LWsurvey$alpha[LWsurvey$sex=="Male"]
mb = 3.172393
# mb <- LWsurvey$beta[LWsurvey$sex=="Male"]
ua = (fa + ma) / 2
## ua <- LWsurvey$alpha[LWsurvey$sex=="Sexes_combined"]
ub = (fb + mb) / 2
## ub <- LWsurvey$beta[LWsurvey$sex=="Sexes_combined"]

################################################################################
# Data checking -------------------------------------------------------
# Check lengths by sex
# These are just starting values - estimates will be based on sex
# von berttalanfy parameters
k = 0.01314229; Linf = 70; L0 = 10; CV1 = 0.20; CV2 = 0.10
# align column names with survey package 
Pdata$Length_cm <- Pdata$lengthcm # survey = length_cm 
Pdata$Sex <- Pdata$SEX

##--------------------------------------------------##
##-----------This part is useless for SST ----------##
# Fit a von Bertalanffy model
# For SST we don't have age data associated with catch
Pdata <- nwfscSurvey::est_growth(
  dat = Pdata,
  Par = data.frame(K = k, Linf = Linf, L0 = L0, CV0 = CV1, CV1 = CV2),
  dir = ".")
##--------------------------------------------------##

# check lengths 
quantile(Pdata$lengthcm, na.rm = TRUE) 
quantile(Pdata$length, na.rm = TRUE) 
summary(Pdata$lengthcm)
summary(Pdata$length) # same as length cm
table(Pdata$geargroup[is.na(Pdata$length)])
table(Pdata$fleet[is.na(Pdata$length)])
# Length data is mostly missing for CA NonTrawl. Only a small percentage of the dataset


# remove observations larger than certain threshold 
#remove = which(Pdata$lengthcm > 100) # none over 100
#Pdata[remove, "Length"] = NA

# W-L plot 
ggplot(Pdata, aes(x = lengthcm, y = weightkg)) +
  geom_jitter() + 
  geom_point(aes(col = SEX), size = 2) +
  scale_colour_viridis_d()

# try with length
ggplot(Pdata, aes(x = length, y = weightkg)) +
  geom_jitter() + 
  geom_point(aes(col = SEX), size = 2) +
  scale_colour_viridis_d()

# look at small weights 
filter(Pdata, weightkg < 0.15) %>%
  select(lengthcm, weightkg, SEX) %>%
  ggplot(aes(x = lengthcm, y = weightkg)) +
  geom_jitter() + 
  geom_point(aes(col = SEX), size = 2) +
  scale_colour_viridis_d()

# what are this odd data points?
Pdata %>%
  filter(lengthcm > 39 & weightkg < 0.05) %>% 
  dplyr::select(year) %>%
  table()
# --> Mainly recent data (2020) from Washington state

Pdata %>%
  mutate(weightkg=ifelse(lengthcm > 39 & weightkg < 0.05, weightkg*0.453592*1000, weightkg)) %>% 
  select(lengthcm, weightkg, SEX) %>%
  ggplot(aes(x = lengthcm, y = weightkg)) +
  geom_jitter() + 
  geom_point(aes(col = SEX), size = 2) +
  scale_colour_viridis_d()

# correct small weights 
#test <- Pdata %>% mutate(weightkg = ifelse(lengthcm > 39 & weightkg < 0.05, weightkg * 1000, weightkg))

# filter out weird values and wierd fish from 1981 that were messing with the expansion
test <- Pdata %>% filter(weightkg > 0.025 | is.na(weightkg))
test <- test %>% filter(AGENCY_SAMPLE_NUMBER != 1981223128134)

# or, alternatively, consider the magical conversion
Pdata %>%
  mutate(weightkg=ifelse(lengthcm > 39 & weightkg < 0.05, weightkg*0.453592*1000, weightkg)) -> test
#test <- Pdata %>% filter(weightkg > 0.025 | is.na(weightkg))
test <- test %>% filter(AGENCY_SAMPLE_NUMBER != 1981223128134)

ggplot(test, aes(x = lengthcm, y = weightkg)) +
  geom_jitter() + 
  geom_point(aes(col = SEX), size = 2) +
  scale_colour_viridis_d()

#####################################################################
# Specify fleets, the stratification for expansion, and calculate expansions
#####################################################################
# Load in the catch file for expansion - the format of this
# catch file may not match your fleet structure in the model.
# Each state should be kept seperate for state based expansions
# for each gear fleet within that state.
# landings reported data from pacfin - separate for each state because different sampling and coverage 

# First stage expansion ----------NOTE: TEST---------------------------------
# expand comps to the trip level
Pdata_exp <- getExpansion_1(
  Pdata = test,
  plot = getwd(),
  fa = fa, fb = fb, ma = ma, mb = mb, ua = ua, ub = ub) # weight-length params

# check the filled weight values are consistent with observations
Pdata_exp %>%
  mutate(is.weight=ifelse(is.na(weightkg), "N", "Y")) %>%
  ggplot(aes(x = lengthcm, y = bestweight)) +
  geom_jitter() + 
  geom_point(aes(col = is.weight), size = 2) +
  scale_colour_viridis_d() +
  theme_bw()

# Second stage expansion -----------NOTE: TEST--------------------------------
# expand comps up to the state and fleet (gear group)
# The stratification.col input below needs to be the same as in the catch csv file

catch <- read.csv("/Users/haleyoleynik/Documents/UW stock assessment course/SST PacFin data/SST_PacFIN_catch.csv")

Pdata_exp <- getExpansion_2(
  Pdata = Pdata_exp, 
  Catch = catch, # catch file - needs to match state and fleet 
  Units = "MT", 
  stratification.cols = c("state", "geargroup"),
  savedir = file.path("/Users/haleyoleynik/Documents/UW stock assessment course/SST PacFin data"))

# Calculate the final expansion size ------------------------------------
# look expansion factors and caps (26 is a tight range)
# multiply expansion factors together 
# cap values applies 0.95 quantile (anything outside gets capped)
Pdata_exp$Final_Sample_Size <- capValues(Pdata_exp$Expansion_Factor_1_L * Pdata_exp$Expansion_Factor_2)

# data frame with expansion factors - only records with lengths, take out na
# dataframe with composition by length bin, state, year, gear
length_comps <- getComps(
  Pdata = Pdata_exp[!is.na(Pdata_exp$lengthcm), ], 
  Comps = "LEN")

# diagnostics 
table(Pdata$SOURCE_AGID, Pdata$SEX)

# look at where unsexed fish are 
Pdata$count <- 1
ggplot(Pdata, aes(x = lengthcm, y = count, fill = SEX))  + 
  geom_histogram(aes(y = count), position="stack", stat="identity") +
  scale_fill_viridis_d()

#################################################################################
# Create the length composition data
#################################################################################
# code to do sex ratio: 
# Commenting out for now because I don't want to assign unsexed 
# due to the dimorphic growth
# There area a fair number of U in CA and in the early years of WA
# length_compSR <- doSexRatio(
#	CompData = length_comps, 
# 	ratioU = 0.5, 
# 	maxsizeU = 25, 
# 	savedir = file.path(dir, "commercial_comps"))

# length bins 
len_bins = c(seq(6, 72, 2))
out_name = sub(pattern = "(.*)\\..*$", replacement = "\\1", bds_file)

writeComps(
  inComps = length_comps, 
  fname = file.path(dir, "pacfin_bds", "forSS", paste0("Lengths_", out_name, ".csv")), # tell file name for .csv
  lbins = len_bins, 
  sum1 = TRUE, # sum comps to 1, SS does this for you 
  partition = 2, # only retained fish 
  digits = 4, # round 
  dummybins = FALSE)

###############################################################################
# Let's format the csv files for direct use in SS3
###############################################################################

out = read.csv(
  file.path(dir, "pacfin_bds", "forSS", paste0("Lengths_", out_name, ".csv")), 
  skip = 3, 
  header = TRUE)

start = 1 
end   = which(as.character(out[,1]) %in% c(" Females only ")) - 1 
cut_out = out[start:end,]

# format the length comps
cut_out$fleet[cut_out$fleet =="CA_ALL"] = 1
cut_out$fleet[cut_out$fleet =="WA_OR_ALL"] = 2

ind = which(colnames(cut_out) %in% paste0("F", min(len_bins))):
  which(colnames(cut_out) %in% paste0("M", max(len_bins)))
format = cbind(cut_out$year, cut_out$month, cut_out$fleet, cut_out$sex, cut_out$partition, cut_out$InputN, cut_out[,ind])
colnames(format) = c("year", "month", "fleet", "sex", "part", "InputN", colnames(cut_out[ind]))
format = format[format$year != 2021, ]
write.csv(
  format, 
  file = file.path(dir, "pacfin_bds", "forSS", paste0("Lcomps_for_SS3_", out_name, ".csv")), 
  row.names = FALSE)


# Let's create the sample table - goes into assessment report 
temp = Pdata[!is.na(Pdata$lengthcm) & Pdata$year < 2021,]
Nfish = table(temp$year, temp$state)
colnames(Nfish) = sort(unique(temp$state)) 

aa = sort(unique(temp$state)) 
yy = sort(unique(temp$year))
Ntows = matrix(0, length(yy), length(aa))
for(y in 1:length(yy)){
  for(a in 1:length(aa)){
    ind = which(temp$year == yy[y] & temp$state  == aa[a])
    if(length(ind) > 0) {Ntows[y, a] = length(unique(temp$SAMPLE_NO[ind])) }
  }
}
colnames(Ntows) = aa
rownames(Ntows) = yy

samples = cbind(rownames(Ntows), Ntows[,"CA"] , Nfish[,"CA"], 
                Ntows[,"OR"] , Nfish[,"OR"],  Ntows[,"WA"] , Nfish[,"WA"])

colnames(samples) = c("Year", "CA Ntows", "CA Nfish",
                      "OR Ntows", "OR Nfish", "WA Ntows", "WA Nfish")
write.csv(
  samples, 
  file = file.path(dir, "pacfin_bds", "forSS", paste0("PacFIN_Length_Samples_by_State.csv")), 
  row.names = FALSE)
