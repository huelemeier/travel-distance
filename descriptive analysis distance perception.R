### DESCRIPTIVES ANALYSIS OF DISTANCE ESTIMATES
# This R script provides descriptive analysis of distance data 
# In case of further questions, please reach out to anna@huelemeier.de
# Github: https://github.com/huelemeier

### TABLE OF CONTENT:
## SETUP
## GETTING STARTED
## DESCRIPTIVES
## DATA CHECK
## PLOTS OF ESTIMATED DISTANCES



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

dforiginal <- read_delim("~/Desktop/distance.txt", delim = "\t", escape_double = FALSE, col_names = FALSE, trim_ws = TRUE)
colnames(dforiginal) <- c("id", "session", "trial", "grav", "translating", "articulating", "facing", "my", "mx", "move_line", "traveldistance", "travelduration", "travelvelocity", "tspeed", "nframes", "estimateddistance", "estimatederror", "timestemp", "numsecs", "ground", "block")
dforiginal$condition <- 2 # natural locomotion condition
dforiginal$condition[dforiginal$articulating == 0] <- 1 # static condition

# code the combination of condition and walker facing
dforiginal$combination <- 1 # static
dforiginal$combination[dforiginal$condition == 2 & dforiginal$facing == 0] <- 2 # approaching
dforiginal$combination[dforiginal$condition == 2 & dforiginal$facing == 180] <- 3 # leaving

## as data check: make sure estimates were above the starting line:
table(dforiginal$estimateddistance < 0.9)
data <- subset(dforiginal, estimateddistance > 0.9)
df <- subset(dforiginal, estimateddistance < 0.9)
df <- data.frame(df$id, df$trial, df$block, df$traveldistance, df$travelvelocity, df$ground, df$combination, df$articulating, df$translating, df$facing)

# factorize independent variables for later analyses.
data$ground <- as.factor(data$ground)
data$combination <- as.factor(data$combination)
data$id <- as.factor(data$id)

# Descriptives
# Descriptive analysis includes mean, median and sd of dependent variables depending on the stimulus combination. Descriptive analysis also checks whether distance estiamtes per travel velcotiy (3 different velocities) differ in their distribution





### DESCRIPTIVES // relevant for post hoc analyses to interpret the direction of the effects

# Ground:
round(data %>%
        group_by(as.numeric(ground)) %>% # grouping variables
        summarise_at(vars(estimateddistance), # dependent variable
                     list(mean = mean, sd = sd, var)), 2) # Descriptives
# Combination:
round(data %>%
        group_by(as.numeric(combination)) %>% # grouping variables
        summarise_at(vars(estimateddistance), # dependent variable
                     list(mean = mean, sd = sd,)), 2) # Descrptives

# interaction ground (stripes vs. gravel) * walker combination (static, approaching, leaving):
round(data %>%
        group_by(as.numeric(ground), as.numeric(combination)) %>% # grouping variables
        summarise_at(vars(estimatederror), # dependent variable
                     list(mean = mean, sd = sd)), 3) # Descriptives




# Is there a relation between estimated distance and travel velocity?
# descriptive analysis:
round(data %>%
        group_by(travelvelocity) %>% # grouping variables
        summarise_at(vars(estimatederror), # dependent variable
                     list(mean = mean, sd = sd)), 3) # Descriptives

# Inferential analysis comparing data distribution using Chi-squared test:
chisq.test(table(subset(dforiginal, id != 29 & travelvelocity == 0.3965 & traveldistance < 9)$estimateddistance, subset(dforiginal, id != 29 & travelvelocity == 0.7930 & traveldistance < 9)$estimateddistance))
chisq.test(table(subset(dforiginal, id != 29 & travelvelocity == 1.1895 & traveldistance > 9)$estimateddistance, subset(dforiginal, id != 29 & travelvelocity == 0.7930 & traveldistance > 9)$estimateddistance))
# At the 5% significance level, the data provides evidence to conclude that there is an association between travel velocity and estimated distance.



### DATA CHECK
# Check if participants could solve the task by correlating traveled distance with distance estimates. 
# gravel ground:
by(data, data$id, function(data) (lm(estimateddistance ~ traveldistance, data = subset(data, ground == 1 & condition == 2))))
by(data, data$id, function(data) (lm(estimateddistance ~ traveldistance, data = subset(data, ground == 1 & facing == 180))))

# stripes ground:
by(data, data$id, function(data) (lm(estimateddistance ~ traveldistance, data = subset(data, ground == 2 & facing == 0))))
by(data, data$id, function(data) (lm(estimateddistance ~ traveldistance, data = subset(data, ground == 2 & facing == 180))))


