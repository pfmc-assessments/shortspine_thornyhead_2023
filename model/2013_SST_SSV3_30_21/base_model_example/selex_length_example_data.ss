#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_Start_time: Fri Sep 30 15:19:58 2022
#_echo_input_data
#C data file for model showing different selectivities
#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
2001 #_StartYr
2012 #_EndYr
1 #_Nseas
 12 #_months/season
2 #_Nsubseasons (even number, minimum is 2)
1 #_spawn_month
2 #_Ngenders: 1, 2, -1  (use -1 for 1 sex setup with SSB multiplied by female_frac parameter)
20 #_Nages=accumulator age, first age is always age 0
1 #_Nareas
5 #_Nfleets (including surveys)
#_fleet_type: 1=catch fleet; 2=bycatch only fleet; 3=survey; 4=predator(M2) 
#_sample_timing: -1 for fishing fleet to use season-long catch-at-age for observations, or 1 to use observation month;  (always 1 for surveys)
#_fleet_area:  area the fleet/survey operates in 
#_units of catch:  1=bio; 2=num (ignored for surveys; their units read later)
#_catch_mult: 0=no; 1=yes
#_rows are fleets
#_fleet_type fishery_timing area catch_units need_catch_mult fleetname
 1 1 1 1 0 Type1_size_logistic  # 1
 1 1 1 1 0 Type6_size_non-parametric  # 2
 1 1 1 1 0 Type24_size_double-normal  # 3
 1 1 1 1 0 Type25_size_exponential-logistic  # 4
 1 1 1 1 0 Type27_size_cubic-spline  # 5
#Bycatch_fleet_input_goes_next
#a:  fleet index
#b:  1=include dead bycatch in total dead catch for F0.1 and MSY optimizations and forecast ABC; 2=omit from total catch for these purposes (but still include the mortality)
#c:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=bycatch F from range of years
#d:  F or first year of range
#e:  last year of range
#f:  not used
# a   b   c   d   e   f 
#_Catch data: yr, seas, fleet, catch, catch_se
#_catch_se:  standard error of log(catch)
#_NOTE:  catch data is ignored for survey fleets
-999 1 1 0 0.1
2001 1 1 1000 0.1
2002 1 1 1000 0.1
2003 1 1 1000 0.1
2004 1 1 1000 0.1
2005 1 1 1000 0.1
2006 1 1 1000 0.1
2007 1 1 1000 0.1
2008 1 1 1000 0.1
2009 1 1 1000 0.1
2010 1 1 1000 0.1
2011 1 1 1000 0.1
2012 1 1 1000 0.1
-999 1 2 0 0.1
2001 1 2 1000 0.1
2002 1 2 1000 0.1
2003 1 2 1000 0.1
2004 1 2 1000 0.1
2005 1 2 1000 0.1
2006 1 2 1000 0.1
2007 1 2 1000 0.1
2008 1 2 1000 0.1
2009 1 2 1000 0.1
2010 1 2 1000 0.1
2011 1 2 1000 0.1
2012 1 2 1000 0.1
-999 1 3 0 0.1
2001 1 3 1000 0.1
2002 1 3 1000 0.1
2003 1 3 1000 0.1
2004 1 3 1000 0.1
2005 1 3 1000 0.1
2006 1 3 1000 0.1
2007 1 3 1000 0.1
2008 1 3 1000 0.1
2009 1 3 1000 0.1
2010 1 3 1000 0.1
2011 1 3 1000 0.1
2012 1 3 1000 0.1
-999 1 4 0 0.1
2001 1 4 1000 0.1
2002 1 4 1000 0.1
2003 1 4 1000 0.1
2004 1 4 1000 0.1
2005 1 4 1000 0.1
2006 1 4 1000 0.1
2007 1 4 1000 0.1
2008 1 4 1000 0.1
2009 1 4 1000 0.1
2010 1 4 1000 0.1
2011 1 4 1000 0.1
2012 1 4 1000 0.1
-999 1 5 0 0.1
2001 1 5 1000 0.1
2002 1 5 1000 0.1
2003 1 5 1000 0.1
2004 1 5 1000 0.1
2005 1 5 1000 0.1
2006 1 5 1000 0.1
2007 1 5 1000 0.1
2008 1 5 1000 0.1
2009 1 5 1000 0.1
2010 1 5 1000 0.1
2011 1 5 1000 0.1
2012 1 5 1000 0.1
-9999 0 0 0 0
#
 #_CPUE_and_surveyabundance_observations
