#C forecast file written by R function SS_writeforecast
#C rerun model to get more complete formatting in forecast.ss_new
#C should work with SS version: 3.3
#C file write time: 2023-07-13 13:25:47
#
1 #_benchmarks
2 #_MSY
0.5 #_SPRtarget
0.4 #_Btarget
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF,  beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
0 0 0 0 0 0 0 0 0 0
1 #_Bmark_relF_Basis
1 #_Forecast
12 #_Nforecastyrs
1 #_F_scalar
#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_recruits, end_recruits (enter actual year, or values of 0 or -integer to be rel. endyr)
0 0 0 0 -999 0
0 #_Fcast_selex
3 #_ControlRuleMethod
0.4 #_BforconstantF
0.1 #_BfornoF
1 #_Flimitfraction
3 #_N_forecast_loops
3 #_First_forecast_loop_with_stochastic_recruitment
0 #_fcast_rec_option
1 #_fcast_rec_val
0 #_Fcast_MGparm_averaging
2025 #_FirstYear_for_caps_and_allocations
0 #_stddev_of_log_catch_ratio
0 #_Do_West_Coast_gfish_rebuilder_output
1999 #_Ydecl
1 #_Yinit
1 #_fleet_relative_F
# Note that fleet allocation is used directly as average F if Do_Forecast=4 
2 #_basis_for_fcast_catch_tuning
# enter list of fleet number and max for fleets with max annual catch; terminate with fleet=-9999
-9999 -1
# enter list of area ID and max annual catch; terminate with area=-9999
-9999 -1
# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
-9999 -1
2 #_InputBasis
 #_Year Seas Fleet Catch or F
   2023    1     1   488.4200
   2023    1     2   133.3200
   2023    1     3   134.3700
   2024    1     1   488.4200
   2024    1     2   133.3200
   2024    1     3   134.3700
   2025    1     1   599.6070
   2025    1     2   120.5460
   2025    1     3    95.1653
   2026    1     1   605.6050
   2026    1     2   122.0000
   2026    1     3    97.1614
   2027    1     1   611.4960
   2027    1     2   123.4670
   2027    1     3    99.4359
   2028    1     1   616.5940
   2028    1     2   124.7990
   2028    1     3   101.8560
   2029    1     1   620.9350
   2029    1     2   125.9980
   2029    1     3   104.3930
   2030    1     1   624.5650
   2030    1     2   127.0710
   2030    1     3   107.0150
   2031    1     1   628.2910
   2031    1     2   128.1860
   2031    1     3   109.8170
   2032    1     1   630.6360
   2032    1     2   129.0420
   2032    1     3   112.4970
   2033    1     1   632.3960
   2033    1     2   129.8070
   2033    1     3   115.1450
   2034    1     1   634.3900
   2034    1     2   130.6500
   2034    1     3   117.8680
-9999 0 0 0
#
999 # verify end of input 
