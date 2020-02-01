rm(list=ls())
data.dir <- ("~/Documents/oleary/MIDnSST/Drug and Alcohol Dependence/MID/")
setwd(data.dir)


###################################################################################
######################### NEURAL AVTIVATION DATA ##################################
###################################################################################

df = read.csv("AllGainv0Hit_noICA.csv", header = FALSE)
names(df) <- c("sub","roi","run","percent")

library(dplyr)
library(tidyr)
run1 = df %>%
  filter(run == 1)
run2 = df %>%
  filter(run == 2)
run3 = df %>%
  filter(run == 3)

mean_across_runs <- rep (0, length(run1$sub))

for (i in 1:length(run1$sub)) {
  mean_across_runs[i] <- (run1$percent[i] + run2$percent[i] + run3$percent[i])/3
}

dflong = data.frame(run1$sub, run1$roi,mean_across_runs)
names(dflong) <- c("sub", "roi", "percent_signal_change")


dfwide <- spread(dflong, roi, percent_signal_change)

group <- read.csv("group.csv",header = FALSE)
group$groupfac <- factor(group$V1, levels=c(1,2,3,4,5), labels=c("Control", 
                                                                 "sBinge",
                                                                 "eBinge",
                                                                 "MJ+sBinge",
                                                                 "MJ+eBinge"))

dfwide$group <- group[,"groupfac"]
dfwide$group_num <- group[,"V1"]
write.csv(dfwide, file = "AllGainv0Hit_noICA_wide.csv")


## Multiple one way ANOVAs across all ROIs: Nothing survive FDR correction
# create a list of names of variables of interest
dependent_vars <- list(print(dfwide[2:7]))
p_anova <- rep (0, length(dependent_vars[[1]]))
# Test Group effect using ANOVA on percent signal change across all rois
for (i in 1:length(dfwide$sub)){
  aov <- summary(aov(dependent_vars[[1]][[i]] ~ dfwide$group, data=dfwide))
  p_anova[i] <- aov[[1]][["Pr(>F)"]]
  cat(paste('\nDependent var:', names(dependent_vars[[1]][i]), '\n'))
  print(aov)
}

p_fdr <- p.adjust(p_anova, method = c("fdr"), n = length(p_anova))
p_fdr




##################################################################
##################################################################
##################################################################

df = read.csv("AllLossv0Hit_noICA.csv", header = FALSE)
names(df) <- c("sub","roi","run","percent")

library(dplyr)
library(tidyr)
run1 = df %>%
  filter(run == 1)
run2 = df %>%
  filter(run == 2)
run3 = df %>%
  filter(run == 3)

mean_across_runs <- rep (0, length(run1$sub))

for (i in 1:length(run1$sub)) {
  mean_across_runs[i] <- (run1$percent[i] + run2$percent[i] + run3$percent[i])/3
}

dflong = data.frame(run1$sub, run1$roi,mean_across_runs)
names(dflong) <- c("sub", "roi", "percent_signal_change")


dfwide <- spread(dflong, roi, percent_signal_change)

group <- read.csv("group.csv",header = FALSE)
group$groupfac <- factor(group$V1, levels=c(1,2,3,4,5), labels=c("Control", 
                                                                 "sBinge",
                                                                 "eBinge",
                                                                 "MJ+sBinge",
                                                                 "MJ+eBinge"))

dfwide$group <- group[,"groupfac"]
dfwide$group_num <- group[,"V1"]
write.csv(dfwide, file = "AllLossv0Hit_noICA_wide.csv")

## Multiple one way ANOVAs across all ROIs: Nothing survive FDR correction
# create a list of names of variables of interest
dependent_vars <- list(print(dfwide[2:7]))
p_anova <- rep (0, length(dependent_vars[[1]]))
# Test Group effect using ANOVA on percent signal change across all rois
for (i in 1:length(dfwide$sub)){
  aov <- summary(aov(dependent_vars[[1]][[i]] ~ dfwide$group, data=dfwide))
  p_anova[i] <- aov[[1]][["Pr(>F)"]]
  cat(paste('\nDependent var:', names(dependent_vars[[1]][i]), '\n'))
  print(aov)
}

