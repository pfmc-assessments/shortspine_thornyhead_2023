if(FALSE){
  wd <- "c:/SS/Thornyheads/runs/forecasts/cat2_and_DeVore_Dec2013"
  setwd(wd)

  # getting 2014
  ave.catch <- c(405.2,307.2,32.6,207.5) # average of 2011-2012 by fleet
  sum(ave.catch)
  ## [1] 952.5
  ACL.2014 <- 393+1525 # south+north from DeVore's projection request
  ACL.2014
  ## [1] 1918
  round(ave.catch*ACL.2014/sum(ave.catch),1)
  ## [1] 815.9 618.6  65.6 417.8
  data.frame(Year=sort(rep(2015:2024,4)),Seas=1, Fleet=1:4,
             Catch=round(ave.catch*ACL.2014/sum(ave.catch),1))

  s.ave.b <- SS_output('SST_base_Ave',covar=FALSE)
  s.ave.l <- SS_output('SST_low_Ave',covar=FALSE)
  s.ave.h <- SS_output('SST_high_Ave',covar=FALSE)

  # list of scenarios
  scens2 <- c("2014ACL",
              "Ave",
              "SPR50_Pstar25",
              "SPR50_Pstar40",
              "SPR50_Pstar45",
              "SPR65_Pstar40")

  # list without average catch scenario, which was already done
  scens <- c("2014ACL",
             #"Ave",
             "SPR50_Pstar25",
             "SPR50_Pstar40",
             "SPR50_Pstar45",
             "SPR65_Pstar40")
  
  states <- c("SST_base_","SST_low_","SST_high_")

  for(scen in scens){
    forefile <- paste("forecast_",scen,".ss",sep="")
    for(state in states){
      newfile <- file.path(paste(state,scen,sep=""),"forecast.ss")
      cat("copying",forefile,"to",newfile,"\n")
      file.copy(forefile, newfile, overwrite=TRUE)
    }
  }

  ## copying forecast_2014ACL.ss to SST_base_2014ACL/forecast.ss 
  ## copying forecast_2014ACL.ss to SST_low_2014ACL/forecast.ss 
  ## copying forecast_2014ACL.ss to SST_high_2014ACL/forecast.ss 
  ## copying forecast_SPR50_Pstar25.ss to SST_base_SPR50_Pstar25/forecast.ss 
  ## copying forecast_SPR50_Pstar25.ss to SST_low_SPR50_Pstar25/forecast.ss 
  ## copying forecast_SPR50_Pstar25.ss to SST_high_SPR50_Pstar25/forecast.ss 
  ## copying forecast_SPR50_Pstar40.ss to SST_base_SPR50_Pstar40/forecast.ss 
  ## copying forecast_SPR50_Pstar40.ss to SST_low_SPR50_Pstar40/forecast.ss 
  ## copying forecast_SPR50_Pstar40.ss to SST_high_SPR50_Pstar40/forecast.ss 
  ## copying forecast_SPR50_Pstar45.ss to SST_base_SPR50_Pstar45/forecast.ss 
  ## copying forecast_SPR50_Pstar45.ss to SST_low_SPR50_Pstar45/forecast.ss 
  ## copying forecast_SPR50_Pstar45.ss to SST_high_SPR50_Pstar45/forecast.ss 
  ## copying forecast_SPR65_Pstar40.ss to SST_base_SPR65_Pstar40/forecast.ss 
  ## copying forecast_SPR65_Pstar40.ss to SST_low_SPR65_Pstar40/forecast.ss 
  ## copying forecast_SPR65_Pstar40.ss to SST_high_SPR65_Pstar40/forecast.ss
  
  # run models
  for(scen in scens){
    for(state in states){
      setwd(file.path(wd,paste(state,scen,sep="")))
      cat("running model in",getwd(),"\n")
      system("SS3 -nohess -phase 10 -nox")
    }
  }



  # get productivity info for Isaac
  reps1 <- list(s.ave.b, s.ave.l, s.ave.h)
  reps1[[2]]$parameters$Value[reps1[[2]]$parameters$Label=="SR_LN(R0)"]
  reps1[[1]]$parameters$Value[reps1[[1]]$parameters$Label=="SR_LN(R0)"]
  reps1[[3]]$parameters$Value[reps1[[3]]$parameters$Label=="SR_LN(R0)"]
  modsum1 <- SSsummarize(reps1)
  SStableComparisons(modsum1,models=c(2,1,3),
                     names= c("NatM", "steep", "Bratio_2013") ,likenames=NULL)
  ## running SStableComparisons
  ## name=NatM: added 4 rows
  ## name=steep: added 1 row
  ## name=Bratio_2013: added 1 row
  ##               Label   model1   model2   model3
  ## 1 NatM_p_1_Fem_GP_1 0.050500 0.050500 0.050500
  ## 2 NatM_p_2_Fem_GP_1 0.000000 0.000000 0.000000
  ## 3 NatM_p_1_Mal_GP_1 0.000000 0.000000 0.000000
  ## 4 NatM_p_2_Mal_GP_1 0.000000 0.000000 0.000000
  ## 5       SR_BH_steep 0.600000 0.600000 0.600000
  ## 6       Bratio_2013 0.546212 0.741723 0.889376

  
  # get results
  reps <- list()
  for(scen in scens2){
    for(state in states){
      cat("getting model from",state,scen,"\n")
      mod <- SS_output(file.path(wd,paste(state,scen,sep="")),
                       covar=FALSE,verbose=FALSE,printstats=FALSE)
      reps[[paste(state,scen,sep="")]] <- mod
    }
  }
  
  # plot comparisons
  names(reps)
  reps2 <- reps
  names(reps2) <- NULL
  modsum <- SSsummarize(reps2)
  SSplotComparisons(modsum,endyrvec=2024,subplot=1,xlim=c(2013,2024),ylimAdj=1)



}

