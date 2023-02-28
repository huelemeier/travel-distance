

## LEAKY PARAMETERS
# This R script conveys the descriptive and inferential analysis of the alpha and k from the leaky model fit. The analysis includes data loading, descriptives, model fitting, post hoc analysis and plots.
# In case of further questions, please reach out to anna@huelemeier.de
# Github: https://github.com/huelemeier

### TABLE OF CONTENT
## SETUP
## GETTING STARTED
## DESCRIPTIVES
## MODEL FITTING
## MODEL CHECKS
## POST HOC ANALYSIS
## PLOTS



### SETUP // Install and activate packages from the library:
# Please activate the following packages for the following data analysis. If you haven't installed them yet, run the first chunk first.
my_packages <- c("readr", "ggplot2", "nortest", "grid", "gridExtra", "cowplot", "plyr", "dplyr", "QuantPsyc", "ggpubr", "ggsignif", "ggsci", "FSA", "dunn.test", "knitr", "base", "car", "RDocumentation", "onewaytests", "olsrr", "ggstatsplot", "PMCMRplus", "boot", "schoRsch", "dplyr", "ez", "nlme", "lsmeans", "lme4", "MCMCglmm", "rstatix", "lmerTest", "ggfortify", "lattice", "stringr", "reshape2", "pander", "foreach", "bestNormalize", "Hmisc", "pastecs", "RColorBrewer", "reshape2", "viridis", "scales", "devtools", "shadow", "nlme", "pscl", "aod", "MASS", "wesanderson", "moments", "pgirmess", "Rcpp", "lmerTest", "report", "emmeans", "multcomp", "report", "performance", "see", "parameters", "correlation", "insight", "e1071", "ggExtra", "hrbrthemes", "GGally", "tidyverse", "patchwork", "igraph", "ggraph", "colormap", "ggridges", "lawstat", "sm", "psycho", "rstanarm", "modelbased", "emmeans", "modelbased", "sjPlot", 'reportnormalitytests', 'lme4', 'perturb', 'sjlabelled', 'sjmisc') # remotes is the developper version of report
library(easypackages)
packages(my_packages) # install packages if necessary
libraries(my_packages) # load all packages
rm(my_packages)
# create folder to store saved images:
results <- "/Users/huelemeier/Desktop/results_distance/"





### GETTING STARTED  // load in the data set and rename columns
# The current section loads and preprocesses the data set for the descriptive and inferential analysis later on.  
# Please consider to write down your path where you store the data!
leaky <- read_delim("~/Desktop/leaky.txt", delim = "\t", escape_double = FALSE, col_names = T, trim_ws = TRUE)
colnames(leaky) = c('id', 'combination', 'ground', 'alpha', 'k')
leaky$combination <- as.factor(leaky$combination)
leaky$ground <- as.factor(leaky$ground)






### DESCRIPTIVES  // relevant for post hoc analyses to interpret the direction of the effects

# main effect ground:
round(leaky %>%
        group_by(as.numeric(ground)) %>% # grouping variables
        summarise_at(vars(alpha, k), # dependent variable
                     list(mean = mean, sd = sd)), 3) # Descriptives
# main effect walker combination
round(leaky %>%
        group_by(as.numeric(combination)) %>% # grouping variables
        summarise_at(vars(alpha, k), # dependent variable
                     list(mean = mean, sd = sd)), 3) # Descriptives
# interaction effect ground*combination
round(leaky %>%
        group_by(as.numeric(ground), as.numeric(combination)) %>% # grouping variables
        summarise_at(vars(alpha, k), # dependent variable
                     list(mean = mean, sd = sd)), 3) # Descriptives








### MODEL FITTING
# The inferential analyses we focussed on the leakage parameter alpha and gain factor k. 
# The data structure is based on a within-subject design with repeated measurements and two categorical independent variables with several levels. 
# As an appropriate procedure, we perform an analysis of variance by applying a mixed-modeling framework (LMM). 
# LMM benefits from higher flexibility, accurateness, and powerfulness for repeated-measures data (Kristensen, 2004; Jaeger, 2008) than traditional variance analyses.

