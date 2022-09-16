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
                    mech = c(rep("MCAR", 500),
                             rep("MAR (rho = .8)", 500),
                             rep("MAR (rho = .01)", 500)))
#reverse level order
data$mech <- factor(data$mech, levels = rev(levels(data$mech)))

#create plot
p <- ggplot(data, aes(Y, p.mis, colour = factor(mech)) ) + 
  geom_point() + geom_smooth(method = "lm") + scale_colour_discrete(guide=FALSE) + 
  facet_wrap(~ mech) + ylab("Probability to be missing") + xlab("Variable to ampute")
grob <- ggplotGrob(p)
grob$grobs$strip_t2$children[[2]]$label <- expression(paste("MAR [", rho == .8, "]"))
grob$grobs$strip_t3$children[[2]]$label <- expression(paste("MAR [", rho == 0, "]"))

grid.draw(grob)

#save plot as pdf
pdf("Tex/figures/plot_mmech.pdf", width = 8, height = 3)
  grid.draw(grob)
dev.off()
