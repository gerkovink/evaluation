# create figures for the manuscript

# set-up
set.seed(123)
library(dplyr)
library(ggplot2)
library(patchwork)
source("R/utils.R")

# missingness mechanism and correlation 
# data generating mechanism
sigma <- matrix(0, 3, 3)
diag(sigma) <- 1
sigma[1, 2] <- sigma[2, 1] <- 0.8 
dat <- data.frame(mvtnorm::rmvnorm(500, mean = c(5, 10, 10), sigma = sigma)) %>% setNames(c("Y", "X1", "X2"))
amp.mcar.8 <- mice::ampute(dat[, c("Y", "X1")], prop = .5, mech = "MCAR")$amp %>% setNames(c("Y", "X"))
amp.mcar.0 <- mice::ampute(dat[, c("Y", "X2")], prop = .5, mech = "MCAR")$amp %>% setNames(c("Y", "X"))
amp.mar.8 <- mice::ampute(dat[, c("Y", "X1")], prop = .5, mech = "MAR")$amp %>% setNames(c("Y", "X"))
amp.mar.0 <- mice::ampute(dat[, c("Y", "X2")], prop = .5, mech = "MAR")$amp %>% setNames(c("Y", "X"))

a <- dat[dat$Y != is.na(amp.mcar.8$Y), ] %>% 
  ggplot() +
  geom_point(aes(x = X1, y = Y), color = mice:::mdc(2), alpha = 0.25) +
  geom_point(aes(x = X, y = Y), color = mice:::mdc(1), alpha = 0.5, data = amp.mcar.8) +
  theme_classic()
b <- dat[dat$Y != is.na(amp.mcar.0$Y), ] %>% 
  ggplot() +
  geom_point(aes(x = X2, y = Y), color = mice:::mdc(2), alpha = 0.25) +
  geom_point(aes(x = X, y = Y), color = mice:::mdc(1), alpha = 0.5, data = amp.mcar.0) +
  theme_classic()
c <- dat[dat$Y != is.na(amp.mar.8$Y), ] %>% 
  ggplot() +
  geom_point(aes(x = X1, y = Y), color = mice:::mdc(2), alpha = 0.25) +
  geom_point(aes(x = X, y = Y), color = mice:::mdc(1), alpha = 0.5, data = amp.mar.8) +
  theme_classic()
d <- dat[dat$Y != is.na(amp.mar.0$Y), ] %>% 
  ggplot() +
  geom_point(aes(x = X2, y = Y), color = mice:::mdc(2), alpha = 0.25) +
  geom_point(aes(x = X, y = Y), color = mice:::mdc(1), alpha = 0.5, data = amp.mar.0) +
  theme_classic()
(a + b) / (c + d)

# types of MAR
dat_mis_types <- data.frame(X = seq(-3, 3, 0.01)) %>% 
  mutate(RIGHT = logistic(-mean(X) + X),
         MID = logistic(-abs(X - mean(X)) + 0.75),
         TAIL = logistic(abs(X - mean(X)) - 0.75),
         LEFT = logistic(mean(X) - X)) %>% 
  tidyr::pivot_longer(c("RIGHT", "MID", "TAIL", "LEFT"), names_to = "Type")

ggplot(dat_mis_types, aes(X, value, linetype = Type)) +
  geom_line() +
  labs(x = "Standardized weighted sum scores",
       y = "Probability") +
  theme_classic()
