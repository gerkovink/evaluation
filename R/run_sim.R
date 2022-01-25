# small simulation study for illustration

# set-up 
set.seed(123)
library(dplyr)
source("R/utils.R")

# parameters
n_sim <- c(100, 1000)
n_obs <- 500 #c(100, 500, 1000)
n_var <- 2 #c(2, 5, 20)
means <- c(10, 100)
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

# data generating mechanism

varcov <- matrix(0, 2, 2)
diag(varcov) <- 1
varcov[1, 2] <- varcov[2, 1] <- corr 

# simulation function
run <- function(
  n_obs = 500,
  corr = 0.4,
  mis_mech = "MAR",
  mis_type = "RIGHT",
  mis_prop = 0.5,
  n_imp = 5,
  n_it = 10,
  imp_meth = "norm",
  ...){
    
    # generate data
    dat <- data.frame(mvtnorm::rmvnorm(
      n = n_obs,
      mean = means,
      sigma = matrix(c(1, corr, corr, 1), 2, 2)
    )) %>% setNames(c("Y", "X"))
    
    # ampute
    amp <- dat %>% 
      mice::ampute(
        prop = mis_prop,
        mech = mis_mech,
        type = mis_type
        ) %>% 
      .$amp
    
    # impute and fit analysis model
    imp <- amp %>%
      mice::mice(
        m = n_imp,
        method = imp_meth,
        maxit = n_it,
        print = FALSE
      ) %>%
      with(lm(Y ~ X))

    # pool results
    res <- imp %>% 
      mice::pool() %>% 
      broom::tidy(conf.int = TRUE) %>% 
      .[2, ] %>% 
      mutate(bias = estimate - corr,
             ciw = conf.high - conf.low,
             cr = conf.low <= corr && corr <= conf.high,
             .keep = "none") %>% 
      cbind(rmse_pred = purrr::map_dbl(1:n_imp, 
        ~{rmse(imp$analyses[[.x]]$residuals)}) %>% 
          mean(),
        rmse_cell = purrr::map_dbl(1:n_imp, 
          ~{rmse(imp$analyses[[.x]]$model$Y[is.na(amp$Y)], dat$Y[is.na(amp$Y)])}) %>% 
          mean()
        )
    
    # output
    return(res)
  }

# test
run()
