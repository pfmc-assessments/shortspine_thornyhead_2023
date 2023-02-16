#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#C control file for model showing different selectivities
#_data_and_control_files: selex_length_example_data.ss // selex_length_example_control.ss
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
2 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
1 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 1 1 0
#
#_Cond 0 # N_movement_definitions goes here if Nareas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
1 #_Nblock_Patterns
 1 #_blocks_per_pattern 
# begin and end years of blocks
 2000 2000
#
# controls for all timevary parameters 
1 #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds
#
# AUTOGEN
 1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen time-varying parms of this category; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
#_Available timevary codes
#_Block types: 0: P_block=P_base*exp(TVP); 1: P_block=P_base+TVP; 2: P_block=TVP; 3: P_block=P_block(-1) + TVP
#_Block_trends: -1: trend bounded by base parm min-max and parms in transformed units (beware); -2: endtrend and infl_year direct values; -3: end and infl as fraction of base range
#_EnvLinks:  1: P(y)=P_base*exp(TVP*env(y));  2: P(y)=P_base+TVP*env(y);  3: P(y)=f(TVP,env_Zscore) w/ logit to stay in min-max;  4: P(y)=2.0/(1.0+exp(-TVP1*env(y) - TVP2))
#_DevLinks:  1: P(y)*=exp(dev(y)*dev_se;  2: P(y)+=dev(y)*dev_se;  3: random walk;  4: zero-reverting random walk with rho;  5: like 4 with logit transform to stay in base min-max
#_DevLinks(more):  21-25 keep last dev for rest of years
#
#_Prior_codes:  0=none; 6=normal; 1=symmetric beta; 2=CASAL's beta; 3=lognormal; 4=lognormal with biascorr; 5=gamma
#
# setup for M, growth, wt-len, maturity, fecundity, (hermaphro), recr_distr, cohort_grow, (movement), (age error), (catch_mult), sex ratio 
#_NATMORT
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
  #_no additional input for selected M option; read 1P per morph
#
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
0 #_Age(post-settlement)_for_L1;linear growth below this
12 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
1 #_First_Mature_Age
1 #_fecundity_at_length option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
 0.05 0.35 0.25 0.1 0.8 0 -3 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 -10 45 22 36 10 6 -2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 40 90 72 70 10 6 -4 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.05 0.4 0.24 0.15 0.8 6 -4 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.05 0.25 0.1 0.1 0.8 0 -3 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.05 0.25 0.1 0.1 0.8 0 -3 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -3 3 2.44e-06 2.44e-06 0.8 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_1
 -3 4 3.34694 3.34694 0.8 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_1
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 50 60 55 55 0.8 0 -3 0 0 0 0 0 0 0 # Mat50%_Fem_GP_1
 -3 3 -0.25 -0.25 0.8 0 -3 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_1
 -3 3 1 1 0.8 0 -3 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem_GP_1
 -3 3 0 0 0.8 0 -3 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem_GP_1
# Sex: 2  BioPattern: 1  NatMort
 0.05 0.15 0.25 0.1 0.8 0 -3 0 0 0 0 0 0 0 # NatM_uniform_Mal_GP_1
# Sex: 2  BioPattern: 1  Growth
 1 45 0 36 10 0 -3 0 0 0 0 0 0 0 # L_at_Amin_Mal_GP_1
 40 90 65 70 10 6 -4 0 0 0 0 0 0 0 # L_at_Amax_Mal_GP_1
 0.05 0.25 0.24 0.15 0.8 6 -4 0 0 0 0 0 0 0 # VonBert_K_Mal_GP_1
 0.05 0.25 0.1 0.1 0.8 0 -3 0 0 0 0 0 0 0 # CV_young_Mal_GP_1
 0.05 0.25 0.1 0.1 0.8 0 -3 0 0 0 0 0 0 0 # CV_old_Mal_GP_1