#_Units:  0=numbers; 1=biomass; 2=F; 30=spawnbio; 31=recdev; 32=spawnbio*recdev; 33=recruitment; 34=depletion(&see Qsetup); 35=parm_dev(&see Qsetup)
#_Errtype:  -1=normal; 0=lognormal; >0=T
#_SD_Report: 0=no sdreport; 1=enable sdreport
#_Fleet Units Errtype SD_Report
1 1 0 0 # Type1_size_logistic
2 1 0 0 # Type6_size_non-parametric
3 1 0 0 # Type24_size_double-normal
4 1 0 0 # Type25_size_exponential-logistic
5 1 0 0 # Type27_size_cubic-spline
#_yr month fleet obs stderr
2001 7 1 10 0.1 #_ Type1_size_logistic
2002 7 1 9 0.1 #_ Type1_size_logistic
2003 7 1 8 0.1 #_ Type1_size_logistic
2004 7 1 7 0.1 #_ Type1_size_logistic
2005 7 1 6 0.1 #_ Type1_size_logistic
2006 7 1 5 0.1 #_ Type1_size_logistic
2007 7 1 5 0.1 #_ Type1_size_logistic
2008 7 1 4 0.1 #_ Type1_size_logistic
2009 7 1 4 0.1 #_ Type1_size_logistic
2010 7 1 3.5 0.1 #_ Type1_size_logistic
-9999 1 1 1 1 # terminator for survey observations 
#
0 #_N_fleets_with_discard
#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)
#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV
# note: only enter units and errtype for fleets with discard 
# note: discard data is the total for an entire season, so input of month here must be to a month in that season
#_Fleet units errtype
# -9999 0 0 0.0 0.0 # terminator for discard data 
#
0 #_use meanbodysize_data (0/1)
#_COND_0 #_DF_for_meanbodysize_T-distribution_like
# note:  type=1 for mean length; type=2 for mean body weight 
#_yr month fleet part type obs stderr
#  -9999 0 0 0 0 0 0 # terminator for mean body size data 
#
# set up population length bin structure (note - irrelevant if not using size data and using empirical wtatage
2 # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector
2 # binwidth for population size comp 
10 # minimum size in the population (lower edge of first bin and size at age 0.00) 
98 # maximum size in the population (lower edge of last bin) 
1 # use length composition data (0/1)
#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined gender below this bin number 
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  consecutive index for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
-1 0.001 1 0 0 0 1 #_fleet:1_Type1_size_logistic
-1 0.001 1 0 0 0 1 #_fleet:2_Type6_size_non-parametric
-1 0.001 1 0 0 0 1 #_fleet:3_Type24_size_double-normal
-1 0.001 1 0 0 0 1 #_fleet:4_Type25_size_exponential-logistic
-1 0.001 1 0 0 0 1 #_fleet:5_Type27_size_cubic-spline
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution
# partition codes:  (0=combined; 1=discard; 2=retained
33 #_N_LengthBins; then enter lower edge of each length bin
 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90
#_yr month fleet sex part Nsamp datavector(female-male)
 2010 7 1 3 0 500 0 1 2 4 15 23 27 28 22 20 18 16 14 10 11 6 6 10 8 4 7 3 2 2 2 1 1 0 0 0 0 0 1 1 0 3 9 13 21 20 21 10 31 21 16 15 11 3 7 6 4 8 2 2 1 2 1 2 0 1 0 0 2 0 0 3
 2010 7 2 3 0 500 0 1 2 4 15 23 27 28 22 20 18 16 14 10 11 6 6 10 8 4 7 3 2 2 2 1 1 0 0 0 0 0 1 1 0 3 9 13 21 20 21 10 31 21 16 15 11 3 7 6 4 8 2 2 1 2 1 2 0 1 0 0 2 0 0 3
 2010 7 3 3 0 500 0 1 2 4 15 23 27 28 22 20 18 16 14 10 11 6 6 10 8 4 7 3 2 2 2 1 1 0 0 0 0 0 1 1 0 3 9 13 21 20 21 10 31 21 16 15 11 3 7 6 4 8 2 2 1 2 1 2 0 1 0 0 2 0 0 3
 2010 7 4 3 0 500 0 1 2 4 15 23 27 28 22 20 18 16 14 10 11 6 6 10 8 4 7 3 2 2 2 1 1 0 0 0 0 0 1 1 0 3 9 13 21 20 21 10 31 21 16 15 11 3 7 6 4 8 2 2 1 2 1 2 0 1 0 0 2 0 0 3
 2010 7 5 3 0 500 0 1 2 4 15 23 27 28 22 20 18 16 14 10 11 6 6 10 8 4 7 3 2 2 2 1 1 0 0 0 0 0 1 1 0 3 9 13 21 20 21 10 31 21 16 15 11 3 7 6 4 8 2 2 1 2 1 2 0 1 0 0 2 0 0 3
-9999 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
#
15 #_N_age_bins
 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
1 #_N_ageerror_definitions
 0.5 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5 10.5 11.5 12.5 13.5 14.5 15.5 16.5 17.5 18.5 19.5 20.5
 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01
