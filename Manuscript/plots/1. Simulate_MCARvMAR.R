#simulation to demonstrate MCAR being (not) distinct from MAR
require(MASS)
require(mice)
source("functions/Ampute.R")
source("functions/simulate.R")
source("functions/pool.finite.R")
source("functions/evaluate.R")
set.seed(12345)

#generate complete data
compl <- data.frame(mvrnorm(
  n     = 500,
  mu    = c(5, 10, 10),
  Sigma = matrix(c(1, .8, .01,
                   .8, 1, 0,
                   .01, 0, 1),
                 3, 3)
))

#create empty object to store simulations
output.MCAR <- list(NA)
output.MAR1 <- list(NA)
output.MAR2 <- list(NA)

#start simulations
nsim = 1000
pb <- txtProgressBar(min = 0, max = nsim, style = 3)
for (i in 1:nsim) {
  output.MCAR[[i]] <-
    simulate.mis(compl[,-3], "MCAR", .5) #exclude tp conform to 2 dims
  output.MAR1[[i]] <-
    simulate.mis(compl[,-3], "MARright", .5) #high correlation
  output.MAR2[[i]] <-
    simulate.mis(compl[,-2], "MARright", .5) #low correlation
  setTxtProgressBar(pb, i)
}
close(pb)

#start evaluations
eval.MCAR <- evaluate(object = output.MCAR, population = compl[, 1])
eval.MAR1 <- evaluate(object = output.MAR1, population = compl[, 1])
eval.MAR2 <- evaluate(object = output.MAR2, population = compl[, 1])

#store it all
save.image("1. Simulate_MCARvMAR.RData")
