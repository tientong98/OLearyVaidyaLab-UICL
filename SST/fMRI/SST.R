rm(list=ls())
data.dir <- ("~/Documents/oleary/MIDnSST/Drug and Alcohol Dependence/SST/")
setwd(data.dir)

df = read.csv("CorStop-CorGo_noICA.csv", header = FALSE)
names(df) <- c("sub","roi","run","percent")

run1 = df[ c(TRUE,FALSE), ]
run2 = df[ !c(TRUE,FALSE), ]

mean_across_runs <- rep (0, length(run1$sub))

for (i in 1:length(run1$sub)) {
  mean_across_runs[i] <- (run1$percent[i] + run2$percent[i])/2
}

dflong = data.frame(run1$sub, run1$roi,mean_across_runs)
names(dflong) <- c("sub", "roi", "percent_signal_change")

library(dplyr)
library(tidyr)
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
write.csv(dfwide, file = "CorStop-CorGo_noICA_wide.csv")

################################### excluding 14 + 1 ####################################

dfwide <- dfwide[!(dfwide$sub %in% c("5038", "3043", "3055", "3096", "4101", "3034", "3070", "3133", 
                                    "5000", "5037", "5009", "5015", "5051", "5052", "5066")), ] 

## Multiple ANCOVAs: group difference for each ROI, tobacco = covariate
# create a list of names of variables of interest
p_ancova <- rep (0, 10)
rcorr(as.matrix(dfwide[2:7]), type="pearson") 

