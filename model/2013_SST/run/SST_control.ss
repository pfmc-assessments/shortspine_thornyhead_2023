# Shortspine Thornyhead control file
# Ian Taylor and Andi Stephens, 2013
#
1  # N growthmorphs
1  # N submorphs within growth patterns
#
3 # Block designs
2 2 1 # Blocks in each design
# design 1 (trawl north)
2007 2010 # design 1, block 1
2011 2012 # design 1, block 2
# design 2 (trawl south)
2007 2010 # design 2, block 1
2011 2012 # design 2, block 2
# design 3 (non-trawl south)
2007 2012 # design 3, block 1
#
# Natural mortality and growth parameters for each morph
0.5  #_fracfemale
1    #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
2    #_N_breakpoints
20 40 # age(real) at M breakpoints
1    # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_speciific_K; 4=not implemented
2    #_Growth_Age_for_L1
100  #_Growth_Age_for_L2 (999 to use as Linf)
0.1  #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0    #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
1    #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity by GP; 4=read age-fecundity by GP; 5=read fec and wt from wtatage.ss; 6=read length-maturity by GP
#_placeholder for empirical age- or length- maturity by growth pattern (female only)
#0 0 0 0 0 0.001 0.060 0.863 0.998 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
#0 0 0 0 0 0     0.027 0.414 0.499 0.520 0.540 0.560 0.580 0.600 0.620 0.640 0.660 0.680 0.700 0.720 0.740 0.760 0.780 0.800 0.820 0.840 0.860 0.880 0.900 0.920 0.940 0.960 0.980 1 1 1 1 1 1 1 1 1 1 1
1    #_First_Mature_Age
1    #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0    #_hermaphroditism option:  0=none; 1=age-specific fxn
3    #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
1    #_env/block/dev_adjust_method (1=standard; 2=logistic transform keeps in base parm bounds; 3=standard w/ no bound check)
#
#-4  # Mortality and growth parameter deviance phase
#
#
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
#0.03    0.08    0.05    0.05    -1      0.15    -3      0       0       0       0       0       0       0       #F_natM_young
0.01    0.15    0.05050 -3.129   3      0.5361  -3      0       0       0       0       0       0       0       #F_natM_young (Owen prior)
-3      3       0       0       -1      0.2     -3      0       0       0       0       0       0       0       #F_natM_old_as_exponential_offset(rel_young)
3       10      7       9       -1      2       -2      0       0       0       0       0       0       0       #F_Lmin
55      95      75      70      -1      5       -2      0       0       0       0       0       0       0       #F_Lmax
0.01    0.03    0.018   0.017   -1      0.8     -3      0       0       0       0       0       0       0       #F_VBK
0.05    0.25    0.125   0.1     -1      0.8     -3      0       0       0       0       0       0       0       #F_CV-young
-3      3       0       0       -1      0.8     -3      0       0       0       0       0       0       0       #F_CV-old_as_exponential_offset(rel_young)
-3      3       0       0       -1      0.8     -3      0       0       0       0       0       0       0       #M_natM_young_as_exponential_offset(rel_morph_1)
-3      3       0       0       -1      0.8     -3      0       0       0       0       0       0       0       #M_natM_old_as_exponential_offset(rel_young)
-3      3       0       0       -1      0.8     -3      0       0       0       0       0       0       0       #M_Lmin_as_exponential_offset
-3      3       -0.1053605 -0.1 -1      0.8     -2      0       0       0       0       0       0       0       #M_Lmax_as_exponential_offset
-3      3       0       0       -1      0.8     -3      0       0       0       0       0       0       0       #M_VBK_as_exponential_offset
-3      3       0       0       -1      0.8     -3      0       0       0       0       0       0       0       #M_CV-young_as_exponential_offset(rel_CV-young_for_morph_1)
-3      3       0       0       -1      0.8     -3      0       0       0       0       0       0       0       #M_CV-old_as_exponential_offset(rel_CV-young)