getstuff2 <- function(replist, yrs=2015:2024){
  # subset timeseries
  ts <- replist$timeseries[replist$timeseries$Yr %in% yrs,]
  catch <- apply(ts[,grep("dead(B)",names(ts),fixed=TRUE)], 1, sum)
  yr <- ts$Yr
  # spawning biomass
  SpawnBio <- ts$SpawnBio
  # depletion
  SpawnBioVirg <- replist$timeseries$SpawnBio[replist$timeseries$Era=="VIRG"]
  dep <- SpawnBio/SpawnBioVirg
  # total biomass
  Bio_all <- ts$Bio_all
  # combine
  stuff <- data.frame(yr=yr[ts$Area==1], catch, dep, SpawnBio, Bio_all)
  stuff <- data.frame(catch, dep, SpawnBio, Bio_all)
  return(stuff)
}

if(FALSE){
  options(width=200)

  cbind(getstuff2(reps[["SST_low_SPR50_Pstar45"]]),
        getstuff2(reps[["SST_base_SPR50_Pstar45"]]),
        getstuff2(reps[["SST_high_SPR50_Pstar45"]]))
        catch       dep SpawnBio Bio_all    catch       dep SpawnBio Bio_all    catch       dep SpawnBio Bio_all
1122.714 0.5364669  54573.7 93842.8 2924.392 0.7376334   139977  242871 8481.254 0.8885679   405107  705793
1114.218 0.5310465  54022.3 92965.2 2893.020 0.7298975   138509  240297 8372.818 0.8788160   400661  697677
1106.320 0.5259545  53504.3 92126.7 2862.360 0.7224198   137090  237773 8265.244 0.8692549   396302  689636
1099.097 0.5211545  53016.0 91328.0 2832.570 0.7151530   135711  235302 8159.009 0.8598320   392006  681680
1092.601 0.5166060  52553.3 90569.2 2803.774 0.7080494   134363  232884 8054.491 0.8504968   387750  673817
1086.864 0.5122788  52113.1 89850.4 2776.042 0.7010724   133039  230522 7951.963 0.8412187   383520  666053
1081.904 0.5081669  51694.8 89171.0 2749.443 0.6942218   131739  228216 7851.646 0.8320019   379318  658394
1077.713 0.5042761  51299.0 88530.4 2723.982 0.6875082   130465  225967 7753.684 0.8228598   375150  650847
1074.268 0.5006105  50926.1 87927.5 2699.631 0.6809422   129219  223775 7658.143 0.8138185   371028  643417
1071.533 0.4971670  50575.8 87361.4 2676.386 0.6745290   128002  221639 7565.082 0.8048913   366958  636107

  cbind(getstuff2(reps[["SST_low_SPR50_Pstar25"]]),
        getstuff2(reps[["SST_base_SPR50_Pstar25"]]),
        getstuff2(reps[["SST_high_SPR50_Pstar25"]]))
        catch       dep SpawnBio Bio_all    catch       dep SpawnBio Bio_all    catch       dep SpawnBio Bio_all
756.2640 0.5364669  54573.7 93842.8 1969.878 0.7376334   139977  242871 5713.003 0.8885679   405107  705793
754.6755 0.5331649  54237.8 93362.4 1959.489 0.7328485   139069  241333 5670.952 0.8823759   402284  700688
753.4499 0.5301844  53934.6 92917.8 1949.399 0.7283061   138207  239834 5628.863 0.8763440   399534  695617
752.6303 0.5274841  53659.9 92509.4 1939.698 0.7239428   137379  238374 5586.966 0.8704108   396829  690585
752.2457 0.5250236  53409.6 92137.2 1930.448 0.7197165   136577  236954 5545.468 0.8645215   394144  685596
752.3147 0.5227715  53180.5 91801.0 1921.684 0.7155903   135794  235574 5504.480 0.8586410   391463  680653
752.8430 0.5207190  52971.7 91500.1 1913.426 0.7115485   135027  234234 5464.111 0.8527670   388785  675761
753.8215 0.5188719  52783.8 91234.0 1905.671 0.7076068   134279  232934 5424.415 0.8469084   386114  670923
755.2367 0.5172342  52617.2 91001.7 1898.401 0.7037705   133551  231675 5385.434 0.8410871   383460  666141
757.0600 0.5157990  52471.2 90801.9 1891.591 0.7000395   132843  230455 5347.171 0.8353162   380829  661418

  cbind(getstuff2(reps[["SST_low_SPR50_Pstar40"]]),
        getstuff2(reps[["SST_base_SPR50_Pstar40"]]),
        getstuff2(reps[["SST_high_SPR50_Pstar40"]]))
         catch       dep SpawnBio Bio_all    catch       dep SpawnBio Bio_all    catch       dep SpawnBio Bio_all
1024.3375 0.5364669  54573.7 93842.8 2668.144 0.7376334   139977  242871 7738.095 0.8885679   405107  705793
1018.0915 0.5316147  54080.1 93071.8 2643.436 0.7306932   138660  240575 7650.435 0.8797723   401097  698485
1012.3661 0.5270879  53619.6 92338.7 2619.281 0.7239955   137389  238325 7563.290 0.8711544   397168  691239
1007.2330 0.5228472  53188.2 91643.9 2595.835 0.7175032   136157  236123 7477.056 0.8626615   393296  684061
1002.7391 0.5188532  52781.9 90987.7 2573.202 0.7111638   134954  233970 7392.057 0.8542388   389456  676960
998.9113 0.5150745  52397.5 90369.9 2551.449 0.7049403   133773  231868 7308.543 0.8458599   385636  669942
995.7603 0.5115042  52034.3 89790.1 2530.613 0.6988328   132614  229816 7226.680 0.8375228   381835  663011
993.2827 0.5081492  51693.0 89247.6 2510.702 0.6928411   131477  227816 7146.609 0.8292426   378060  656174
991.4573 0.5050134  51374.0 88741.5 2491.709 0.6869865   130366  225866 7068.380 0.8210414   374321  649434
990.2483 0.5020919  51076.8 88270.6 2473.599 0.6812742   129282  223969 6992.018 0.8129346   370625  642796

 cbind(getstuff2(reps[["SST_low_2014ACL"]]),
       getstuff2(reps[["SST_base_2014ACL"]]),
       getstuff2(reps[["SST_high_2014ACL"]]))
     catch       dep SpawnBio Bio_all  catch       dep SpawnBio Bio_all  catch       dep SpawnBio Bio_all
1917.9 0.5364669  54573.7 93842.8 1917.9 0.7376334   139977  242871 1917.9 0.8885679   405107  705793
1917.9 0.5264509  53554.8 92101.5 1917.9 0.7330119   139100  241388 1917.9 0.8872585   404510  704814
1917.9 0.5166385  52556.6 90380.1 1917.9 0.7285906   138261  239932 1917.9 0.8861223   403992  703863
1917.9 0.5070020  51576.3 88680.7 1917.9 0.7243275   137452  238503 1917.9 0.8850914   403522  702939
1917.9 0.4975090  50610.6 87005.3 1917.9 0.7201697   136663  237104 1917.9 0.8841043   403072  702040
1917.9 0.4881429  49657.8 85355.6 1917.9 0.7160751   135886  235734 1917.9 0.8831173   402622  701165
1917.9 0.4789055  48718.1 83732.9 1917.9 0.7120438   135121  234394 1917.9 0.8821149   402165  700312
1917.9 0.4698146  47793.3 82138.0 1917.9 0.7080810   134369  233085 1917.9 0.8811081   401706  699480
1917.9 0.4608839  46884.8 80571.6 1917.9 0.7041973   133632  231807 1917.9 0.8801035   401248  698667
1917.9 0.4521164  45992.9 79033.9 1917.9 0.7003979   132911  230560 1917.9 0.8791121   400796  697873

 cbind(getstuff2(reps[["SST_low_Ave"]]),
       getstuff2(reps[["SST_base_Ave"]]),
       getstuff2(reps[["SST_high_Ave"]]))
catch       dep SpawnBio Bio_all catch       dep SpawnBio Bio_all catch       dep SpawnBio Bio_all
952.5 0.5364669  54573.7 93842.8 952.5 0.7376334   139977  242871 952.5 0.8885679   405107  705793
952.5 0.5320315  54122.5 93148.8 952.5 0.7359945   139666  242437 952.5 0.8884999   405076  705866
952.5 0.5278891  53701.1 92486.4 952.5 0.7346086   139403  242041 952.5 0.8886228   405132  705976
952.5 0.5240032  53305.8 91856.5 952.5 0.7334124   139176  241683 952.5 0.8888684   405244  706123
952.5 0.5203356  52932.7 91259.9 952.5 0.7323584   138976  241362 952.5 0.8891711   405382  706302
952.5 0.5168606  52579.2 90697.0 952.5 0.7314046   138795  241077 952.5 0.8894870   405526  706512
952.5 0.5135725  52244.7 90168.0 952.5 0.7305404   138631  240828 952.5 0.8897962   405667  706749
952.5 0.5104829  51930.4 89673.0 952.5 0.7297658   138484  240615 952.5 0.8901077   405809  707010
952.5 0.5075977  51636.9 89211.6 952.5 0.7290860   138355  240436 952.5 0.8904301   405956  707293
952.5 0.5049161  51364.1 88783.5 952.5 0.7285063   138245  240289 952.5 0.8907679   406110  707596
 

 
options(width=80)
}
