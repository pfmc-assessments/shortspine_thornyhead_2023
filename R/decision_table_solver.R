#library(r4ss)
#wd = "C:/Assessments/2021/dover_sole_2021/models/_decision_tables"
#dir = file.path(wd, "7.0.1_base_m")
#
#find_para(dir = dir, 
#		  yr = 2021, 
#		  parm = c("MGparm[1]"), quant = c(0.875), 
#		  ctl_name = "2021_dover.ctl", 
#		  parm_string = "NatM_p_1_Fem_GP_1", 
#		  est = FALSE,
#		  sigma = 0.50)
#' @param dir the directory pointing to the model
#' @param base object created by SS_output. If left blank the model located in the dir
#' location will be defined as the base object
#' @param yr the year to calculate the 12.5 and 87.5 percentiles around
#' @param parm the par.ss file parameter name
#' @param quant the quantiles to use - not directly used in the current code
#' @param ctl_name if you need to turn off a parameter (R0) this will be done in the named
#' control file
#' @param parm_string parameter name from the control file for the parameter to turn off
#' @param est turns off the parameter in the control file default value is FALSE
#' @param sigma sigma value to use, options are 0.50, 1.0, or if left blank will use the Pstar_sigma

find_para <- function(dir, base, yr = 2023, parm = c("MGparm[1]"), 
                      quant = c(0.125, 0.875), 
                      ctl_name, parm_string, est = FALSE, sigma, 
                      tol = 0.005, use_115 = TRUE)
{
  
  for (tt in 1:length(quant)){
    
    dec_dir <- paste0(dir, "_", parm, "_decision_table_1.15_", sigma, "_", quant[tt])
    dir.create(dec_dir, showWarnings = FALSE)
    
    # Check for existing files and delete
    if (length(list.files(dec_dir)) != 0) { 
      remove <- list.files(dec_dir) 
      file.remove(file.path(dec_dir, remove)) 
    }
    
    all_files <- list.files(dir)
    capture.output(file.copy(from = file.path(dir, all_files), 
                             to = dec_dir, overwrite = TRUE), file = "run_diag_warning.txt")
    message(paste0( "Running search for ", parm, " solved for ", quant[tt], ".") )
    
    setwd(dec_dir)
    
    starter <- r4ss::SS_readstarter(file.path(dec_dir, 'starter.ss'))
    if(!missing(ctl_name)) {
      r4ss::SS_changepars(ctlfile = ctl_name, 
                          newctlfile = paste0("_mod_", ctl_name), 
                          strings = parm_string,  
                          estimate = est)
      starter$ctlfile = paste0("_mod_", ctl_name)
    }
    
    starter$init_values_src <- 1 # run from the par file
    r4ss::SS_writestarter(starter, dir = dec_dir, overwrite=TRUE)
    
    # This should always read the base model in the dir folder
    base = r4ss::SS_output(dir, printstats = FALSE, verbose = FALSE, covar = FALSE)	
    par.name = "ss.par"
    
    sb = base$derived_quants[grep(paste0('SSB_', yr), base$derived_quants$Label), c("Value", "StdDev")]
    #target = round(qnorm(quant[tt], mean = sb[,"Value"], sd = sb[,"StdDev"]), 1)
    
    if(missing(sigma)){
      sigma = round(base$Pstar_sigma,2)
    }
    
    if(quant[tt] == 0.125) {
      target = sb$Value/(exp(1.15*sigma))			
    } else {
      target = sb$Value/(exp(-1.15*sigma))
    }
    
    #if (!use_115){
    #	target = exp(qlnorm(quant[tt], mean = sb[,"Value"], sd = sb[,"StdDev"]))
    #}
    
    for(a in 1:100){
      
      if(a == 1){
        find_sb = as.numeric(sb["Value"])
      }else{
        low = SS_output(dec_dir, printstats = FALSE, verbose = FALSE, covar = FALSE)
        find_sb = low$derived_quants[grep(paste0('SSB_', yr), low$derived_quants$Label), "Value"]
      }
      
      print(paste0("!!!!!!!!!!!   SB = ", find_sb, " vs Target = ", target, "    !!!!!!!!!!!"))	
      if (find_sb > target - target * tol & find_sb < target + target * tol){
        print(paste0("Found solution -- parameter value = ", temp, " matches target SB in ", yr))
        write.table(paste(parm, "=", temp, "for Target SB = ", target), 
                    file = file.path(dec_dir, "_Solved_Param_Value.txt"))
        break()
      }
      
      rawpar    <- readLines(file.path(dec_dir, "ss.par"))
      which_line <- NULL
      for(pp in 1:length(parm)){
        temp = grep(parm[pp], rawpar, fixed = TRUE) + 1
        which_line = c(which_line, temp)
      }
      temp = as.numeric(rawpar[which_line])
      
      if(temp[1] < 0.40) {
        step.size = ifelse(find_sb > target - target * 0.05 & find_sb < target + target * 0.05,
                           ifelse(find_sb > target - target* 0.02 & find_sb < target + target * 0.02,
                                  0.0002, 0.001), 0.002)
      } else {
        step.size =ifelse(find_sb > target - target * 0.05 & find_sb < target + target * 0.05, 
                          ifelse(find_sb > target - target* 0.02 & find_sb < target + target * 0.02,
                                 0.0005, 0.005), 0.02)			
      }
      
      value = ifelse( find_sb > target, temp - step.size,
                      ifelse (find_sb < target, temp + step.size, temp))
      print(paste0("!!!!!!!!!!!  ", value, "  !!!!!!!!!!!"))
      temp = value
      rawpar[which_line] = temp
      writeLines(rawpar, con = file.path(dec_dir, "ss.par"))
      shell("ss -nohess -maxfun 0 > output.txt 2>&1")  
      
      #if(!missing(parm_string)){
      #  if (parm_string == "SR_BH_steep" & value == 1.0){
      #    print("Hit the upper bound for steepness")
      #    break()
      #  }
      #}  
    } # end a loop
  } # end tt loop
  
} # close function