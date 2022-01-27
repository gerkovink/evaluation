# small simulation study for illustration

# set-up 
set.seed(123)
library(dplyr)
source("R/utils.R")

# # parameters
# n_sim <- 1000 #c(100, 1000)
# n_obs <- 500 #c(50, 500, 5000)
# n_var <- 2 #c(2, 5, 20)
# corr <- 0.4 #c(0, .8)
# mis_mech <- "MAR" #c("MCAR", "MAR", "MNAR")
# mis_type <- "RIGHT" #c("left", "right", "mid", "tail")
# mis_prop <- 0.5 #c(.1, .25, .5)
# n_imp <- 5 #c(1, 5)
# imp_meth <- "norm" #c("mean", "norm.predict", "norm") #cca
# n_it <- 10 #c(1, 5, 10)
# # est <- c("mean(Y)", "var(Y)", "cov(X,Y)", "lm(Y~X)", "lm(X~Y)")
# # model vs design based
# # with or without sampling variance


# generate data
generation <- function(n_obs, corr){
  dat <- data.frame(mvtnorm::rmvnorm(
    n = n_obs,
    mean = c(10, 10),
    sigma = matrix(c(1, corr, corr, 1), 2, 2)
  )) %>% setNames(c("Y", "X"))
}

# ampute the data
amputation <- function(dat, mis_mech, mis_type, mis_prop){
  amp <- dat %>% 
  mice::ampute(
    prop = mis_prop,
    mech = mis_mech,
    type = mis_type
  )}

# impute the data
imputation <- function(amp, imp_meth, n_imp, n_it){
  imp <- amp$amp %>%
  mice::mice(
    m = n_imp,
    method = imp_meth,
    maxit = n_it,
    print = FALSE
  )}

# evaluate the imputations
evaluation <- function(imp, amp, dat, corr){
  # analysis model
  fit <- imp %>% 
    with(lm(Y ~ X))
  
  # reference performance
  refs <- data.frame(
    mean_obs = mean(dat$Y),
    mean_cca = mean(amp$amp$Y, na.rm = TRUE),
    mean_est = mean(mice::complete(imp, "long")$Y),
    beta_obs = coef(lm(Y~X, dat))[2],
    beta_cca = coef(lm(Y~X, amp$amp, na.action = na.omit))[2])
  
  # root mean squared errors
  rmses <- purrr::map_dfr(1:imp$m, function(.m){
    data.frame(
      rmse_pred = rmse(fit$analyses[[.m]]$residuals),    
    rmse_cell = rmse(imp$imp$Y[[.m]] - dat$Y[imp$where[, "Y"]])) 
  }) %>% colMeans() %>% t()
  
  # performance
  out <- fit %>% 
    mice::pool() %>% 
    broom::tidy(conf.int = TRUE) %>% 
    .[2, ] %>% 
    mutate(
      beta_est = estimate,
      beta_ciw = conf.high - conf.low,
      beta_cr = conf.low <= corr && corr <= conf.high,
      .keep = "none") %>% 
    cbind(
      n_obs = nrow(dat), 
      corr = corr, 
      mis_mech = amp$mech,
      mis_type = amp$type,
      mis_prop = amp$prop,
      imp_meth = imp$method[1],
      n_imp = imp$m,
      n_it = imp$iteration,
      refs,
      ., 
      rmses)
  rownames(out) <- NULL
  return(out)
}

# simulation function
run <- function(
  n = 500,
  r = 0.4,
  mech = "MAR",
  type = "RIGHT",
  prop = 0.5,
  meth = "norm",
  m = 5,
  it = 10){
    
  # generate data
  dat <- generation(n_obs = n, corr = r)
  
  # ampute the data
  amp <- amputation(dat, mis_mech = mech, mis_type = type, mis_prop = prop)
    
  # impute the data
  imp <- imputation(amp, imp_meth = meth, n_imp = m, n_it = it)
  
  # evaluate the imputations 
  out <- evaluation(imp, amp, dat, corr = r)
  
  # output
  return(out)
}

# test once
run()
run(r = 0.8)

# test with multiple conditions
purrr::map_dfr(c(50, 500), ~{run(n = .x)}) 
purrr::map_dfr(c(0, .4, .8), ~{run(r = .x)}) 

# test with more simulation repetitions
sims <- purrr::map_dfr(1:5, ~{
  purrr::map_dfr(c(0, .4, .8), function(.c){run(r = .c) %>% cbind(sim = .x, .)})})
sims %>% group_by(corr) %>% summarise(mean(rmse_pred))

