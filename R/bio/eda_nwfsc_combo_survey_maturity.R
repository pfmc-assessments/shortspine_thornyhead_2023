# Shortspine thornyhead
# Maturity data from the NWFSC Combo survey

  # packages
  library(nwfscSurvey)

  # List of functions
  ls("package:nwfscSurvey")
  
  
  # NWFSC.combo survey
  
  # pull other biological data
  bio_mat = pull_biological_samples(common_name = "shortspine thornyhead", 
                                        survey = "NWFSC.Combo")
  # column headings
    #I am not sure what these all means, perhaps there is a readme?
  names(bio_mat)
  
  # maturity data by year...not sure differences between the two columns
  table(bio_mat$year, bio_mat$biologically_mature_certain_indicator)
  table(bio_mat$year, bio_mat$biologically_mature_indicator)
  
  # Notes: The 2013 assessment did a sensitivity to observed proportions
            #mature by age bin (and spatial patterns)
  
  # If needed, revisit the 2013 sensitivity analysis
            
  