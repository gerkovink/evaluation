#ampute function

ampute <- function(data, mis.var, cov.var, prop.mis, m.mech="MARright"){
  data.rm 	<- data 
  n			<- nrow(data.rm)
  inv.log		<- function(x){ exp(x) / (1+exp(x)) }
  m.cov		<- mean(data.rm[,cov.var])
  if (prop.mis==.15){
    ML <- (mean(data[,cov.var]) - data[,cov.var])/sd(data[,cov.var])-2.05
    MR <- (-mean(data[,cov.var]) + data[,cov.var])/sd(data[,cov.var])-2.048
    MM <- (.75 - abs((data[,cov.var] - mean(data[,cov.var]))/sd(data[,cov.var])))-1.83
    MT <- (-.75 + abs((data[,cov.var] - mean(data[,cov.var]))/sd(data[,cov.var])))-1.9
  }
  if (prop.mis==.25){
    ML <- (mean(data[,cov.var]) - data[,cov.var])/sd(data[,cov.var])-1.3
    MR <- (-mean(data[,cov.var]) + data[,cov.var])/sd(data[,cov.var])-1.3
    MM <- (.75 - abs((data[,cov.var] - mean(data[,cov.var]))/sd(data[,cov.var])))-1.15
    MT <- (-.75 + abs((data[,cov.var] - mean(data[,cov.var]))/sd(data[,cov.var])))-1.225
  }
  if (prop.mis==.5){
    ML <- (mean(data[,cov.var]) - data[,cov.var])/sd(data[,cov.var])
    MR <- (-mean(data[,cov.var]) + data[,cov.var])/sd(data[,cov.var])
    MM <- (.75 - abs((data[,cov.var] - mean(data[,cov.var]))/sd(data[,cov.var])))
    MT <- (-.75 + abs((data[,cov.var] - mean(data[,cov.var]))/sd(data[,cov.var])))
  }
  
  
  if (m.mech=="MARleft"){
    p.MAR <- inv.log(ML)
    data.rm[1 == rbinom(n, 1, p.MAR), mis.var] <- NA
  }	
  
  if (m.mech=="MARright"){
    p.MAR <- inv.log(MR)
    data.rm[1 == rbinom(n, 1, p.MAR), mis.var] <- NA
  }
  
  if (m.mech=="MARmid"){
    p.MAR <- inv.log(MM)
    data.rm[1 == rbinom(n, 1, p.MAR), mis.var] <- NA
  }
  
  if (m.mech=="MARtail"){
    p.MAR <- inv.log(MT)
    data.rm[1 == rbinom(n, 1, p.MAR), mis.var] <- NA
  }
  
  if (m.mech=="MCAR"){
    p.MAR = rep(prop.mis, nrow(data.rm))
    data.rm[0 == rbinom(n, 1, 1 - prop.mis), mis.var] <- NA
  }
  
  # Prepare data for return
  true.mis 		<- mean(is.na(data.rm[,mis.var]))
  mis.info 		<- data.frame(Mechanism = m.mech, Proportion = true.mis)
  output 			<- list(data.rm, p.MAR, mis.info)
  names(output) 	<- c("data", "p.mis", "info")
  return(output)
}