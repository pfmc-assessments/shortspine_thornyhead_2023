#C forecast file written by R function SS_writeforecast
#C rerun model to get more complete formatting in forecast.ss_new
#C should work with SS version: 3.3
#C file write time: 2023-06-19 19:43:32
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
   2025    1     1   522.7690
   2025    1     2   105.0980
   2025    1     3    82.9702
   2026    1     1   523.8770
   2026    1     2   105.5360
   2026    1     3    84.0594
   2027    1     1   524.8500
   2027    1     2   105.9740
   2027    1     3    85.3680
   2028    1     1   525.0120
   2028    1     2   106.2660
   2028    1     3    86.7619
   2029    1     1   525.1460
   2029    1     2   106.5670
   2029    1     3    88.3380
   2030    1     1   524.5710
   2030    1     2   106.7360
   2030    1     3    89.9472
   2031    1     1   523.3320
   2031    1     2   106.7850
   2031    1     3    91.5556
   2032    1     1   521.4680
   2032    1     2   106.7220
   2032    1     3    93.1280
   2033    1     1   519.0140
   2033    1     2   106.5580
   2033    1     3    94.6294
   2034    1     1   516.4920
   2034    1     2   106.4000
   2034    1     3    96.1183
-9999 0 0 0
#
999 # verify end of input 