p_fdr <- p.adjust(p_anova, method = c("fdr"), n = length(p_anova))
p_fdr

##################################################################
#################### Gain 5 vs Gain 0 hit ########################
##################################################################

df = read.csv("Gain5v0Hit_noICA.csv", header = FALSE)
names(df) <- c("sub","roi","run","percent")

library(dplyr)
library(tidyr)
run1 = df %>%
  filter(run == 1)
run2 = df %>%
  filter(run == 2)
run3 = df %>%
  filter(run == 3)

mean_across_runs <- rep (0, length(run1$sub))

for (i in 1:length(run1$sub)) {
  mean_across_runs[i] <- (run1$percent[i] + run2$percent[i] + run3$percent[i])/3
}

dflong = data.frame(run1$sub, run1$roi,mean_across_runs)
names(dflong) <- c("sub", "roi", "percent_signal_change")


dfwide <- spread(dflong, roi, percent_signal_change)

group <- read.csv("group.csv",header = FALSE)
group$groupfac <- factor(group$V1, levels=c(1,2,3,4,5), labels=c("Control", 
                                                                 "sBinge",
                                                                 "eBinge",
                                                                 "MJ+sBinge",
                                                                 "MJ+eBinge"))

dfwide$group <- group[,"groupfac"]
dfwide$group_num <- group[,"V1"]
dfwide$tobacco <- group[,"V2"]

write.csv(dfwide, file = "Gain5v0Hit_noICA_wide.csv")

################################### excluding 14 ####################################

dfwide <- dfwide[!(dfwide$sub %in% 
               c("3043", "3055", "3096", "4101", "3034", "3070", "3133", 
                 "5000", "5037", "5009", "5015", "5051", "5052", "5066")), ] 

## Multiple ANCOVAs: group difference for each ROI, tobacco = covariate
# create a list of names of variables of interest
p_ancova <- rep (0, 6)
rcorr(as.matrix(dfwide[2:7]), type="pearson") 

for (i in 2:7) {
    ancova <- Anova(lm(unlist(dfwide[i]) ~ group + tobacco,
                       contrasts=list(group=contr.sum), data=dfwide), type="III")
    p_ancova[i-1] <- ancova$"Pr(>F)"[2]
    cat(paste('\nRoi:', names(dfwide[i]), '\n'))
    print(ancova)
}

p_fdr <- p.adjust(p_ancova, method = c("fdr"), n = length(p_ancova))
p_fdr

###################################
## Multiple one way ANOVAs across all ROIs
# create a list of names of variables of interest
dependent_vars <- list(print(dfwide[2:7]))
p_anova <- rep (0, length(dependent_vars[[1]]))
# Test Group effect using ANOVA on percent signal change across all rois
for (i in 1:length(dfwide$sub)){
  aov <- summary(aov(dependent_vars[[1]][[i]] ~ dfwide$group, data=dfwide))
  p_anova[i] <- aov[[1]][["Pr(>F)"]]
  cat(paste('\nDependent var:', names(dependent_vars[[1]][i]), '\n'))
  print(aov)
}

p_fdr <- p.adjust(p_anova, method = c("fdr"), n = length(p_anova))
p_fdr


lVS <- aov(dfwide$lVS ~ dfwide$group, 
            data=dfwide)
TukeyHSD(lVS)

library("car")
leveneTest(lVS ~ group, data = dfwide)
# Run Shapiro-Wilk test
shapiro.test(x = lVS[["residuals"]] )

d <- lVS[["model"]][["dfwide$group"]]
d <- as.character(d)

qqnorm(lVS[["residuals"]][d=="Control"])

####################################################################################
####################################################################################
####################################################################################
library(ggplot2)

