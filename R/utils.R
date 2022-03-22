# utils functions

`%nin%` <- Negate(`%in%`)
logistic <- function(x){exp(x)/(1+exp(x))} 
rmse <- function(obs, pred = 0){sqrt(mean((obs-pred)^2))}