#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
## 0       100     4.9E-6  4.9E-6  -1      0.8     -3      0       0       0       0       0       0       0       #Female_wt-len-1
## 0       100     3.264   3.264   -1      0.8     -3      0       0       0       0       0       0       0       #Female_wt-len-2
0       100     4.770654e-06 0  -1      0.8     -3      0       0       0       0       0       0       0       #Female_wt-len-1
0       100     3.262977     0  -1      0.8     -3      0       0       0       0       0       0       0       #Female_wt-len-2
0       100     18.2    22      -1      0.8     -3      0       0       0       0       0       0       0       #Female_mat-len-1
-3      100     -2.3    -0.4    -1      0.8     -3      0       0       0       0       0       0       0       #Female_mat-len-2
0       100     1       1       -1      0.8     -3      0       0       0       0       0       0       0       #Female_eggs/gm_intercept
0       100     0       0       -1      0.8     -3      0       0       0       0       0       0       0       #Female_eggs/gm_slope
## 0       100     4.9E-6 4.9E-6   -1      0.8     -3      0       0       0       0       0       0       0       #Male_wt-len-1
## 0       100     3.264   3.264   -1      0.8     -3      0       0       0       0       0       0       0       #Male_wt-len-2
0       100     4.770654e-06 0  -1      0.8     -3      0       0       0       0       0       0       0       #Male_wt-len-1
0       100     3.262977     0  -1      0.8     -3      0       0       0       0       0       0       0       #Male_wt-len-2

#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
0       0       0       0       -1      0       -4      0       0       0       0       0       0       0       #RecrDist_GP_1
0       0       0       0       -1      0       -4      0       0       0       0       0       0       0       #RecrDist_Area_1
0       0       0       0       -1      0       -4      0       0       0       0       0       0       0       #RecrDist_Seas_1
0       0       0       0       -1      0       -4      0       0       0       0       0       0       0       #CohortGrowDev
#
# custom-env read
#0  #   0=read one setup and apply to all env fxns; #1=read a setup line for each MGparm with Env-var>0
#
# custom-block read
#0  #   0=read one setup and apply to all MG-blocks;  #1=read a setup line for each block x MGparm with block>0
#
# Seasonal effects on biology parameters (0=none)
 0 0 0 0 0 0 0 0 0 0
#
#_Cond -4 #_MGparm_Dev_Phase
#
#_Spawner-Recruitment
3 #_SR_function: 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm
#
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE
7       13      10.3    10      -1      10      4       #_SR_LN(R0)
#0.2    1       0.6     0.6     -1      0.2     -4      #_SR_BH_steep (old model)
0.2     1       0.6     0.779   -2      0.152   -2      #_SR_BH_steep (Thorson prior turned off)
0       2       0.5     0.5     -1      0.8     -4      #_SR_sigmaR
-5      5       0       0       -1      1       -3      #_SR_envlink
-5      5       0       0       -1      1       -4      #_SR_R1_offset
-1      1       0       0       -1      100     -1      #_SR_autocorr
#
0     #_SR_env_link
0     #_SR_env_target_0=none;1=devs;_2=R0;_3=steepness
1     #_do_recdev:  0=none; 1=devvector; 2=simple deviations
1850  # first year of main recr_devs; early devs can preceed this era
2012  # last year of main recr_devs; forecast devs start in following year
6     #_recdev phase
1     # (0/1) to read 13 advanced options
 0    #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 -4   #_recdev_early_phase
 5   #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1    #_lambda for Fcast_recr_like occurring before endyr+1
 1859.5  #_last_early_yr_nobias_adj_in_MPD                   
 1918.4  #_first_yr_fullbias_adj_in_MPD                      
 2010.7  #_last_yr_fullbias_adj_in_MPD                       
 2012.1  #_first_recent_yr_nobias_adj_in_MPD                 
 0.072   #_max_bias_adj_in_MPD (1.0 to mimic pre-2009 models)
 0    #_period of cycles in recruitment (N parms read below)
 -5   #min rec_dev
 5    #max rec_dev
 0    #_read_recdevs
#_end of advanced SR options
#
#Fishing Mortality info
0.06 # F ballpark for annual F (=Z-M) for specified year
1999 # F ballpark year (neg value to disable)
1    # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
0.9  # max F or harvest rate, depends on F_Method
#
# init F setupforeachfleet
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE
0       1       0.00    0.01    -1       99      -1
0       1       0.00    0.01    -1       99      -1
0       1       0.00    0.01    -1       99      -1
0       1       0.00    0.01    -1       99      -1
#
#_Q_setup
 # Q_type options:  <0=mirror, 0=float_nobiasadj, 1=float_biasadj, 2=parm_nobiasadj, 3=parm_w_random_dev, 4=parm_w_randwalk, 5=mean_unbiased_float_assign_to_parm