# Sex: 2  BioPattern: 1  WtLen
 -3 3 2.44e-06 2.44e-06 0.8 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Mal_GP_1
 -3 4 3.34694 3.34694 0.8 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Mal_GP_1
# Hermaphroditism
#  Recruitment Distribution 
 0 0 0 0 0 0 -4 0 0 0 0 0 0 0 # RecrDist_GP_1
 0 0 0 0 0 0 -4 0 0 0 0 0 0 0 # RecrDist_Area_1
 0 0 0 0 0 0 -4 0 0 0 0 0 0 0 # RecrDist_month_1
#  Cohort growth dev base
 0.1 10 1 1 1 6 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#  M2 parameter for each predator fleet
#
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
0  # 0/1 to use steepness in initial equ recruitment calculation
0  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
             3            31       9.13416          10.3            10             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           0.2             1          0.75           0.7          0.05             1         -4          0          0          0          0          0          0          0 # SR_BH_steep
             0             2           0.6           0.8           0.8             0         -4          0          0          0          0          0          0          0 # SR_sigmaR
            -5             5             0             0             1             0         -4          0          0          0          0          0          0          0 # SR_regime
             0             0             0             0             0             0        -99          0          0          0          0          0          0          0 # SR_autocorr
#_no timevary SR parameters
0 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
2001 # first year of main recr_devs; early devs can preceed this era
2010 # last year of main recr_devs; forecast devs start in following year
-3 #_recdev phase 
0 # (0/1) to read 13 advanced options
#_Cond 0 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
#_Cond -4 #_recdev_early_phase
#_Cond -4 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
#_Cond 1 #_lambda for Fcast_recr_like occurring before endyr+1
#_Cond 1001 #_last_yr_nobias_adj_in_MPD; begin of ramp
#_Cond 1981 #_first_yr_fullbias_adj_in_MPD; begin of plateau
#_Cond 2010 #_last_yr_fullbias_adj_in_MPD
#_Cond 2013 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
#_Cond 1 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
#_Cond 0 #_period of cycles in recruitment (N parms read below)
#_Cond -5 #min rec_dev
#_Cond 5 #max rec_dev
#_Cond 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_Yr Input_value
#
# all recruitment deviations
#  2011F 2012F 2013F
# #
#Fishing Mortality info 
0.3 # F ballpark value in units of annual_F
-2001 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
2.9 # max F (methods 2-4) or harvest fraction (method 1)
4  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 0
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
#
# F rates by fleet x season
# Yr:  2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1
# Type1_size_logistic 0.0226987 0.0254321 0.0285933 0.0322001 0.0362964 0.0409693 0.0463725 0.0527648 0.0605835 0.0705988 0.0842847 0.104858 0.104858
# Type6_size_non-parametric 0.0312812 0.0350172 0.0392256 0.0439365 0.0492364 0.0552501 0.0621742 0.070332 0.0802675 0.0929391 0.110179 0.13598 0.13598
# Type24_size_double-normal 0.0307202 0.0343895 0.0385108 0.0431128 0.0482734 0.054111 0.0608182 0.0687117 0.0783212 0.0905768 0.107254 0.132218 0.132218
# Type25_size_exponential-logistic 0.0293308 0.0328426 0.0367966 0.0411922 0.0460782 0.0515628 0.0578344 0.0652003 0.0741674 0.0856169 0.101223 0.124627 0.124627
# Type27_size_cubic-spline 0.0309789 0.0346791 0.0388344 0.0434681 0.0486556 0.0545176 0.0612493 0.0691701 0.0788126 0.0911109 0.107847 0.132902 0.132902
#
#_Q_setup for fleets with cpue or survey data
#_1:  fleet number
#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         1         1         0         0         0         1  #  Type1_size_logistic
-9999 0 0 0 0 0
#
#_Q_parms(if_any);Qunits_are_ln(q)
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
           -25            25      -8.38539             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_Type1_size_logistic(1)
