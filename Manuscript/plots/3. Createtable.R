#create table
require(xtable)
load('1. Simulate_MCARvMAR.RData')

MCAR <- eval.MCAR$pool[c(2, 1), c("bias", "cov", "ciw")]
MAR1 <- eval.MAR1$pool[c(2, 1), c("bias", "cov", "ciw")]
MAR2 <- eval.MAR2$pool[c(2, 1), c("bias", "cov", "ciw")]

table <- rbind(MCAR, MAR1, MAR2)
table <- cbind(table[c(1, 3, 5), ], table[c(2, 4, 6), ])
rownames(table) <- c("MCAR", "MAR1", "MAR2")

xtable(table, digits = 3)

# % latex table generated in R 3.2.2 by xtable 1.8-0 package
# % Wed Feb  3 13:12:53 2016
# \begin{table}[ht]
# \centering
# \begin{tabular}{rrrrrrrr}
# \hline
# &\multicolumn{3}{c}{CCA} &&\multicolumn{3}{c}{imputation}	\\\cline{2-4}\cline{6-8}
# mechanism	& bias & cov & ciw && bias & cov & ciw \\ 
# \hline
# mcar & -0.001 & 0.948 & 0.175 && 0.001 & 0.945 & 0.156 \\ 
# mar ($\rho_{YX} = .8$) & 0.325 & 0.000 & 0.163 && -0.001 & 0.956 & 0.187 \\ 
# mar ($\rho_{YX} = .01$) & -0.013 & 0.962 & 0.176 && 0.017 & 0.954 & 0.310 \\ 
# \hline
# \end{tabular}
# \end{table}  