#_for_env-var:_enter_index_of_the_env-var_to_be_linked
#_Den-dep  env-var  extra_se  Q_type
 0 0 0 0 # 1 NorthTrawl
 0 0 0 0 # 2 SouthTrawl
 0 0 0 0 # 3 NorthOther
 0 0 0 0 # 4 SouthOther
 0 0 1 0 # 5 Triennial1
 0 0 0 0 # 6 Triennial2
 0 0 0 0 # 7 AFSCslope
 0 0 0 0 # 8 NWFSCslope
 0 0 0 0 # 9 NWFSCcombo
#
#LO  HI      INIT    PRIOR   PR_type SD      PHASE
0.01 0.5     0.05    0.05    -1      0.1     4 # additive value for triennial survey

## #LO  HI      INIT    PRIOR   PR_type SD      PHASE
## -3   3       -0.5    -0.5    -1      2       2       #_Q_for_triennial_early
## -3   3       -0.5    -0.5    -1      2       2       #_Q_for_triennial_late
## -3   3       0       0.01    -1      2       2       #_Q_for_AFSC_slope_survey
## -3   3       0       0.01    -1      2       2       #_Q_for_NWFSC_slope_survey
## -3   3       0       0.01    -1      2       -2      #_Q_for_NWFSC_combo_survey
#### -3   3       -0.2231 0.01    -1      2       -2      #_Q_for_NWFSC_combo_survey
#
# SELEX & RETENTION PARAMETERS
#Pattern  Retention(0/1)  Male(0/1)  Special
# Size selex
24  1  0  0  # North Trawl
24  1  0  0  # South Trawl
24  1  0  0  # North Other
24  1  0  0  # South Other
24  0  0  0  # Triennial1
24  0  0  0  # Triennial2
24  0  0  0  # AFSC Slope survey
24  0  0  0  # NWFSC Slope survey
24  0  0  0  # NWFSC combo survey
# Age selex
10  0  0  0  # North Trawl
10  0  0  0  # South Trawl
10  0  0  0  # North Other
10  0  0  0  # South Other
10  0  0  0  # Triennial1
10  0  0  0  # Triennial2
10  0  0  0  # AFSC Slope survey
10  0  0  0  # NWFSC Slope survey
10  0  0  0  # NWFSC combo survey
#
#LO  HI  INIT  PRIOR  PR type  SD  PHASE  env-variable  use dev  dev minyr  dev maxyr  dev stddev  Block Pattern
#Size-Selectivity for North Trawl (double normal)
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       1       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       0       -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal

#Retention for North Trawl
5       70      23      27      -1      99      3       0       0       0       0       0       1       3       # infl_for_logistic
0.1     40      2       15      -1      99      3       0       0       0       0       0       0       0       # 95%width_for_logistic
0.0001  1       0.9     0.9     -1      99      3       0       0       0       0       0       1       3       # final
-3      3       0       0       -1      3       -4      0       0       0       0       0       0       0       # male_offset

#Size-Selectivity for South Trawl (double normal)
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       1       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       0       -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal

#Retention for South Trawl
5       70      23      27      -1      99      3       0       0       0       0       0       2       3       # infl_for_logistic
0.1     40      2       15      -1      99      3       0       0       0       0       0       0       0       # 95%width_for_logistic
0.0001  1       0.9     0.9     -1      99      3       0       0       0       0       0       2       3       # final
-3      3       0       0       -1      3       -4      0       0       0       0       0       0       0       # male_offset

#Size-Selectivity for North non-trawl (double normal)
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       2       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       0       -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal

#Retention for North non-trawl
5       70      23      27      -1      99      3       0       0       0       0       0       0       0       # infl_for_logistic
0.1     40      2       15      -1      99      3       0       0       0       0       0       0       0       # 95%width_for_logistic
0.0001  1       0.9     0.9     -1      99      3       0       0       0       0       0       0       0       # final
-3      3       0       0       -1      3       -4      0       0       0       0       0       0       0       # male_offset

#Size-Selectivity for South non-trawl (double normal)
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       2       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       0       -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal
#Retention for South non-trawl
5       70      23      27      -1      99      3       0       0       0       0       0       3       3       # infl_for_logistic
0.1     40      2       15      -1      99      3       0       0       0       0       0       0       0       # 95%width_for_logistic
0.0001  1       0.9     0.9     -1      99      3       0       0       0       0       0       3       3       # final
-3      3       0       0       -1      3       -4      0       0       0       0       0       0       0       # male_offset

