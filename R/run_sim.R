# small simulation study for illustration

# set-up 
# set.seed(123)
# library(dplyr)
# source("R/utils.R")

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
generation <- function(n, r){
  dat <- data.frame(mvtnorm::rmvnorm(
    n = n,
    mean = c(10, 10),
    sigma = matrix(c(1, r, r, 1), 2, 2)
  )) %>% setNames(c("Y", "X"))
}

# ampute the data
amputation <- function(dat, mech, type, prop){
  amp <- dat %>% 
  mice::ampute(
    prop = prop,
    mech = mech,
    type = type
  )}

# impute the data
imputation <- function(amp, meth, m, it){
  imp <- amp$amp %>%
  mice::mice(
    m = m,
    method = meth,
    maxit = it,
    print = FALSE
  )}

# evaluate the imputations
evaluation <- function(imp, amp, dat, r){
  # fit analysis model
  fit_imps <- with(imp, lm(Y ~ X))
  fits <- list(full = lm(Y~X, dat),
               cca = lm(Y~X, amp$amp, na.action = na.omit),
               imp = mice::pool(fit_imps))
  # performance
  out <- purrr::map_dfr(fits, ~{
           broom::tidy(.x, conf.int = TRUE) %>% 
             .[2, c("estimate", "conf.low", "conf.high")]}) %>% 
    mutate(
      dat = c("full", "cca", "imp"),
      est = estimate,
      ciw = conf.high - conf.low,
      cov = conf.low <= r && r <= conf.high,
      .keep = "none")
  
  # refs <- data.frame(
  #   mean_full = mean(dat$Y),
  #   mean_cca = mean(amp$amp$Y, na.rm = TRUE),
  #   mean_est = mean(mice::complete(imp, "long")$Y),
  #   beta_full = coef(lm(Y~X, dat))[2],
  #   beta_cca = coef(lm(Y~X, amp$amp, na.action = na.omit))[2])
  
  # root mean squared errors
  rmses <- data.frame(
    rmse_pred = c(rmse(fits$full$residuals), rmse(fits$cca$residuals)),
    rmse_cell = c(0, NA)) %>% 
    rbind(., purrr::map_dfr(1:imp$m, function(.m) {
    data.frame(
      rmse_pred = rmse(fit$analyses[[.m]]$residuals),
      rmse_cell = rmse(imp$imp$Y[[.m]] - dat$Y[imp$where[, "Y"]])
    )}) %>% colMeans() %>% t())
  
  # performance
  out <- out %>% 
  # <- fit %>% 
  #   mice::pool() %>% 
  #   broom::tidy(conf.int = TRUE) %>% 
  #   .[2, ] %>% 
  #   mutate(
  #     beta_est = estimate,
  #     beta_ciw = conf.high - conf.low,
  #     beta_cr = conf.low <= r && r <= conf.high,
  #     .keep = "none") %>% 
    cbind(
      n_obs = nrow(dat), 
      corr = r, 
      mis_mech = amp$mech,
      mis_type = amp$type,
      mis_prop = amp$prop,
      imp_meth = imp$method[1],
      n_imp = imp$m,
      n_it = imp$iteration,
      .,
      ave = c(mean(dat$Y), mean(amp$amp$Y, na.rm = TRUE), mean(mice::complete(imp, "long")$Y)),
      rmses,
      row.names = NULL)
  return(out)
}

# simulation function
run <- function(
  n_obs = 500,
  corr = 0.4,
  mis_mech = "MAR",
  mis_type = "RIGHT",
  mis_prop = 0.5,
  imp_meth = "norm",
  n_imp = 5,
  n_it = 10){
    
  # generate data
  dat <- generation(n = n_obs, r = corr)
  
  # ampute the data
  amp <- amputation(dat, mech = mis_mech, type = mis_type, prop = mis_prop)
    
  # impute the data
  imp <- imputation(amp, meth = imp_meth, m = n_imp, it = n_it)
  
  # evaluate the imputations 
  out <- evaluation(imp, amp, dat, r = corr)
  
  # output
  return(out)
}

# # test once
# run()
# run(corr = 0.8)
# 
# # test with multiple conditions
# purrr::map_dfr(c(50, 500), ~{run(n_obs = .x)}) 
# purrr::map_dfr(c(0, .4, .8), ~{run(corr = .x)}) 
# purrr::map_dfr(c("MCAR", "MAR", "MNAR"), ~{run(mis_mech = .x)}) 
# 
# # test with more simulation repetitions
# sims <- purrr::map_dfr(1:5, ~{
#   purrr::map_dfr(c(0, .4, .8), function(.c){run(corr = .c) %>% cbind(sim = .x, .)})})
# sims %>% group_by(corr) %>% summarise(mean(rmse_pred))