# We analyzed separately, whether the magnitude of k or alpha depends on the walker combinations and the ground types. 
# We fitted LMM (estimated using restricted maximum likelihood criterion (REML) and nloptwrap optimizer) with random intercept and constant slope for participants. 
# This model predicted k respectively alpha the interaction of ground types and walker combinations. 
# We incorporated as factors the ground with two levels (gravel vs. stripes) and walker combinations with three levels (static vs. approaching vs. leaving). 
# Note the gravel ground and the static walker condition were set as references. The model included participant id as a random effect and conditions as fixed effects with four levels. 
# We obtained standardized parameters by fitting the model on a standardized version of the dataset. 
# The 95% Confidence Intervals (CIs) and p-values were aligned to the Wald approximation. Effect sizes were labeled following Field's (2013) recommendations.

modelk<- lmer(k ~ ground * combination + (1 | id), leaky) # model of the gain factor k
modelalpha <- lmer(alpha ~ ground * combination + (1 | id), leaky) # model of the leakage rate alpha
# get model parameters of the anova:
model_parameters(anova(modelk))
model_parameters(anova(modelalpha))
# automatically report anova:
report(anova(modelk))
report(anova(modelalpha))





### MODEL CHECK
# check model regarding convergence, normality, prediction accuracy, residuals, etc.

# check model perfomance, e.g. interclass correlation (ICC) as measure of subject variability
model_performance(modelk) 
model_performance(modelalpha) 

check_model((modelk))
check_model((modelalpha))

check_predictions(modelk)
check_predictions(modelalpha)

check_singularity(modelk)
check_singularity(modelalpha)

check_collinearity(modelk)
check_collinearity(modelalpha)

check_convergence(modelk)
check_convergence(modelalpha)

check_normality(modelk)
check_normality(modelalpha)





### POST HOC ANALYSIS
# In case of significant main and interaction effects between ground type and walker combination, you can calculate post hoc analyses with the Tukey method for p-adjustments (two-tailed testing):
emmeans(modelk, list(pairwise ~ ground), adjust = "tukey")
emmeans(modelalpha, list(pairwise ~ ground), adjust = "tukey")
mmeans(modelk, list(pairwise ~ combination), adjust = "tukey")
emmeans(modelalpha, list(pairwise ~ combination), adjust = "tukey")
emmeans(modelk, list(pairwise ~ ground*combination), adjust = "tukey")
emmeans(modelalpha, list(pairwise ~ ground*combination), adjust = "tukey")





### PLOTS
# The plots depict participants' leaky parameters (jittered) and the average parameters (coloured)

# create dataset for plots:
highlightmean <- leaky[1:6,1:5]
highlightmean$id <- 99
highlightmean$combination <- as.factor(c(1,2,3,1,2,3))
highlightmean$ground <- as.factor(c(1,1,1, 2,2,2))
highlightmean$alpha <- c(mean(subset(leaky,combination == 1 & ground == 1)$alpha),
                         mean(subset(leaky,combination == 2 & ground == 1)$alpha),
                         mean(subset(leaky,combination == 3 & ground == 1)$alpha),
                         mean(subset(leaky,combination == 1 & ground == 2)$alpha),
                         mean(subset(leaky,combination == 2 & ground == 2)$alpha),
                         mean(subset(leaky,combination == 3 & ground == 2)$alpha)) 
highlightmean$k <- c(mean(subset(leaky,combination == 1 & ground == 1)$k),
                     mean(subset(leaky,combination == 2 & ground == 1)$k),
                     mean(subset(leaky,combination == 3 & ground == 1)$k),
                     mean(subset(leaky,combination == 1 & ground == 2)$k),
                     mean(subset(leaky,combination == 2 & ground == 2)$k),
                     mean(subset(leaky,combination == 3 & ground == 2)$k)) 





