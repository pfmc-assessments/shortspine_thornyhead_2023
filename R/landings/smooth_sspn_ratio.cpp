// A multivariate state-space random walk model to smooth observed ratios of
// shortspine thornyhead to total identified thornyhead. The predicted smoothed
// ratios are estimated as random effects. Observation error is assumed to
// inversely proportional to the unidentified catch (larger catches are assigned
// smaller CVs). An inverse logit transformation is applied to the ratios in order
// bound random effects between 0 and 1. The only fixed effects parameters in
// the model are the standard deviation of the process error.

#include <TMB.hpp>
#include <iostream>

template<class Type>
Type objective_function<Type>::operator() ()
{
  // model dimensions
  DATA_IVECTOR(model_yrs);

  // observed ratios of sspn
  DATA_MATRIX(logit_ratio_obs);
  DATA_MATRIX(ratio_cv);

  // indexing vector
  DATA_IVECTOR(pointer_PE); // length = ncol ratio obs (# fleets), unique values = number of PE parameters

  // parameter section

  // PARAMETER(dummy);  // dummy var for troubleshooting
  PARAMETER_VECTOR(log_PE); // process errors

  // random effects of predicted sspn ratios
  PARAMETER_MATRIX(logit_ratio_pred);

  // negative log likelihood
  vector<Type> jnll(2); // random walk, observation error
  jnll.setZero();
  Type nll = 0;

  // derived quantities 
  int nyrs = model_yrs.size();
  int nfleets = logit_ratio_obs.cols();

  matrix<Type> ratio_pred(nyrs, nfleets);
  ratio_pred.setZero();
  for(int i = 0; i < nyrs; i++) {
    for(int j = 0; j < nfleets; j++) {
      ratio_pred(i,j) = invlogit(logit_ratio_pred(i,j));
    }
  }

  matrix<Type> ratio_obs(nyrs, nfleets);
  ratio_obs.setZero();
  for(int i = 0; i < nyrs; i++) {
    for(int j = 0; j < nfleets; j++) {
      ratio_obs(i,j) = invlogit(logit_ratio_obs(i,j));
    }
  }

  matrix<Type> log_ratio_sd(nyrs, nfleets);
  log_ratio_sd.setZero();

  for(int i = 0; i < nyrs; i++) {
    for(int j = 0; j < nfleets; j++) {
      log_ratio_sd(i,j) = ratio_cv(i,j) * ratio_cv(i,j) + Type(1.0);
      log_ratio_sd(i,j) = sqrt(log(log_ratio_sd(i,j)));
    }
  }

  // random effects contribution to likelihood
  for(int i = 1; i < nyrs; i++) {
    for(int j = 0; j < nfleets; j++) {
      jnll(0) -= dnorm(log(ratio_pred(i-1,j)), log(ratio_pred(i,j)), exp(log_PE(pointer_PE(j))), 1);
    }
  }

  // likelihood for sspn ratio data observation error
  for(int i = 0; i < nyrs; i++) {
    for(int j = 0; j < nfleets; j++) {

      if(ratio_obs(i,j) > 0) {
        jnll(1) -= dnorm(logit_ratio_obs(i,j), logit_ratio_pred(i,j), log_ratio_sd(i,j), 1);
      }

    }
  }

  // report section
  ADREPORT(ratio_pred);
  REPORT(jnll);
  // jnll = dummy * dummy;        // Uncomment when debugging code
  nll = jnll.sum();
  return nll;

}
