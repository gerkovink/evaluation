# small simulation study for illustration

# set-up 
set.seed(123)
library(dplyr)
source("R/utils.R")

# parameters
n_sim <- 1000 #c(100, 1000)
n_obs <- 500 #c(50, 500, 5000)
n_var <- 2 #c(2, 5, 20)
corr <- 0.4 #c(0, .8)
mis_mech <- "MAR" #c("MCAR", "MAR", "MNAR")
mis_type <- "RIGHT" #c("left", "right", "mid", "tail")
mis_prop <- 0.5 #c(.1, .25, .5)
n_imp <- 5 #c(1, 5)
imp_meth <- "norm" #c("mean", "norm.predict", "norm") #cca
n_it <- 10 #c(1, 5, 10)
# est <- c("mean(Y)", "var(Y)", "cov(X,Y)", "lm(Y~X)", "lm(X~Y)")
# model vs design based
# with or without sampling variance


# generate data
generation <- function(n_obs = 500, corr = 0.4){
  dat <- data.frame(mvtnorm::rmvnorm(
    n = n_obs,
    mean = c(10, 10),
    sigma = matrix(c(1, corr, corr, 1), 2, 2)
  )) %>% setNames(c("Y", "X"))
}

# ampute the data
amputation <- function(dat, mis_mech = "MAR", mis_type = "RIGHT", mis_prop = 0.5){
  amp <- dat %>% 
  mice::ampute(
    prop = mis_prop,
    mech = mis_mech,
    type = mis_type
  )}

# impute the data
imputation <- function(amp, imp_meth = "norm", n_imp = 5, n_it = 10){
  imp <- amp$amp %>%
  mice::mice(
    m = n_imp,
    method = imp_meth,
    maxit = n_it,
    print = FALSE
  )}

# evaluate the imputations
evaluation <- function(imp, amp, dat, corr = 0.4){
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
  n_obs = NULL,
  corr = NULL,
  mis_mech = NULL,
  mis_type = NULL,
  mis_prop = NULL,
  imp_meth = NULL,
  n_imp = NULL,
  n_it = NULL){
    
  # generate data
  dat <- generation()
  
  # ampute the data
  amp <- amputation(dat)
    
  # impute the data
  imp <- imputation(amp)
  
  # evaluate the imputations 
  out <- evaluation(imp, amp, dat)
  
  # output
  return(out)
}

# test once
run()

# test with multiple conditions
purrr::map_dfr(c(50, 500), ~{run(n_obs = .x)}) #%>% cbind(n_obs = .x, .)
purrr::map_dfr(c(0, .4, .8), ~{run(corr = .x)}) #%>% cbind(corr = .x, .)

# test with more simulation repetitions
sims <- purrr::map_dfr(1:10, ~{
  purrr::map_dfr(c(0, .4, .8), function(.c){run(corr = .c) %>% cbind(it = .x, corr = .c, .)})})
sims %>% group_by(corr) %>% summarise(mean(bias))


