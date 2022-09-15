evaluate <- function(object, population){
  OUT <- list(NA)
  N <- nrow(object[[1]]$imp$data)
  pb <- txtProgressBar(min = 0, max = nsim, style = 3)  
  for(i in 1:length(object)){
    # extract mean of Y - name it Q cf. Rubin (1987, pp 76)
    Q1           <- unlist(with(object[[i]]$imp, mean(Y))$analyses) 
    # extract variance of Q - name it U cf. Rubin (1987, pp 76)
    U1           <- unlist(with(object[[i]]$imp, var(Y))$analyses) / N
    pool1         <- pool.finite(Q1, U1)
    pool1$lower   <- pool1$qbar - qt(.975, pool1$df) * sqrt(pool1$t)
    pool1$upper   <- pool1$qbar + qt(.975, pool1$df) * sqrt(pool1$t)
    pool1$lambda  <- (pool1$b + (pool1$b / pool1$m)) / pool1$t
    # extract CCA mean of Y - name it Q cf. Rubin (1987, pp 76)
    CCA          <- na.omit(object[[i]]$incompl$data)
    Q2           <- rep(mean(CCA$Y), object[[i]]$imp$m)
    # extract CCA variance of Q - name it U cf. Rubin (1987, pp 76)
    U2           <- rep(var(CCA$Y), object[[i]]$imp$m)  / 500
    pool2         <- pool.scalar(Q2, U2)
    pool2$lower   <- pool2$qbar - qt(.975, nrow(CCA) - 1) * sqrt(pool2$t)
    pool2$upper   <- pool2$qbar + qt(.975, nrow(CCA) - 1) * sqrt(pool2$t)
    pool2$lambda  <- (pool2$b + (pool2$b / pool2$m)) / pool2$t
    #save evaluations to list
    res      <- as.data.frame(rbind(unlist(pool1), unlist(pool2)))
    rownames(res) <- c("imp", "CCA")
    res$pop.mean <- mean(population)
    res$bias <- res$pop.mean - res$qbar
    res$cov <- res$lower < res$pop.mean & res$pop.mean < res$upper
    res$ciw <- res$upper - res$lower
    OUT[[i]] <- res
    setTxtProgressBar(pb, i)
  }
  close(pb)
  POOL <- Reduce("+", OUT) / length(OUT)
  return(list(sim = OUT, pool = POOL))
}