dfwide <- read.csv("~/Documents/oleary/MIDnSST/new-recentuse/MID/Gain5v0Hit_noICA_wide.csv")
dfwide$group <- factor(dfwide$group_num, levels=c(1,2,3,4,5), labels=c("Control", 
                                                                 "sBinge",
                                                                 "eBinge",
                                                                 "MJ+sBinge",
                                                                 "MJ+eBinge"))
ggplot(dfwide, aes(group,lVS)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  ggtitle("Left Ventral Striatum Gain $5 vs. Neutral") +
  ylab("Percent Signal Change") +
  theme(plot.title = element_text(size=16, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank()
  ) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lVS), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=14,face="bold"),
        axis.title.y = element_text(size=15,face="bold"),
        axis.text.y = element_text(size=13,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=5)

ggplot(dfwide, aes(group,rVS)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  ggtitle("Right Ventral Striatum Gain $5 vs. Neutral") +
  ylab("Percent Signal Change") +
  theme(plot.title = element_text(size=16, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank()
  ) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,rVS), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=14,face="bold"),
        axis.title.y = element_text(size=15,face="bold"),
        axis.text.y = element_text(size=13,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=5)


######################## lMPFC ##########################
hist(dfwide$lMPFC)
shapiro.test(x = dfwide$lMPFC)
boxplot(dfwide$lMPFC, data=dfwide)

lMPFC <- aov(dfwide$lMPFC ~ dfwide$group,data=dfwide)
summary(lMPFC)

leveneTest(lMPFC ~ group, data = dfwide)
shapiro.test(x = lMPFC[["residuals"]] )

ggplot(dfwide, aes(group,lMPFC)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lMPFC), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

######################## lVS ##########################
hist(dfwide$lVS)
shapiro.test(x = dfwide$lVS)
boxplot(dfwide$lVS, data=dfwide)

sink(file="Gain5-results.txt")
library("car")
lVS_lm <- lm(lVS ~ group,data=dfwide)
summary(lVS_lm) # type III SS
library("lsr")
etaSquared(lVS_lm, type = 3, anova = FALSE )

leveneTest(lVS ~ group, data = dfwide)
shapiro.test(x = lVS_lm[["residuals"]] )

pairwise.t.test(dfwide$lVS, dfwide$group, pool.sd = T, p.adjust.method = c("BH"))
pairwise.t.test(dfwide$lVS, dfwide$group, pool.sd = T, p.adjust.method = c("none"))


control_lVS <- as.numeric(unlist(dfwide %>%
                                   filter(group == "Control") %>%
                                   select(lVS)))
sBinge_lVS <- as.numeric(unlist(dfwide %>%
                                  filter(group == "sBinge") %>%
                                  select(lVS)))
eBinge_lVS <- as.numeric(unlist(dfwide %>%
                                  filter(group == "eBinge") %>%
                                  select(lVS)))
MJsBinge_lVS <- as.numeric(unlist(dfwide %>%
                                    filter(group == "MJ+sBinge") %>%
                                    select(lVS)))
MJeBinge_lVS <- as.numeric(unlist(dfwide %>%
                                    filter(group == "MJ+eBinge") %>%
                                    select(lVS)))

library("effsize")
cohen.d(MJsBinge_lVS, control_lVS,pooled=TRUE,paired=FALSE, na.rm=FALSE, hedges.correction=FALSE,
        conf.level=0.95,noncentral=FALSE)
cohen.d(MJsBinge_lVS, sBinge_lVS,pooled=TRUE,paired=FALSE, na.rm=FALSE, hedges.correction=FALSE,
        conf.level=0.95,noncentral=FALSE)
cohen.d(MJsBinge_lVS, eBinge_lVS,pooled=TRUE,paired=FALSE, na.rm=FALSE, hedges.correction=FALSE,
        conf.level=0.95,noncentral=FALSE)
