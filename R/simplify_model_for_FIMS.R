# read 2023 assessment
new_inputs <- inputs <- r4ss::SS_read(
  "https://raw.githubusercontent.com/pfmc-assessments/shortspine_thornyhead_2023/refs/heads/main/model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/run/",
  #"model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/run",
  ss_new = FALSE
)
output <- r4ss::SS_output(
  "https://raw.githubusercontent.com/pfmc-assessments/shortspine_thornyhead_2023/refs/heads/main/model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/run/"
  # "model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/run"
)

#######################################
### control file changes
#######################################

# use average parameters across sexes
# first confirm that all parameters are fixed
inputs$ctl$MG_parms |> dplyr::pull(PHASE) |> unique()
# [1]  -3  -2  -4 -99

# compare female and male parameters
compare <- cbind(
  inputs$ctl$MG_parms |>
    dplyr::filter(
      grepl("_Fem_", rownames(inputs$ctl$MG_parms)) &
        !grepl("^Mat", rownames(inputs$ctl$MG_parms)),
      !grepl("^Eggs", rownames(inputs$ctl$MG_parms))
    ) |>
    dplyr::select(INIT) |>
    dplyr::rename(female = INIT),
  inputs$ctl$MG_parms |>
    dplyr::filter(grepl("_Mal_", rownames(inputs$ctl$MG_parms))) |>
    dplyr::select(INIT) |>
    dplyr::rename(male = INIT)
)

compare
#                         female        male
# NatM_p_1_Fem_GP_1   0.04000000  0.04000000
# NatM_p_2_Fem_GP_1   0.04000000  0.04000000
# L_at_Amin_Fem_GP_1 11.38320000  9.17330000
# L_at_Amax_Fem_GP_1 73.60790000 66.07280000
# VonBert_K_Fem_GP_1  0.00989856  0.01678540
# CV_young_Fem_GP_1   0.10903400  0.10903400
# CV_old_Fem_GP_1     0.10903400  0.10903400
# Wtlen_1_Fem_GP_1    0.00000486  0.00000496
# Wtlen_2_Fem_GP_1    3.26000000  3.25000000

# only parameters related to mean growth differ between sexes
names_that_differ <- compare |> dplyr::filter(female != male) |> rownames()
#  [1] "L_at_Amin_Fem_GP_1" "L_at_Amax_Fem_GP_1" "VonBert_K_Fem_GP_1" "Wtlen_1_Fem_GP_1"   "Wtlen_2_Fem_GP_1"

# create new dataframe that only has female parameters and
# replace those that differ by the average of female and male values
new_MG_parms <- female_MG_parms <- inputs$ctl$MG_parms |>
  dplyr::filter(
    !grepl("_Mal_", rownames(inputs$ctl$MG_parms))
  )
male_MG_params <- inputs$ctl$MG_parms |>
  dplyr::filter(grepl("_Mal_", rownames(inputs$ctl$MG_parms)))

for (name in names_that_differ) {
  new_MG_parms[name, "INIT"] <- mean(c(
    female_MG_parms[name, "INIT"],
    male_MG_params[gsub("_Fem_", "_Mal_", name), "INIT"]
  ))
}

# confirm that the new parameters have the averaged values
data.frame(
  female = female_MG_parms[1:9, "INIT"],
  new = new_MG_parms[1:9, "INIT"],
  male = male_MG_params[, "INIT"]
)
#        female         new        male
# 1  0.04000000  0.04000000  0.04000000
# 2  0.04000000  0.04000000  0.04000000
# 3 11.38320000 10.27825000  9.17330000
# 4 73.60790000 69.84035000 66.07280000
# 5  0.00989856  0.01334198  0.01678540
# 6  0.10903400  0.10903400  0.10903400
# 7  0.10903400  0.10903400  0.10903400
# 8  0.00000486  0.00000491  0.00000496
# 9  3.26000000  3.25500000  3.25000000

# remove fecundity relationship
# option 1 is eggs=W*(a+b*W), so a = 1, b = 0 results in eggs = W (proportional to body weight)
new_MG_parms[rownames(new_MG_parms) == "Eggs_alpha_Fem_GP_1", "INIT"] <- 1
new_MG_parms[rownames(new_MG_parms) == "Eggs_beta_Fem_GP_1", "INIT"] <- 0
# update the table of mortality and growth parameters
new_inputs$ctl$MG_parms <- new_MG_parms
# update the fecundity option
new_inputs$ctl$fecundity_option <- 1 # was 2

# selectivity: remove discard/retention parameters and male parameters
new_inputs$ctl$size_selex_types
#            Pattern Discard Male Special
# Trawl_N         24       1    0       0
# Trawl_S         24       1    0       0
# Non-trawl       24       1    0       0
# Triennial1      24       0    3       0
# Triennial2      24       0    3       0
# NWFSCcombo      24       0    3       0
new_inputs$ctl$size_selex_types <- new_inputs$ctl$size_selex_types |>
  dplyr::mutate(Discard = 0, Male = 0)

