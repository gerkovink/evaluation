# simulation study for illustration

# set-up 
# set.seed(123)
# library(dplyr)
# source("R/utils.R")
n_sim = 2

## simulation parameters ##

# conditions
n_obs = c(50, 500, 5000) 
corr = c(0, .4, .8)
mis_mech = c("MCAR", "MAR", "MNAR")
mis_type = c("LEFT", "RIGHT", "MID", "TAIL")
mis_prop = c(.1, .25, .5)
n_imp = c(1, 5)
imp_meth = c("mean", "norm.predict", "norm") 
n_it = c(1, 5, 10)

# combine into lists for mapping
dat_par <- expand.grid(n_obs = n_obs, corr = corr)
amp_par <- expand.grid(dat_nr = 1:nrow(dat_par), mis_mech = mis_mech, mis_type = mis_type, mis_prop = mis_prop, stringsAsFactors = FALSE)
imp_par <- expand.grid(amp_nr = 1:nrow(amp_par), imp_meth = imp_meth, n_imp = n_imp, n_it = n_it, stringsAsFactors = FALSE)


## simulation functions ##

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
               imp = suppressWarnings(mice::pool(fit_imps)))
  # performance
  out <- purrr::map_dfr(fits, ~{
           broom::tidy(.x, conf.int = TRUE) %>% 
             .[2, c("estimate", "conf.low", "conf.high")]}) %>% 
    mutate(
      dat = factor(c("complete", "incomplete", "imputed"), ordered = TRUE),
      est = estimate,
      cill = conf.low,
      ciul = conf.high,
      .keep = "none")
  
  # root mean squared errors
  rmses <- data.frame(
    rmse_pred = c(rmse(fits$full$residuals), rmse(fits$cca$residuals)),
    rmse_cell = c(0, NA)) %>% 
    rbind(., purrr::map_dfr(1:imp$m, function(.m) {
    data.frame(
      rmse_pred = rmse(fit_imps$analyses[[.m]]$residuals),
      rmse_cell = rmse(imp$imp$Y[[.m]] - dat$Y[imp$where[, "Y"]])
    )}) %>% colMeans() %>% t())
  
  # performance
  out <- out %>% 
    cbind(
      # n_obs = nrow(dat), 
      # corr = r, 
      # mis_mech = amp$mech,
      # mis_type = amp$type,
      # mis_prop = amp$prop,
      # imp_meth = imp$method[1],
      # n_imp = imp$m,
      # n_it = imp$iteration,
      .,
      ave = c(mean(dat$Y), mean(amp$amp$Y, na.rm = TRUE), mean(mice::complete(imp, "long")$Y)),
      rmses,
      row.names = NULL)
  return(out)
}

# run simulation once
simulation <- function(...){
# generate
dat <- purrr::pmap(dat_par, ~{
  list(n_obs = ..1, corr = ..2, dat = generation(n = ..1, r = ..2))
})
# ampute
amp <- purrr::pmap(amp_par, ~{
  list(n_obs = dat[[..1]]$n_obs, corr = dat[[..1]]$corr, mis_mech = ..2, mis_type = ..3, mis_prop = ..4, 
       dat = dat[[..1]]$dat,
       amp = amputation(dat = dat[[..1]]$dat, mech = ..2, type = ..3, prop = ..4))
})
# impute
imp <- purrr::pmap(imp_par, ~{
  list(n_obs = amp[[..1]]$n_obs, corr = amp[[..1]]$corr, mis_mech = amp[[..1]]$mis_mech, mis_type = amp[[..1]]$mis_type, mis_prop = amp[[..1]]$mis_prop, 
       imp_meth = ..2, n_imp = ..3, n_it = ..4,
       dat = amp[[..1]]$dat,
       amp = amp[[..1]]$amp,
       imp = imputation(amp[[..1]]$amp, meth = ..2, m = ..3, it = ..4))
       })
# analyze
out <- purrr::map_dfr(1:length(imp), ~{
  evaluation(imp[[.x]]$imp, imp[[.x]]$amp, imp[[.x]]$dat, r = imp[[.x]]$corr)
})
# output
return(out)
}

# run simulation n_sim times
results <- purrr::map_dfr(1:n_sim, ~{
  cbind(sim = .x, simulation())
})

# all_par <- expand.grid(
#   n_obs = n_obs, 
#   corr = corr,
#   mis_mech = mis_mech,
#   mis_type = mis_type,
#   mis_prop = mis_prop,
#   imp_meth = imp_meth,
#   n_imp = n_imp,
#   n_it = n_it)

# # simulate complete datasets
# dat <- purrr::map(n_obs, function(n){
#   purrr::map(corr, function(r){
#     generation(n, r)
#   }) %>% setNames(corr)
# }) %>% setNames(n_obs)
# 
# # ampute all datasets
# amp <- purrr::map(n_obs, function(n){
#   purrr::map(corr, function(r){
#     purrr::map(mis_mech, function(mech){
#   amputation(dat[[n]][[r]], mech, type = mis_type, prop = mis_prop)})})})

# impute all incomplete datasets



# l2 <- list(
#   list(num = 1:3,     letters[1:3]),
#   list(num = 101:103, letters[4:6]),
#   list()
# )
# l2 %>% purrr::map(c(2, 2))
# 
# 
# par_dat <- list(
#   n_obs = c(50, 500, 5000),
#   corr = c(0, .4, .8))
# 
# par_dat %>% purrr::map(~generation(n = n_obs, r = corr))

# expand.grid(height = seq(60, 80, 5), weight = seq(100, 300, 50),
#             sex = c("Male","Female"))

# # simulation function
# run <- function(
#   n_obs = 500,
#   corr = 0.4,
#   mis_mech = "MAR",
#   mis_type = "RIGHT",
#   mis_prop = 0.5,
#   imp_meth = "norm",
#   n_imp = 5,
#   n_it = 10){
#     
#   # generate data
#   dat <- generation(n = n_obs, r = corr)
#   
#   # ampute the data
#   amp <- amputation(dat, mech = mis_mech, type = mis_type, prop = mis_prop)
#     
#   # impute the data
#   imp <- imputation(amp, meth = imp_meth, m = n_imp, it = n_it)
#   
#   # evaluate the imputations 
#   out <- evaluation(imp, amp, dat, r = corr)
#   
#   # output
#   return(out)
# }

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

# refs <- data.frame(
#   mean_full = mean(dat$Y),
#   mean_cca = mean(amp$amp$Y, na.rm = TRUE),
#   mean_est = mean(mice::complete(imp, "long")$Y),
#   beta_full = coef(lm(Y~X, dat))[2],
#   beta_cca = coef(lm(Y~X, amp$amp, na.action = na.omit))[2])

# <- fit %>% 
#   mice::pool() %>% 
#   broom::tidy(conf.int = TRUE) %>% 
#   .[2, ] %>% 
#   mutate(
#     beta_est = estimate,
#     beta_ciw = conf.high - conf.low,
#     beta_cr = conf.low <= r && r <= conf.high,
#     .keep = "none") %>% 