#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined gender below this bin number 
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  consecutive index for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
-1 0.001 0 0 0 0 1 #_fleet:1_Type1_size_logistic
-1 0.001 0 0 0 0 1 #_fleet:2_Type6_size_non-parametric
-1 0.001 0 0 0 0 1 #_fleet:3_Type24_size_double-normal
-1 0.001 0 0 0 0 1 #_fleet:4_Type25_size_exponential-logistic
-1 0.001 0 0 0 0 1 #_fleet:5_Type27_size_cubic-spline
3 #_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution
# partition codes:  (0=combined; 1=discard; 2=retained
#_yr month fleet sex part ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)
 2010 7 -1 3 0 1 -1 -1 250 49 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
 2010 7 -2 3 0 1 -1 -1 250 49 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
 2010 7 -3 3 0 1 -1 -1 250 49 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
 2010 7 -4 3 0 1 -1 -1 250 49 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
 2010 7 -5 3 0 1 -1 -1 250 49 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
 2010 7 4 3 0 1 26 30 50 49 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
 2010 7 4 3 0 1 30 34 50 37 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 2 0 0 0 2 0 0 0 0 0 0 0 0
 2010 7 4 3 0 1 34 38 50 36 2 0 0 1 0 0 0 0 0 0 0 0 0 0 0 9 0 1 1 0 0 0 0 0 0 0 0 0 0
 2010 7 4 3 0 1 38 42 50 23 6 2 0 0 0 0 0 0 0 0 0 0 0 0 0 12 6 1 0 0 0 0 0 0 0 0 0 0 0
 2010 7 4 3 0 1 42 46 50 10 13 1 0 0 0 0 0 0 0 0 0 0 0 0 0 11 9 4 0 0 0 0 1 1 0 0 0 0 0
 2010 7 4 3 0 1 46 50 50 0 10 9 1 3 0 0 0 0 0 0 0 0 0 0 0 6 11 7 2 1 0 0 0 0 0 0 0 0 0
 2010 7 4 3 0 1 50 54 50 1 3 14 2 1 1 0 0 0 0 0 0 0 1 0 0 3 9 4 7 1 1 1 0 0 0 0 0 0 1
 2010 7 4 3 0 1 54 58 50 0 1 15 8 3 0 1 1 0 0 0 0 0 0 0 0 0 2 7 4 4 1 1 1 0 0 1 0 0 0
 2010 7 4 3 0 1 58 62 50 0 1 2 6 6 6 1 1 0 0 0 0 0 0 0 0 0 1 5 4 7 1 4 0 2 0 1 1 0 1
 2010 7 4 3 0 1 62 66 50 0 0 2 10 5 6 4 1 1 1 0 0 0 0 0 0 0 0 0 2 2 4 3 4 3 1 0 0 0 1
 2010 7 4 3 0 1 66 70 50 0 0 0 2 4 11 2 2 4 1 0 2 1 0 2 0 0 0 1 2 0 4 1 1 3 2 1 1 0 3
 2010 7 4 3 0 1 70 74 50 0 0 1 0 3 4 5 5 2 6 1 0 4 2 2 0 0 0 0 1 0 0 0 1 3 2 2 1 1 4
 2010 7 4 3 0 1 74 78 50 0 0 0 0 1 3 9 6 5 0 4 1 4 1 6 0 0 0 0 0 0 0 2 0 0 1 1 3 0 3
 2010 7 4 3 0 1 78 82 50 0 0 0 0 0 0 5 8 3 4 2 3 1 4 12 0 0 1 0 0 1 0 0 2 0 0 2 0 1 1
 2010 7 4 3 0 1 82 86 50 0 0 0 0 0 1 0 4 3 2 8 3 4 3 15 0 0 0 0 0 0 0 0 1 0 0 0 2 1 3
 2010 7 4 3 0 1 86 90 50 0 0 0 0 0 0 0 2 1 3 7 4 6 3 24 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
-9999  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
0 #_Use_MeanSize-at-Age_obs (0/1)
#
0 #_N_environ_variables
# -2 in yr will subtract mean for that env_var; -1 will subtract mean and divide by stddev (e.g. Z-score)
#Yr Variable Value
#
# Sizefreq data. Defined by method because a fleet can use multiple methods
0 # N sizefreq methods to read (or -1 for expanded options)
# 
0 # do tags (0/1/2); where 2 allows entry of TG_min_recap
#
0 #    morphcomp data(0/1) 
#  Nobs, Nmorphs, mincomp
#  yr, seas, type, partition, Nsamp, datavector_by_Nmorphs
#
0  #  Do dataread for selectivity priors(0/1)
# Yr, Seas, Fleet,  Age/Size,  Bin,  selex_prior,  prior_sd
# feature not yet implemented
#
999