for (i in 2:11) {
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
dependent_vars <- list(print(dfwide[2:11]))
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


dfwide <- read.csv(file = "CorStop-CorGo_noICA_wide.csv")

####################################################################################
####################################################################################
####################################################################################

dfwide <- read.csv("~/Documents/oleary/MIDnSST/Drug and Alcohol Dependence/SST/CorStop-CorGo_noICA_wide.csv")
dfwide$group <- factor(dfwide$group_num, levels=c(1,2,3,4,5), labels=c("Control", 
                                                                       "sBinge",
                                                                       "eBinge",
                                                                       "MJ+sBinge",
                                                                       "MJ+eBinge"))

ggplot(dfwide, aes(group,lIFG)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  ggtitle("Left Inferior Frontal Gyrus Correct Stop vs. Correct Go") +
  ylab("Percent Signal Change") +
  theme(plot.title = element_text(size=16, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank()
  ) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lIFG), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=14,face="bold"),
        axis.title.y = element_text(size=15,face="bold"),
        axis.text.y = element_text(size=13,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=5)

ggplot(dfwide, aes(group,rIFG)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  ggtitle("Right Inferior Frontal Gyrus Correct Stop vs. Correct Go") +
  ylab("Percent Signal Change") +
  theme(plot.title = element_text(size=16, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank()
  ) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,rIFG), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=14,face="bold"),
        axis.title.y = element_text(size=15,face="bold"),
        axis.text.y = element_text(size=13,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=5)

######################## lIFG ##########################
hist(dfwide$lIFG)
shapiro.test(x = dfwide$lIFG)
boxplot(dfwide$lIFG, data=dfwide)

lIFG <- aov(dfwide$lIFG ~ dfwide$group,data=dfwide)
summary(lIFG)

leveneTest(lIFG ~ group, data = dfwide)
shapiro.test(x = lIFG[["residuals"]] )

ggplot(dfwide, aes(group,lIFG)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lIFG), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(lIFG ~ group, data = dfwide)

######################## rIFG ##########################
hist(dfwide$rIFG)
shapiro.test(x = dfwide$rIFG)
boxplot(dfwide$rIFG, data=dfwide)

rIFG <- aov(dfwide$rIFG ~ dfwide$group,data=dfwide)
summary(rIFG)

leveneTest(rIFG ~ group, data = dfwide)
shapiro.test(x = rIFG[["residuals"]] )

ggplot(dfwide, aes(group,rIFG)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,rIFG), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(rIFG ~ group, data = dfwide)

######################## lInsula ##########################
hist(dfwide$lInsula)
shapiro.test(x = dfwide$lInsula)
boxplot(dfwide$lInsula, data=dfwide)

lInsula <- aov(dfwide$lInsula ~ dfwide$group,data=dfwide)
summary(lInsula)

leveneTest(lInsula ~ group, data = dfwide)
shapiro.test(x = lInsula[["residuals"]] )

ggplot(dfwide, aes(group,lInsula)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lInsula), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(lInsula ~ group, data = dfwide)

######################## rInsula ##########################
hist(dfwide$rInsula)
shapiro.test(x = dfwide$rInsula)
boxplot(dfwide$rInsula, data=dfwide)

rInsula <- aov(dfwide$rInsula ~ dfwide$group,data=dfwide)
summary(rInsula)

leveneTest(rInsula ~ group, data = dfwide)
shapiro.test(x = rInsula[["residuals"]] )

ggplot(dfwide, aes(group,rInsula)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,rInsula), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(rInsula ~ group, data = dfwide)

######################## lPallidum ##########################
hist(dfwide$lPallidum)
shapiro.test(x = dfwide$lPallidum)
boxplot(dfwide$lPallidum, data=dfwide)

lPallidum <- aov(dfwide$lPallidum ~ dfwide$group,data=dfwide)
summary(lPallidum)

leveneTest(lPallidum ~ group, data = dfwide)
shapiro.test(x = lPallidum[["residuals"]] )

ggplot(dfwide, aes(group,lPallidum)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lPallidum), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(lPallidum ~ group, data = dfwide)

######################## rPallidum ##########################
hist(dfwide$rPallidum)
shapiro.test(x = dfwide$rPallidum)
boxplot(dfwide$rPallidum, data=dfwide)

rPallidum <- aov(dfwide$rPallidum ~ dfwide$group,data=dfwide)
summary(rPallidum)

leveneTest(rPallidum ~ group, data = dfwide)
shapiro.test(x = rPallidum[["residuals"]] )

ggplot(dfwide, aes(group,rPallidum)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,rPallidum), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(rPallidum ~ group, data = dfwide)

######################## lSMA ##########################
hist(dfwide$lSMA)
shapiro.test(x = dfwide$lSMA)
boxplot(dfwide$lSMA, data=dfwide)

lSMA <- aov(dfwide$lSMA ~ dfwide$group,data=dfwide)
summary(lSMA)

leveneTest(lSMA ~ group, data = dfwide)
shapiro.test(x = lSMA[["residuals"]] )

ggplot(dfwide, aes(group,lSMA)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lSMA), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(lSMA ~ group, data = dfwide)

######################## rSMA ##########################
hist(dfwide$rSMA)
shapiro.test(x = dfwide$rSMA)
boxplot(dfwide$rSMA, data=dfwide)

rSMA <- aov(dfwide$rSMA ~ dfwide$group,data=dfwide)
summary(rSMA)

leveneTest(rSMA ~ group, data = dfwide)
shapiro.test(x = rSMA[["residuals"]] )

ggplot(dfwide, aes(group,rSMA)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,rSMA), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(rSMA ~ group, data = dfwide)

######################## lSuppra ##########################
hist(dfwide$lSuppra)
shapiro.test(x = dfwide$lSuppra)
boxplot(dfwide$lSuppra, data=dfwide)

lSuppra <- aov(dfwide$lSuppra ~ dfwide$group,data=dfwide)
summary(lSuppra)

leveneTest(lSuppra ~ group, data = dfwide)
shapiro.test(x = lSuppra[["residuals"]] )

ggplot(dfwide, aes(group,lSuppra)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,lSuppra), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(lSuppra ~ group, data = dfwide)

######################## rSuppra ##########################
hist(dfwide$rSuppra)
shapiro.test(x = dfwide$rSuppra)
boxplot(dfwide$rSuppra, data=dfwide)

rSuppra <- aov(dfwide$rSuppra ~ dfwide$group,data=dfwide)
summary(rSuppra)

leveneTest(rSuppra ~ group, data = dfwide)
shapiro.test(x = rSuppra[["residuals"]] )

ggplot(dfwide, aes(group,rSuppra)) +
  theme_bw() +
  geom_boxplot(aes(col=group), lwd=1, position=position_dodge(3), outlier.shape=NA) + 
  #ggtitle("Right Ventral Striatum") +
  theme(plot.title = element_text(size=14, face="bold", hjust = 0.5)) +
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(legend.position = "none") +
  geom_jitter(aes(group,rSuppra), size=2, shape=16, 
              position=position_jitter(width = 0.1, height = 0)) +
  theme(axis.text.x = element_text(size=12,face="bold"),
        axis.text.y = element_text(size=12,face="plain")) +
  stat_summary(fun.y=mean, colour="red", geom="point", size=4)

kruskal.test(rSuppra ~ group, data = dfwide)

##################################################################
##################################################################
##################################################################
rm(list=ls())

df = read.csv("CorStop-IncStop_noICA.csv", header = FALSE)
names(df) <- c("sub","roi","run","percent")

run1 = df[ c(TRUE,FALSE), ]
run2 = df[ !c(TRUE,FALSE), ]

mean_across_runs <- rep (0, length(run1$sub))

for (i in 1:length(run1$sub)) {
  mean_across_runs[i] <- (run1$percent[i] + run2$percent[i])/2
}

dflong = data.frame(run1$sub, run1$roi,mean_across_runs)
names(dflong) <- c("sub", "roi", "percent_signal_change")

library(dplyr)
library(tidyr)
dfwide <- spread(dflong, roi, percent_signal_change)

group <- read.csv("group.csv",header = FALSE)
group$groupfac <- factor(group$V1, levels=c(1,2,3,4,5), labels=c("Control", 
                                                                 "sBinge",
                                                                 "eBinge",
                                                                 "MJ+sBinge",
                                                                 "MJ+eBinge"))

dfwide$group <- group[,"groupfac"]
dfwide$group_num <- group[,"V1"]
write.csv(dfwide, file = "CorStop-IncStop_noICA_wide.csv")

dfwide <- read.csv(file = "CorStop-IncStop_noICA_wide.csv")

## Multiple one way ANOVAs across all ROIs: Nothing survive FDR correction
# create a list of names of variables of interest
dependent_vars <- list(print(dfwide[3:12]))
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