#Size-Selectivity for Triennial1
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       2       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       -7      -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal

#Size-Selectivity for Triennial2
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       2       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       0       -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal
#Size-Selectivity for AK slope
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       2       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       -7      -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal
#Size-Selectivity for NW slope
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       2       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       0       -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal
#Size-Selectivity for NW combo
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_min dev_max dev_SD  Block   Block_Fxn
10      60      30      30      -1      5       2       0       0       0       0       0       0       0       # SizeSel_3P_1_Type24_size_double-normal
-7      7       0       -0.5    -1      2       3       0       0       0       0       0       0       0       # SizeSel_3P_2_Type24_size_double-normal
-5      10      3       1.75    -1      5       3       0       0       0       0       0       0       0       # SizeSel_3P_3_Type24_size_double-normal
-5      10      5       0.1     -1      2       4       0       0       0       0       0       0       0       # SizeSel_3P_4_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_5_Type24_size_double-normal
-999    15      -999    0       -1      5       -99     0       0       0       0       0       0       0       # SizeSel_3P_6_Type24_size_double-normal
#
1 #_custom_sel-blk_setup (0/1)
#### BLOCK PARAMETERS FOR EACH FLEET
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE
-10     10      0       0       0       5       4       #       Retain_1P_1_NorthTrawl_BLK1delta_1989
-10     10      0       0       0       5       4       #       Retain_1P_1_NorthTrawl_BLK1delta_1996
-0.5    0.5     0       0       0       0.2     4       #       Retain_1P_3_NorthTrawl_BLK2delta_1989
-0.5    0.5     0       0       0       0.2     4       #       Retain_1P_3_NorthTrawl_BLK2delta_1996
#
-10     10      0       0       0       5       4       #       Retain_1P_1_NorthTrawl_BLK1delta_1989
-10     10      0       0       0       5       4       #       Retain_1P_1_NorthTrawl_BLK1delta_1996
-0.5    0.5     0       0       0       0.2     4       #       Retain_1P_3_NorthTrawl_BLK2delta_1989
-0.5    0.5     0       0       0       0.2     4       #       Retain_1P_3_NorthTrawl_BLK2delta_1996
#
-10     10      0       0       0       5       4       #       Retain_4P_1_SouthOther_BLK1delta_1989
-0.5    0.5     0       0       0       0.2     4       #       Retain_4P_3_SouthOther_BLK2delta_1989
#
# 3 #_selparm_Dev_Phase
2 #_env/block/dev_adjust_method (1=standard; 2=logistic trans to keep in base parm bounds; 3=standard w/ no bound check)
#
0  # TG_custom
1 #_Variance_adjustments_to_input_values
#_fleet: 1 2 3 4 5 6 7 8 9
  0 0 0 0 0 0 0 0 0 #_add_to_survey_CV
  0 0 0 0 0 0 0 0 0 #_add_to_discard_stddev
  0 0 0 0 0 0 0 0 0 #_add_to_bodywt_CV
0.5595 0.9773 0.5422 0.4024 0.6812 0.6494 1 0.5126 1 #_mult_by_lencomp_N
#  1 1 1 1 1 1 1 1 1 #_mult_by_lencomp_N
  1 1 1 1 1 1 1 1 1 #_mult_by_agecomp_N
  1 1 1 1 1 1 1 1 1 #_mult_by_size-at-age_N
5  # max lambda phases: read this Number of values for each componentxtype below
1  # include (1) or not (0) the constant offset For Log(s) in the Log(like) calculation
#
3 # number of changes to make to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark
#like_comp fleet/survey  phase  value  sizefreq_method
17          999           2     0.1      999
17          999           3     0.01     999
17          999           5     0        999

# survey lambdas
#   0  0  .75  .75  1  1
# discard lambdas
#  1  1  0  0  0  0
# meanbodywt
#1
# lenfreq lambdas
#  1  1  1  1  1  1
# age freq lambdas
#  0  0  0  0  0  0
# size@age lambdas
#  0  0  0  0  0  0
# initial equil catch
#0
# recruitment lambda
#1
# parm prior lambda
#1
# parm dev timeseries lambda
#0
# crashpen lambda
#100
#max F
#0.9
#
0 # extra SD pointer
#
999  # end-of-file
