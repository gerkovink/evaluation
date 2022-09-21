#create plot script
require(ggplot2)
load("1. Simulate_MCARvMAR.RData")
#extract missingness probabilities
p.mcar <- output.MCAR[[1]]$incompl$p.mis
p.mar1 <- output.MAR1[[1]]$incompl$p.mis
p.mar2 <- output.MAR2[[1]]$incompl$p.mis

#format data correctly
data  <- data.frame(Y = rep(compl[, 1],3), 
                    p.mis = c(p.mcar, p.mar1, p.mar2),
                    mech = as.factor(c(rep("MCAR", 500),
                             rep("MAR (rho = .8)", 500),
                             rep("MAR (rho = .0)", 500))))
#reverse level order
data$mech <- factor(data$mech, levels = rev(levels(data$mech)))
levels(data$mech) <- c("MCAR", 
                       expression(paste("right-tailed MAR (", rho == .8, ")")),
                       expression(paste("right-tailed MAR (", rho == 0, ")")))

#create plot
p <- ggplot(data, aes(Y, p.mis, colour = factor(mech)) ) + 
  geom_point() + 
  geom_smooth(method = "lm", colour = "black") + 
  theme_classic() +
  scale_colour_discrete(guide="none") + 
  facet_grid(. ~ mech, labeller = label_parsed) + 
  ylab("Probability to be missing") + 
  xlab("Variable to ampute")

#save plot as pdf
pdf("plot_mmech.pdf", width = 8, height = 3)
  p
dev.off()