#_no timevary Q parameters
#
#_size_selex_patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6;  parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (average over bin range)
#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option
#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2+special; non-parm len selex, read as pairs of size, then selex
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_2;  parm=6; double_normal with sel(minL) and sel(maxL), using joiners, back compatibile version of 24 with 3.30.18 and older
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (average over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 1 0 0 0 # 1 Type1_size_logistic
 6 0 0 5 # 2 Type6_size_non-parametric
 24 0 0 0 # 3 Type24_size_double-normal
 25 0 0 0 # 4 Type25_size_exponential-logistic
 27 0 0 3 # 5 Type27_size_cubic-spline
#
#_age_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic. Recommend using pattern 18 instead.
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (average over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (average over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
#_Pattern Discard Male Special
 10 0 0 0 # 1 Type1_size_logistic
 10 0 0 0 # 2 Type6_size_non-parametric
 10 0 0 0 # 3 Type24_size_double-normal
 10 0 0 0 # 4 Type25_size_exponential-logistic
 10 0 0 0 # 5 Type27_size_cubic-spline
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   Type1_size_logistic LenSelex
            25            80       32.8734            50          0.01             1          2          0          0          0          0          0          0          0  #  Size_inflection_Type1_size_logistic(1)
          0.01            60       6.65077            15          0.01             1          3          0          0          0          0          0          0          0  #  Size_95%width_Type1_size_logistic(1)
# 2   Type6_size_non-parametric LenSelex
             1           100            25             0           0.5             0        -99          0          0          0          0          0          0          0  #  SizeSel_P1_Type6_size_non-parametric(2)
             1           100            70             0           0.5             0        -99          0          0          0          0          0          0          0  #  SizeSel_P2_Type6_size_non-parametric(2)
            -5             5      -2.10081             0           0.5             0          2          0          0          0          0          0          0          0  #  SizeSel_P3_Type6_size_non-parametric(2)
            -5             5     -0.101585             0           0.5             0          2          0          0          0          0          0          0          0  #  SizeSel_P4_Type6_size_non-parametric(2)
            -5             5      0.265656             0           0.5             0          2          0          0          0          0          0          0          0  #  SizeSel_P5_Type6_size_non-parametric(2)
            -5             5      -0.26885             0           0.5             0          2          0          0          0          0          0          0          0  #  SizeSel_P6_Type6_size_non-parametric(2)
            -5             5          -0.1             0           0.5             0         -2          0          0          0          0          0          0          0  #  SizeSel_P7_Type6_size_non-parametric(2)
# 3   Type24_size_double-normal LenSelex
            30            60       45.8769            36             5             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_Type24_size_double-normal(3)
            -7             7      -3.19566          -0.5             2             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_Type24_size_double-normal(3)
            -5            10       5.31147          1.75             5             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_Type24_size_double-normal(3)
            -5            10       1.71063           0.1             2             0          4          0          0          0          0          0          0          0  #  Size_DblN_descend_se_Type24_size_double-normal(3)
          -999            15          -999            -1             5             0        -99          0          0          0          0          0          0          0  #  Size_DblN_start_logit_Type24_size_double-normal(3)
          -999            15      0.741647             1             5             0          4          0          0          0          0          0          0          0  #  Size_DblN_end_logit_Type24_size_double-normal(3)
# 4   Type25_size_exponential-logistic LenSelex
          0.02             1      0.381735             0           0.5             0          2          0          0          0          0          0          0          0  #  SizeSel_P1_Type25_size_exponential-logistic(4)
          0.01          0.99       0.36601             0           0.5             0          2          0          0          0          0          0          0          0  #  SizeSel_P2_Type25_size_exponential-logistic(4)
         0.001           0.6      0.043592             0           0.5             0          2          0          0          0          0          0          0          0  #  SizeSel_P3_Type25_size_exponential-logistic(4)
# 5   Type27_size_cubic-spline LenSelex
             0             2             0             0             0             0         -9          0          0          0          0          0          0          0  #  SizeSpline_Code_Type27_size_cubic-spline(5)
        -0.001            10      0.204043             0           0.1             0          3          0          0          0          0          0          0          0  #  SizeSpline_GradLo_Type27_size_cubic-spline(5)
           -10          0.01             0             0           0.1             0         -3          0          0          0          0          0          0          0  #  SizeSpline_GradHi_Type27_size_cubic-spline(5)
             1            70            10             0             0             0        -99          0          0          0          0          0          0          0  #  SizeSpline_Knot_1_Type27_size_cubic-spline(5)
             1            70            45             0             0             0        -99          0          0          0          0          0          0          0  #  SizeSpline_Knot_2_Type27_size_cubic-spline(5)
             1            70            60             0             0             0        -99          0          0          0          0          0          0          0  #  SizeSpline_Knot_3_Type27_size_cubic-spline(5)
            -5             5      -4.96614             0             0             0          2          0          0          0          0          0          0          0  #  SizeSpline_Val_1_Type27_size_cubic-spline(5)
            -5             5             0             0             0             0         -2          0          0          0          0          0          0          0  #  SizeSpline_Val_2_Type27_size_cubic-spline(5)
            -5             5     -0.415755             0             0             0          2          0          0          0          0          0          0          0  #  SizeSpline_Val_3_Type27_size_cubic-spline(5)
# 1   Type1_size_logistic AgeSelex
# 2   Type6_size_non-parametric AgeSelex
# 3   Type24_size_double-normal AgeSelex
# 4   Type25_size_exponential-logistic AgeSelex
# 5   Type27_size_cubic-spline AgeSelex
#_No_Dirichlet parameters
#_no timevary selex parameters
#
0   #  use 2D_AR1 selectivity(0/1)
#_no 2D_AR1 selex offset used
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read and autogen if tag data exist; 1=read
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# no timevary parameters
#
#
# Input variance adjustments factors: 
 #_1=add_to_survey_CV
 #_2=add_to_discard_stddev
 #_3=add_to_bodywt_CV
 #_4=mult_by_lencomp_N
 #_5=mult_by_agecomp_N
 #_6=mult_by_size-at-age_N
 #_7=mult_by_generalized_sizecomp
#_Factor  Fleet  Value
 -9999   1    0  # terminator
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 0 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  1 #_CPUE/survey:_1
#  0 #_CPUE/survey:_2
#  0 #_CPUE/survey:_3
#  0 #_CPUE/survey:_4
#  0 #_CPUE/survey:_5
#  1 #_lencomp:_1
#  1 #_lencomp:_2
#  1 #_lencomp:_3
#  1 #_lencomp:_4
#  1 #_lencomp:_5
#  1 #_agecomp:_1
#  1 #_agecomp:_2
#  1 #_agecomp:_3
#  1 #_agecomp:_4
#  1 #_agecomp:_5
#  1 #_init_equ_catch1
#  1 #_init_equ_catch2
#  1 #_init_equ_catch3
#  1 #_init_equ_catch4
#  1 #_init_equ_catch5
#  1 #_recruitments
#  1 #_parameter-priors
#  1 #_parameter-dev-vectors
#  1 #_crashPenLambda
#  0 # F_ballpark_lambda
1 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 4 1 -1 23 # Selectivity: (1) 0 to skip or fleet, (2) 1=len/2=age/3=combined, (3) year, (4) N selex bins; NOTE: combined reports in age bins
 1 1 # Growth: (1) 0 to skip or growth pattern, (2) growth ages; NOTE: does each sex
 1 -1 1 # Numbers-at-age: (1) 0 or area(-1 for all), (2) year, (3) N ages;  NOTE: sums across morphs
 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 # vector with selex std bins (-1 in first bin to self-generate)
 -1 # vector with growth std ages picks (-1 in first bin to self-generate)
 20 # vector with NatAge std ages (-1 in first bin to self-generate)
999

