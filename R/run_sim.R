# small simulation study for illustration

# set-up 
set.seed(123)
library(dplyr)
source("R/utils.R")

# parameters
n_sim <- 1000 #c(100, 1000)
n_obs <- c(50, 500, 5000)
n_var <- 2 #c(2, 5, 20)
corr <- c(0, .8)
mis_mech <- c("MCAR", "MAR", "MNAR")
mis_type <- "RIGHT" #c("left", "right", "mid", "tail")
mis_prop <- c(.1, .25, .5)
n_imp <- c(1, 5)
imp_meth <- c("mean", "norm.predict", "norm") #cca
n_it <- c(1, 5, 10)
est <- c("mean(Y)", "var(Y)", "cov(X,Y)", "lm(Y~X)", "lm(X~Y)")
# model vs design based
# with or without sampling variance

# # data generating mechanism
# means <- c(10, 100)
# varcov <- matrix(0, 2, 2)
# diag(varcov) <- 1
# varcov[1, 2] <- varcov[2, 1] <- corr 

# generate complete data
generation <- function(...){
  dat <- data.frame(mvtnorm::rmvnorm(
    n = n_obs,
    mean = c(10, 100),
    sigma = matrix(c(1, corr, corr, 1), 2, 2)
  )) %>% setNames(c("Y", "X"))
}

# ampute the data
amputation <- function(dat, ...){
  amp <- dat %>% 
  mice::ampute(
    prop = mis_prop,
    mech = mis_mech,
    type = mis_type
  ) %>% 
  .$amp}

# impute the data
imputation <- function(amp, ...){
  imp <- amp %>%
  mice::mice(
    m = n_imp,
    method = imp_meth,
    maxit = n_it,
    print = FALSE
  )}

# evaluate the imputations
evaluation <- function(imp, dat, ...){
  fit <- imp %>% 
    with(lm(Y ~ X))
  
  rmses <- purrr::map_dfr(1:imp$m, function(.m){
    data.frame(
      rmse_cell = rmse(imp$imp$Y[[.m]] - dat$Y[imp$where[, "Y"]]), 
      rmse_pred = rmse(fit$analyses[[.m]]$residuals))    
  }) %>% colMeans() %>% t()
  
  fit %>% 
    mice::pool() %>% 
    broom::tidy(conf.int = TRUE) %>% 
    .[2, ] %>% 
    mutate(
      bias = estimate - corr,
      ciw = conf.high - conf.low,
      cr = conf.low <= corr && corr <= conf.high,
      .keep = "none") %>% 
    cbind(., rmses)
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
  dat <- generation(n_obs, corr)
  
  # ampute the data
  amp <- amputation(dat, mis_mech, mis_prop, mis_type)
    
  # impute the data
  imp <- imputation(amp, imp_meth, n_imp, n_it)
  
  # evaluate the imputations 
  out <- evaluation(imp, dat)
  
  # output
  return(out)
}

# test once
run()

# test with multiple conditions
purrr::map_dfr(c(50, 500), ~{run(n_obs = .x) %>% cbind(n_obs = .x, .)})
purrr::map_dfr(c(0, .4, .8), ~{run(corr = .x) %>% cbind(corr = .x, .)})

# test with more simulation repetitions
sims <- purrr::map_dfr(1:10, ~{
  purrr::map_dfr(c(0, .4, .8), function(.c){run(corr = .c) %>% cbind(it = .x, corr = .c, .)})})
sims %>% group_by(corr) %>% summarise(mean(bias))