# Next check whether distance gauges were significantly larger than the starting line (0.9). Non-significant results would indicate participants perceived no self-motion at all.
# As prerequisite, check normal distribution assumption:
by(data, data$travelvelocity, function (data) (ad.test(subset(data, ground == 1 & combination == 1)$estimateddistance))) 
by(data, data$travelvelocity, function (data) (ad.test(subset(data, ground == 1 & combination == 2)$estimateddistance)))  
# If data are not normally distributed, apply wilcoxon test as the non-parametric alternative of a paired t-test.
by(data, data$combination, function (data) wilcox.test(subset(data, ground == 1)$estimateddistance, mu = 0.9, alternative = "greater", conf.int = T)) 
by(data, data$combination, function (data) wilcox.test(subset(data, ground == 2)$estimateddistance, mu = 0.9, alternative = "greater", conf.int = T)) 
by(data, data$combination, function (data) t.test(subset(data, ground == 1)$estimateddistance, mu = 0.9, alternative = "greater"))
by(data, data$combination, function (data) t.test(subset(data, ground == 2)$estimateddistance, mu = 0.9, alternative = "greater"))







### PLOTS OF ESTIMATED DISTANCES
# The first plot depicts data one out of three travel velocities, while the second one distinguishes between velocities. 
# The plots show mean plus standard deviations.
# You can adapt the plot according to your research question.

# Labelling:
walkerlabels <- c("0" = "approaching crowd", "180" = "leaving crowd")
groundlabels <- c("1" = "gravel", "2" = "stripes")
conditionlabels <- c("1" = "static", "2" = "natural locomotion")

# First plot: moving crowd with different colours for approaching vs leaving, and normal self-motion speed:
plot <- ggplot(subset(data, combination == 2 & travelvelocity == 0.7930), aes(y = estimateddistance, x = (traveldistance), color = factor(facing))) +
  ggtitle("Travel distance estimation across velocities in the presence of biological motion") +
  theme_classic2() +
  geom_smooth(method = "lm", alpha = 0.5, se = F, size = 0.3) +
  facet_wrap(~ ground * condition, labeller = labeller(ground = groundlabels, condition = conditionlabels)) +
  scale_color_manual("walker facing", values = c("#2A64AE", "#D9345D"), breaks = c(0, 180), labels = c("approaching", "leaving")) +
  stat_summary(
    mapping = aes(x = traveldistance, y = estimateddistance),
    fun.ymin = function(z) {
      mean(z) - sd(z) },
    fun.ymax = function(z) {
      mean(z) + sd(z)  },
    fun.y = mean, size = 0.2, position = position_dodge(width = 0.9)) +
  theme(
    strip.text.x = element_text(size = 7),
    strip.background = element_rect(color = "white"),
    panel.background = element_rect(fill = "#F9F9F9"),
    axis.title.x = element_text(hjust = 0),
    axis.title.y = element_text(hjust = 1),
    text = element_text(size = 6, family = "Helvetica"),
    element_line(size = 0.1),
    legend.position = "bottom",
    plot.title = element_text(size = 7, family = "Helvetica", hjust = 0, face = "bold"),
    plot.title.position = "plot",
    axis.text = element_text(size = 5),
    legend.key.size = unit(2, "mm") ) +
  scale_x_continuous(name = "        traveled distance", breaks = c(4, 5.66, 8, 11.31, 16, 22.63)) +
  scale_y_continuous(name = "estimated distance (in m)            ")
ggsave(plot, file = paste(results, "natural locomotion mean sd distance estimation approaching crowd", ".pdf", sep = ""), units = "in", width = 8.4, height = 8.4)



# second plot with distance estimates per travel speed
plot <- ggplot((data), aes(y = estimateddistance, x = (traveldistance), color = factor(travelvelocity))) +
  ggtitle("Travel distance estimation in the presence of biological motion // all travel speeds") +
  theme_classic2() +
  geom_smooth(method = "lm", alpha = 0.8, se = F, size = 0.5) +
  facet_wrap(~ ground * facing * condition, labeller = labeller(facing = walkerlabels, ground = groundlabels, condition = conditionlabels)) +
  scale_color_manual("travel velocity", values = c("#F3C067", "#87C8C1", "#E06957"), guide = guide_legend(nrow = 1)) +
  stat_summary(
    mapping = aes(x = traveldistance, y = estimateddistance),
    fun.ymin = function(z) {
      mean(z) - sd(z) },
    fun.ymax = function(z) {
      mean(z) + sd(z)  },
    fun.y = mean, size = 0.4, position = position_dodge(width = 0.9) ) +
  theme(
    strip.text.x = element_text(size = 7),
    strip.background = element_rect(color = "white"),
    panel.background = element_rect(fill = "#F9F9F9"),
    axis.title.x = element_text(hjust = 0),
    axis.title.y = element_text(hjust = 1),
    text = element_text(size = 6, family = "Helvetica"),
    element_line(size = 0.1),
    legend.position = "bottom",
    plot.title = element_text(size = 7, family = "Helvetica", hjust = 0, face = "bold"),
    plot.title.position = "plot",
    axis.text = element_text(size = 5),
    legend.key.size = unit(2, "mm") ) +
  scale_x_continuous(name = "  traveled distance", breaks = c(4, 5.66, 8, 11.31, 16, 22.63)) +
  scale_y_continuous(name = "estimated distance (in m)        ")
ggsave(plot, file = paste(results, "mean sd distance estimation per travel speed", ".pdf", sep = ""), units = "in", width = 14, height = 14)




### END.


