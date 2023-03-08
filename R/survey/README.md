# Shortspine Thornyhead 2023 Fisheries Independent Surveys

Data from five fisheries independent surveys conducted by NOAA fisheries since 1980 are used to calculate indices of abundance and length compositions for shortspine thornyhead since 1980.

### Files

`SST_surveys_2023.R` - Pulls survey data from the official `nwfscSurvey` package and calculates the design-based indices of abundance and length compositions for each of the five surveys. All data is saved in SS format in the `outputs/surveys/` directory.

`SST_surveys_2013.R` - Reads and plots design-based indices of abunadance from the 2013 survey.

`plot_survey_indices.R` - Reads in SS style design-based index of abundance information output by the `SST_surveys_2023.R` script, reformats, and plots the indices of abundance with associated uncertainties. Outputs `2023_survey_indices.png`.

`plot_length_comps.R` - Reads in SS style length composition information output by the `SST_surveys_2023.R` script, reformats, and plots the sex-based length composition as a ridge plot. Outputs `2023_length_compositions.png`.

`survey_index_comparison_2013_2023.R` - Plots 2013 and 2023 indices of abundance against each faciliate comparing trends and scales across assessments.

`PlotStrata.fn.R` and `PlotStrataMap.fn.R` - Extraneous functions for making plots of the design-based strata.
