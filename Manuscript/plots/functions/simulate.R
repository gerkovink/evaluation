#simulate function
simulate.mis <- function(true, mech = "MCAR", prop = .5){
  colnames(true) <- c("Y", "X")
  incompl <- ampute(true, 
                    mis.var = 1, 
                    cov.var = 2, 
                    prop.mis = prop, 
                    m.mech = mech)
  imp <- mice(incompl$data, 
              method = "norm", 
              m = 5, 
              maxit = 1, #missingness is monotone
              print = FALSE)
  return(list(imp = imp, 
              incompl = incompl))
} 