new_inputs$ctl$size_selex_parms <- new_inputs$ctl$size_selex_parms |>
  dplyr::filter(
    !grepl("PMalOff|PRet", rownames(new_inputs$ctl$size_selex_parms))
  )
# confirm that there are 36 parameters (6 fleets x 6 double-normal parameters)
new_inputs$ctl$size_selex_parms |> nrow()
# [1] 36
# remove time-varying retention parameters (leaves behind 4 trawl selectivity t-v parameters)
new_inputs$ctl$size_selex_parms_tv <- new_inputs$ctl$size_selex_parms_tv |>
  dplyr::filter(
    !grepl("PMalOff|PRet", rownames(new_inputs$ctl$size_selex_parms_tv))
  )

new_inputs$ctl$Nsexes <- -1

# simplify recruitment bias adjustment settings
new_inputs$ctl$max_bias_adj <- -1 # set bias adjust = 1.0 for all years

#######################################
### data file changes
#######################################

# combine female and male comps
new_inputs$dat$Nsexes <- -1 # -1 means combine sexes but apply sex ratio to spawning output
new_inputs$dat |> names()

#  [1] "sourcefile"              "type"                    "ReadVersion"
#  [4] "Comments"                "styr"                    "endyr"
#  [7] "nseas"                   "months_per_seas"         "Nsubseasons"
# [10] "spawn_month"             "Nsexes"                  "Nages"
# [13] "N_areas"                 "Nfleets"                 "fleetinfo"
# [16] "fleetnames"              "surveytiming"            "units_of_catch"
# [19] "areas"                   "catch"                   "CPUEinfo"
# [22] "CPUE"                    "N_discard_fleets"        "discard_fleet_info"
# [25] "discard_data"            "use_meanbodywt"          "DF_for_meanbodywt"
# [28] "meanbodywt"              "lbin_method"             "binwidth"
# [31] "minimum_size"            "maximum_size"            "use_lencomp"
# [34] "len_info"                "N_lbins"                 "lbin_vector"
# [37] "lencomp"                 "N_agebins"               "use_MeanSize_at_Age_obs"
# [40] "N_environ_variables"     "N_sizefreq_methods_rd"   "N_sizefreq_methods"
# [43] "do_tags"                 "morphcomp_data"          "use_selectivity_priors"
# [46] "eof"                     "spawn_seas"              "Nfleet"
# [49] "Nsurveys"                "fleetinfo1"              "fleetinfo2"
# [52] "comp_tail_compression"   "add_to_comp"             "max_combined_lbin"
# [55] "N_MeanSize_at_Age_obs"   "N_lbinspop"              "lbin_vector_pop"

# length comps
f_cols <- grep("^f[0-9]", colnames(inputs$dat$lencomp))
m_cols <- grep("^m[0-9]", colnames(inputs$dat$lencomp))
# remove male columns
new_inputs$dat$lencomp <- inputs$dat$lencomp[, 1:max(f_cols)]
# add male proportions to female proportions
new_inputs$dat$lencomp[, f_cols] <- inputs$dat$lencomp[, f_cols] +
  inputs$dat$lencomp[, m_cols]
# note that some proportions sum to 1 and others to 2 but this was the case in the original data
inputs$dat$lencomp[, c(f_cols, m_cols)] |> apply(1, sum) |> round(3) |> table()
new_inputs$dat$lencomp[, f_cols] |> apply(1, sum) |> round(3) |> table()
#   1   2
#  61 130

# remove discard comps (partition 1)
new_inputs$dat$lencomp <- new_inputs$dat$lencomp |> dplyr::filter_out(part == 1)

# TODO: consider for future models: separate estimated discards into new fleets

# remove discard info
new_inputs$dat$N_discard_fleets <- 0
new_inputs$dat$discard_fleet_info <- NULL
new_inputs$dat$discard_data <- NULL

# remove mean body weight
new_inputs$dat$use_meanbodywt <- 0
new_inputs$dat$meanbodywt <- NULL
new_inputs$dat$DF_for_meanbodywt <- NULL

# replace landings with total mortality including discards
new_inputs$dat$catch <- output$catch |>
  dplyr::select(Yr, Seas, Fleet, kill_bio, se) |>
  dplyr::rename(
    year = Yr,
    seas = Seas,
    fleet = Fleet,
    catch = kill_bio,
    catch_se = se
  )

r4ss::SS_write(new_inputs, dir = "model/simplify_for_FIMS", overwrite = TRUE)
r4ss::run("model/simplify_for_FIMS", show_in_console = TRUE)

output2 <- r4ss::SS_output("model/simplify_for_FIMS")
r4ss::SSplotComparisons(
  r4ss::SSsummarize(
    list(output, output2)
  ),
  legendlabels = c("original", "simplified"),
  plot = FALSE,
  print = TRUE,
  plotdir = "model/simplify_for_FIMS"
)

r4ss::plot_twopanel_comparison(
  list(output, output2),
  legendlabels = c("original", "simplified"),
  dir = "model/simplify_for_FIMS",
  subplot1 = 4,
  subplot2 = 12
)