cohen.d(MJsBinge_lVS, MJeBinge_lVS,pooled=TRUE,paired=FALSE, na.rm=FALSE, hedges.correction=FALSE,
        conf.level=0.95,noncentral=FALSE)

ttest_MJsBinge_eBinge <- lm(lVS ~ group, data = subset(dfwide, group_num %in% c(3,4)))
summary(ttest_MJsBinge_eBinge)
d_MJsBinge_eBinge = 0.10681/0.1964 #estimated std/residual SE

lVS_lm <- lm(lVS ~ group,data=dfwide)


lVS_compare <- list(c("eBinge", "MJ+sBinge"),
                    c("sBinge", "MJ+sBinge"),
                    c("Control", "MJ+sBinge"),
                    c("MJ+eBinge", "MJ+sBinge"))
ggplot(dfwide, aes(group,lVS)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  ylab("Percent Signal Change") +
  theme(plot.title = element_text(size=16, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank()
  ) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lVS), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=14,face="bold"),
        axis.title.y = element_text(size=15,face="bold"),
        axis.text.y = element_text(size=13,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4) +
  stat_compare_means(comparisons = lVS_compare)


######################## rVS ##########################
hist(dfwide$rVS)
shapiro.test(x = dfwide$rVS)
describe(dfwide$rVS, data = subset(dfwide, group %in% c("Control")))

control_rVS <- dfwide %>% 
  filter(group_num == 1) %>%
  select(rVS)%>%
  summarise_all(funs(min = min, 
                      q25 = quantile(., 0.25), 
                      median = median, 
                      q75 = quantile(., 0.75), 
                      max = max,
                      mean = mean, 
                      sd = sd,
                      iqr = q75 - q25))


rVS_lm <- lm(rVS ~ group,data=dfwide)
summary(rVS_lm) # type III SS
etaSquared(rVS_lm, type = 3, anova = FALSE )
leveneTest(rVS ~ group, data = dfwide)
shapiro.test(x = rVS_lm[["residuals"]] )
pairwise.t.test(dfwide$rVS, dfwide$group, pool.sd = F, p.adjust.method = c("BH"))

Control_rVS <- as.numeric(unlist(dfwide %>%
                                    filter(group == "Control") %>%
                                    select(rVS)))
MJsBinge_rVS <- as.numeric(unlist(dfwide %>%
                                    filter(group == "MJ+sBinge") %>%
                                    select(rVS)))
MJeBinge_rVS <- as.numeric(unlist(dfwide %>%
                                    filter(group == "MJ+eBinge") %>%
                                    select(rVS)))
cohen.d(MJsBinge_lVS, control_lVS,pooled=FALSE,paired=FALSE, na.rm=FALSE, hedges.correction=FALSE,
        conf.level=0.95,noncentral=FALSE)
cohen.d(MJsBinge_lVS, MJeBinge_lVS,pooled=FALSE,paired=FALSE, na.rm=FALSE, hedges.correction=FALSE,
        conf.level=0.95,noncentral=FALSE)


dfwide_excOUT <- subset(dfwide, -0.1 < rVS  & rVS < 1)
rVS_lm <- lm(rVS ~ group,data=dfwide_excOUT)
summary(rVS_lm) # type III SS
etaSquared(rVS_lm, type = 3, anova = FALSE )
leveneTest(rVS ~ group, data = dfwide_excOUT)
shapiro.test(x = rVS_lm[["residuals"]] )
pairwise.t.test(dfwide_excOUT$rVS, dfwide_excOUT$group, pool.sd = F, p.adjust.method = c("BH"))


library("car")
leveneTest(rVS ~ group, data = dfwide) #violated - use Welch
# Run Shapiro-Wilk test
shapiro.test(x = rVS[["residuals"]] )

rVS_welch = oneway.test(dfwide$rVS ~ dfwide$group,data=dfwide)
library("onewaytests")
bf.test(rVS ~ group,data=dfwide, alpha = 0.05, na.rm = TRUE, verbose = TRUE)

