#C forecast file written by R function SS_writeforecast
#C rerun model to get more complete formatting in forecast.ss_new
#C should work with SS version: 3.3
#C file write time: 2023-06-09 11:03:54
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
   2023    1     1    488.420
   2023    1     2    133.320
   2023    1     3    134.370
   2024    1     1    488.420
   2024    1     2    133.320
   2024    1     3    134.370
   2025    1     1    636.249
   2025    1     2    128.133
   2025    1     3    101.125
   2026    1     1    641.560
   2026    1     2    129.569
   2026    1     3    103.094
   2027    1     1    646.620
   2027    1     2    130.999
   2027    1     3    105.302
   2028    1     1    650.724
   2028    1     2    132.262
   2028    1     3    107.608
   2029    1     1    653.923
   2029    1     2    133.353
   2029    1     3    109.983
   2030    1     1    656.282
   2030    1     2    134.279
   2030    1     3    112.397
   2031    1     1    658.666
   2031    1     2    135.213
   2031    1     3    114.954
   2032    1     1    659.543
   2032    1     2    135.844
   2032    1     3    117.342
   2033    1     1    659.765
   2033    1     2    136.349
   2033    1     3    119.662
   2034    1     1    660.205
   2034    1     2    136.915
   2034    1     3    122.031
-9999 0 0 0
#
999 # verify end of input 
