# small simulation study for illustration

# set-up 
set.seed(123)
library(dplyr)
rmse <- function(obs, pred = 0){sqrt(mean((obs-pred)^2))}

# parameters
n_sim <- c(100, 1000)
n_obs <- 500 #c(100, 500, 1000)
n_var <- 2 #c(2, 5, 20)
rho <- c(0, .8)
mis_mech <- c("MCAR", "MAR", "MNAR")
mis_type <- "right" #c("left", "right", "mid", "tail")
mis_prop <- c(.1, .25, .5)
n_imp <- c(1, 5)
n_it <- c(1, 5, 10)
imp_meth <- c("mean", "norm.predict", "norm")
est <- c("mean(Y)", "var(Y)", "cov(X,Y)", "lm(Y~X)", "lm(X~Y)")
# other: cca, model vs design based; with or without sampling variance

# data generating mechanism
mu <- c(5, 10, 10)
sigma <- matrix(0, 3, 3)
diag(sigma) <- 1
sigma[1, 2] <- sigma[2, 1] <- 0.8 #make this rho

# generate data
dat <- data.frame(mvtnorm::rmvnorm(n_obs, mean = mu, sigma = sigma))

# ampute 
amp.mcar.8 <- mice::ampute(dat[, c("X1", "X2")], prop = .5, mech = "MCAR")$amp
amp.mcar.0 <- mice::ampute(dat[, c("X1", "X3")], prop = .5, mech = "MCAR")$amp
amp.mar.8 <- mice::ampute(dat[, c("X1", "X2")], prop = .5, mech = "MAR")$amp
amp.mar.0 <- mice::ampute(dat[, c("X1", "X3")], prop = .5, mech = "MAR")$amp

# impute and fit analysis model
imp.mcar.8 <- amp.mcar.8 %>% 
  mice::mice(method = "norm", print = FALSE) %>% 
  with(lm(X1 ~ X2))

# pool results
res.mcar.8 <- imp.mcar.8 %>% 
  mice::pool() %>% 
  broom::tidy(conf.int = TRUE) %>% 
  select("estimate", "conf.low", "conf.high") %>% 
  .[2, ] %>% 
  c(rmse_pred = purrr::map_dbl(
    1:5, 
    ~{rmse(imp.mcar.8$analyses[[.x]]$residuals)}
    ) %>% mean(),
    rmse_cell = purrr::map_dbl(
      1:5, 
      ~{rmse(imp.mcar.8$analyses[[.x]]$model$X1[is.na(amp.mcar.8$X1)], dat$X1[is.na(amp.mcar.8$X1)])}
    ) %>% mean()
    )