# jitter plot of the leakage rate alpha
plot <- ggplot(leaky, aes(y = alpha, x = combination)) +
  geom_point(aes(shape = ground, group = ground, alpha = 0), color = "#E0E0E0", position = position_jitterdodge(dodge.width=0.8)) +
  geom_point(data=highlightmean, aes(x=combination, y=alpha, shape = factor(ground)), position = position_dodge(0.8), color=ifelse(highlightmean$alpha > 0.2,  "#D9345D",'#2A64AE'),
             size=4)+
  theme_classic2() + 
  theme(strip.text.x = element_text(size=10),
        strip.background = element_rect(color = "white"),
        panel.background = element_rect(fill = "#F9F9F9"),
        text = element_text(size=8,  family="Helvetica"), 
        element_line(size=0.1),
        legend.position='bottom',
        plot.title.position = "plot",
        legend.justification = "left",
        axis.title.x = element_text(hjust = 0),
        axis.title.y = element_text(hjust = 1),
        plot.title = element_text(size=10, family="Helvetica", hjust = 0, face = "bold"),
        axis.text = element_text(size=8), 
        legend.key.size = unit(2, "mm"),
        axis.text.x = element_text(angle = 0, hjust=0.5)) +
  guides(shape = guide_legend(order = 1, title = "ground type", reverse = F, nrow=1), alpha = "none") + 
  scale_shape_discrete(labels=c(expression(paste("gravel")), 
                                expression(paste("stripes")) )) +
  scale_x_discrete(name="walker condition", breaks = c(1,2,3), labels=c("static", "approaching", "leaving")) +
  scale_y_continuous(name="leakage rate alpha")
ggsave(plot, file=paste(results, "alpha jitter plot", ".png", sep=''), units = "in", height = 3.9, width = 4.6,  dpi = 900)




# jitter plot of the gain factor k
plot <- ggplot(leaky, aes(y = k, x = combination)) +
  geom_point(aes(shape = ground, group = ground, alpha = 0), color = "#E0E0E0", position = position_jitterdodge(dodge.width=0.8)) +
  geom_point(data=highlightmean, aes(x=combination, y=k, shape = factor(ground)), position = position_dodge(0.8), color=ifelse(highlightmean$k > 1.5,  "#D9345D",'#2A64AE'),
             size=4)+
  theme_classic2() + 
  theme(strip.text.x = element_text(size=10),
        strip.background = element_rect(color = "white"),
        panel.background = element_rect(fill = "#F9F9F9"),
        text = element_text(size=8,  family="Helvetica"), 
        element_line(size=0.1),
        legend.position='bottom',
        plot.title.position = "plot",
        legend.justification = "left",
        axis.title.x = element_text(hjust = 0),
        axis.title.y = element_text(hjust = 1),
        plot.title = element_text(size=10, family="Helvetica", hjust = 0, face = "bold"),
        axis.text = element_text(size=8), 
        legend.key.size = unit(2, "mm"),
        axis.text.x = element_text(angle = 0, hjust=0.5)) +
  guides(shape = guide_legend(order = 1, title = "ground type", reverse = F, nrow=1), alpha = "none") + 
  scale_shape_discrete(labels=c(expression(paste("gravel")), 
                                expression(paste("stripes")) )) +
  scale_x_discrete(name="walker condition", breaks = c(1,2,3), labels=c("static", "approaching", "leaving")) +
  scale_y_continuous(name="gain factor k")
ggsave(plot, file=paste(results, "k jitter plot", ".pdf", sep=''), units = "in", height = 3.9, width = 4.6)



# posthoc analysis plot of the leackage rate alpha
plot <- ggplot(subset(leaky, ground == 2), aes(y = alpha, x = (combinationplot))) +
  # Hintergrund gestrichelte Linien
  geom_hline(yintercept = 0.3, size = 0.09, color = "#161412", linetype = "dotted") + 
  geom_hline(yintercept = 0.2, size = 0.09, color = "#161412", linetype = "dotted") + 
  geom_hline(yintercept = 0.1, size = 0.09, color = "#161412", linetype = "dotted") + 
  geom_hline(yintercept = 0, size = 0.09, color = "#161412", linetype = "dotted") + 
  
  # load in data:
  geom_point(data=subset(highlightmean, ground == 2), aes(x=(combinationplot), y=alpha, color=factor(combinationplot)), position = position_dodge(0.8), size=4.5) +
  geom_pointrange(data=subset(highlightmean, ground == 2), aes(y=(alpha), ymin = alpha-alphasd, ymax=alpha+alphasd, x=(combinationplot), group = combinationplot, color=factor(combinationplot)), position = position_dodge(.9), linewidth=0.7) +
  
  # annotations
  geom_text(data=highlightmean %>% filter(combinationplot == 2 & ground == 2), x=1.5, y=0.33, label="*", size=4.3, color="#161412", check_overlap = TRUE, hjust = 0) + 
  geom_segment(data=highlightmean %>% filter(combinationplot == 2 & ground == 2), aes(y=0.31, x = 1.1, yend = 0.31, xend = 1.9), size = 0.2, color="#161412") +

  # general layout
  theme_classic2() + 
  theme(strip.text.x = element_text(size=8.5),
        strip.background = element_rect(color = "white"),
        panel.background = element_rect(fill = "white"), ##F9F9F9
        text = element_text(size=8.5,  family="Helvetica"), 
        element_line(size=0.1),
        legend.position='none',
        plot.title.position = "plot",
        legend.justification = "left",
        axis.title.x = element_text(hjust = 0),
        axis.title.y = element_text(hjust = 1),
        plot.title = element_text(size=10, family="Helvetica", hjust = 0, face = "bold"),
        axis.text = element_text(size=8.5), 
        legend.key.size = unit(2, "mm"),
        panel.spacing = unit(0.5, "cm"),
        axis.text.x = element_text(angle = 0, hjust=0.5)) +
  scale_color_manual(values = colourscheme) + 
  scale_x_discrete(name="", breaks = c(1, 2, 3), labels=c("static", "approaching", "leading")) +
  scale_y_continuous(name="Leakage rate alpha", limits = c(-0.01, 0.35))