install.packages("userfriendlyscience")
library("userfriendlyscience")
posthocTGH(dfwide$rVS, dfwide$group, method=c("games-howell"),
           conf.level = 0.95, digits=2, p.adjust="BH",
           formatPvalue = TRUE)
pairwise.t.test(dfwide$rVS, dfwide$group, pool.sd = T, p.adjust.method = c("BH"))



rVS_compare <- list(c("Control", "MJ+sBinge"),
                    c("MJ+eBinge", "MJ+sBinge"))
ggplot(dfwide, aes(group,rVS)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  ylab("Percent Signal Change") +
  theme(plot.title = element_text(size=16, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank()
  ) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,rVS), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=14,face="bold"),
        axis.title.y = element_text(size=15,face="bold"),
        axis.text.y = element_text(size=13,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4) +
  stat_compare_means(comparisons = rVS_compare)



##################################################################
##################################################################
##################################################################

df = read.csv("Loss5v0Hit_noICA.csv", header = FALSE)
names(df) <- c("sub","roi","run","percent")

library(dplyr)
library(tidyr)
run1 = df %>%
  filter(run == 1)
run2 = df %>%
  filter(run == 2)
run3 = df %>%
  filter(run == 3)

mean_across_runs <- rep (0, length(run1$sub))

for (i in 1:length(run1$sub)) {
  mean_across_runs[i] <- (run1$percent[i] + run2$percent[i] + run3$percent[i])/3
}

dflong = data.frame(run1$sub, run1$roi,mean_across_runs)
names(dflong) <- c("sub", "roi", "percent_signal_change")


dfwide <- spread(dflong, roi, percent_signal_change)

group <- read.csv("group.csv",header = FALSE)
group$groupfac <- factor(group$V1, levels=c(1,2,3,4,5), labels=c("Control", 
                                                                 "sBinge",
                                                                 "eBinge",
                                                                 "MJ+sBinge",
                                                                 "MJ+eBinge"))

dfwide$group <- group[,"groupfac"]
dfwide$group_num <- group[,"V1"]
dfwide$tobacco <- group[,"V2"]
write.csv(dfwide, file = "Loss5v0Hit_noICA_wide.csv")

################################### excluding 14 ####################################

dfwide <- dfwide[!(dfwide$sub %in% 
                     c("3043", "3055", "3096", "4101", "3034", "3070", "3133", 
                       "5000", "5037", "5009", "5015", "5051", "5052", "5066")), ] 

## Multiple ANCOVAs: group difference for each ROI, tobacco = covariate
# create a list of names of variables of interest
p_ancova <- rep (0, 6)
rcorr(as.matrix(dfwide[2:7]), type="pearson") 

for (i in 2:7) {
  ancova <- Anova(lm(unlist(dfwide[i]) ~ group + tobacco,
                     contrasts=list(group=contr.sum), data=dfwide), type="III")
  p_ancova[i-1] <- ancova$"Pr(>F)"[2]
  cat(paste('\nRoi:', names(dfwide[i]), '\n'))
  print(ancova)
}

p_fdr <- p.adjust(p_ancova, method = c("fdr"), n = length(p_ancova))
p_fdr

## Multiple one way ANOVAs across all ROIs: Nothing survive FDR correction
# create a list of names of variables of interest
dependent_vars <- list(print(dfwide[2:7]))
p_anova <- rep (0, length(dependent_vars[[1]]))
# Test Group effect using ANOVA on percent signal change across all rois
for (i in 1:length(dfwide$sub)){
  aov <- summary(aov(dependent_vars[[1]][[i]] ~ dfwide$group, data=dfwide))
  p_anova[i] <- aov[[1]][["Pr(>F)"]]
  cat(paste('\nDependent var:', names(dependent_vars[[1]][i]), '\n'))
  print(aov)
}

p_fdr <- p.adjust(p_anova, method = c("fdr"), n = length(p_anova))
p_fdr