ggsave(plot, file=paste(results, "alpha post hoc", ".pdf", sep=''), units = "in", height = 3.17, width = 2.5)



# posthoc analysis plot of the gain factor k
plot <- ggplot(subset(leaky, ground == 2), aes(y = k, x = combinationplot)) +
  # Hintergrund gestrichelte Linien
  geom_hline(yintercept = 1, size = 0.09, color = "#161412", linetype = "dotted") + 
  geom_hline(yintercept = 1.25, size = 0.09, color = "#161412", linetype = "dotted") + 
  geom_hline(yintercept = 1.5, size = 0.09, color = "#161412", linetype = "dotted") + 
  geom_hline(yintercept = 1.75, size = 0.09, color = "#161412", linetype = "dotted") + 
  
  # load in data
  geom_point(data=subset(highlightmean, ground == 2), aes(x=combinationplot, y=k, color=factor(combinationplot)), position = position_dodge(0.8), size=4.5) +
  geom_pointrange(data = subset(highlightmean, ground == 2), aes(y=(k), ymin = k-ksd, ymax=k+ksd, x=combinationplot, group = combinationplot, color=factor(combinationplot)), position = position_dodge(.9), linewidth=0.7) +
  
  # annotations
  geom_text(data=highlightmean %>% filter(combinationplot == 2 & ground == 1), x=1.45, y=1.72, label="*", size=4.3, color="#161412", check_overlap = TRUE, hjust = 0) + 
  geom_segment(data=highlightmean %>% filter(combinationplot == 2 & ground == 1), aes(y=1.67, x = 1.1, yend = 1.67, xend = 1.9), size = 0.2, color="#161412") +
  geom_text(data=highlightmean %>% filter(combinationplot == 2 & ground == 2), x=2.5, y=1.72, label="*", size=4.3, color="#161412", check_overlap = TRUE, hjust = 0) + 
  geom_segment(data=highlightmean %>% filter(combinationplot == 2 & ground == 2), aes(y=1.67, x = 2.1, yend = 1.67, xend = 2.9), size = 0.2, color="#161412") +
  
  theme_classic2() + 
  theme(strip.text.x = element_text(size=8.5),
        strip.background = element_rect(color = "white"),
        panel.background = element_rect(fill = "white"), # #F9F9F9
        text = element_text(size=8.5,  family="Helvetica"), 
        element_line(size=0.1),
        legend.position='none',
        plot.title.position = "plot",
        legend.justification = "left",
        axis.title.x = element_text(hjust = 0),
        axis.title.y = element_text(hjust = 1),
        plot.title = element_text(size=10, family="Helvetica", hjust = 0, face = "bold"),
        axis.text = element_text(size=8.5), 
        legend.key.size = unit(2, "mm"),
        panel.spacing = unit(0.5, "cm"),
        axis.text.x = element_text(angle = 0, hjust=0.5)) +
  scale_color_manual(values = colourscheme) + 
  scale_x_discrete(name="", breaks = c(1, 2, 3), labels=c("static", "approaching", "leading")) +
  scale_y_continuous(name="Gain factor k", limits = c(0.87, 1.86))
ggsave(plot, file=paste(results, "k post hoc", ".pdf", sep=''), units = "in", height = 3.17, width = 2.5)




### END.

