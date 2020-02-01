rm(list=ls())
data.dir <- ("~/Documents/oleary/MIDnSST/Drug and Alcohol Dependence/SST/")
setwd(data.dir)

##############################################################################
############################### CLEAN THE DATA ###############################
##############################################################################

# read csv file
df = read.csv2("SST-Behav-Data-ses1.csv", sep = "\t", header = TRUE)
# turn all values to character (if not do this, column = factor)
# can't change factor --> numeric in 1 step
df_char <- sapply(df, as.character)
# create blank dataframe with dimension of: df
blank <- matrix(0L, nrow = dim(df)[1], ncol = dim(df)[2])
df_num <- as.data.frame(blank)
# copy df's column names to blank dataframe df_num
names = c(colnames(df))
colnames(df_num) = names
# turn all column to numeric 
for (i in 1:442) {
  for (j in 1:28) {
    df_num[i,j] <- as.numeric(df_char[i,j])
  }
}
# move subID and run to the 1st and 2nd column
# then sort by ID, then by run
library(dplyr)
df_num_fin <- df_num %>%
  select(SubID, Run, everything()) %>%
  arrange(SubID, Run)
# change all negative value to NA
for (i in 1:442) {
  for (j in 1:28) {
    if (df_num_fin[i,j] < 0){
      is.na(df_num_fin[i,j]) <- df_num_fin[i,j]
    }
  }
}
# Re-calculate meanSSRT excluding NA 
for (i in 1:442) {
  x <- c(df_num_fin$SSRT1[i], df_num_fin$SSRT2[i], df_num_fin$SSRT3[i], df_num_fin$SSRT4[i])
  df_num_fin$meanSSRT[i] = mean(x, na.rm=TRUE)
}
# save this
write.csv(df_num_fin, file = "cleanedBehav-2Runs-sep.csv")

#################SEPARATE 2 RUNS, THEN AVERAGE ACROSS RUNS#################
# run 1 = concatenate even rows 
run1 = df_num_fin[ c(TRUE,FALSE), ]
run1$Run <- NULL
# run 2 = concatenate even rows
run2 = df_num_fin[ !c(TRUE,FALSE), ]
run2$Run <- NULL

# Subject that might be weird
# 3126 SSRT < 50 run 2
# 3081 SSRT < 50 run 1
# 3110 SSRT < 50 run 2
# 3108 SSRT > 50 but have negative SSRT2

# make blank dataframe of the same dimension as run1, named it: behav
blank <- matrix(0L, nrow = dim(run1)[1], ncol = dim(run1)[2])
behav <- as.data.frame(blank)
# copy run1's column names to blank dataframe: behav
names = c(colnames(run1))
colnames(behav) = names
# make a dataframe called behav = average of run1 and run2
for (i in 1:length(run1$SubID)) {
  for (j in 1:27) {
    behav[i,j] <- (run1[i,j] + run2[i,j]) / 2
  }
}
####include grouping variable
group <- read.csv("group.csv",header = FALSE)
group$group <- factor(group$V1, levels=c(1,2,3,4,5), labels=c("Control", 
                                                                 "sBinge",
                                                                 "eBinge",
                                                                 "MJ+sBinge",
                                                                 "MJ+eBinge"))

behav$group <- group[,"group"]
behav$group_num <- group[,"V1"]
behav$tobacco <- group[,"V2"]

behav <- behav %>%
  select(SubID, group, group_num, everything()) %>%
  arrange(SubID)

# save this
write.csv(behav, file = "cleanedBehav-2Runs-comb.csv")

behav_excon <- behav %>%
  filter(group_num != 1)

# exclusion criteria: Congdon et al 2012 frontiers
#(1) Percent inhibition on stop trials less than 25% or greater than 75%: 
#    NO ONE WAS EXCLUDED
#(2) Percent Go-Response (CorGo) less than than 60%: NO ONE WAS EXCLUDED
#(3) Percent Go-Errors (IncGo) greater than 10%: s5038 12% (mj+sbinge)
#(4) SSRT estimate that is negative or less than 50 ms: NO ONE WAS EXCLUDED


###################################################################################   
##################### ONE-WAY ANCOVA SSRT tobacco = covariate #####################
###################################################################################

library("psych")
describeBy(behav$meanSSRT, behav$group)
hist(behav$meanSSRT)
behav$meanSSRT_log <- log10(behav$meanSSRT)
hist(behav$meanSSRT_log)
describeBy(behav$meanSSRT_log, behav$group)

# ANCOVA: effect of group on ssrt, controlling for tobacco
library(car) # for Anova()
ssrt_lm <- lm(meanSSRT ~ group + tobacco,
            contrasts=list(group=contr.sum), data=behav)
Anova(ssrt_lm, type="III")
library("lsr")
etaSquared(ssrt_lm, type = 3)

ssrtlog_lm <- lm(meanSSRT_log ~ group + tobacco,
              contrasts=list(group=contr.sum), data=behav)
Anova(ssrtlog_lm, type="III")
library("lsr")
etaSquared(ssrtlog_lm, type = 3)

# Homogeneity of Covariate effects can be tested via interaction term. 
# A significant interaction implies that the effects of treatements are different 
# at different covariate levels
ssrt_lmint <- lm(meanSSRT ~ group*tobacco,
                 contrasts=list(group=contr.sum), data=behav)
Anova(ssrt_lmint, type="III")

# Normality 
shapiro.test(x = ssrt_lm[["residuals"]] )
shapiro.test(x = ssrtlog_lm[["residuals"]] )

# Equal variances
leveneTest(meanSSRT ~ group, data = behav)

# post hoc pairwise comparison
library(emmeans)
emm_ssrt = emmeans(ssrt_lm, specs = pairwise ~ group + tobacco)
emm_options(opt.digits = FALSE) # show results with more decimal places
summary(emm_ssrt)
test(emm_ssrt)
confint(emm_ssrt)

plot(emm_ssrt) + theme_bw() + 
  labs(x = "SSRT", 
       y = "Group")

###################################################################################   
##################### ONE-WAY ANCOVA STOP ACC tobacco = covariate #####################
###################################################################################

library("psych")
describeBy(behav$Accuracy_Stop, behav$group)
hist(behav$Accuracy_Stop)
behav$Accuracy_Stop_log <- log10(behav$Accuracy_Stop) # worse
hist(behav$Accuracy_Stop_log) # worse

# ANCOVA: effect of group on Accuracy_Stop, controlling for tobacco
library(car) # for Anova()
Accuracy_Stop_lm <- lm(Accuracy_Stop ~ group + tobacco,
                       contrasts=list(group=contr.sum), data=behav)
Anova(Accuracy_Stop_lm, type="III")
library("lsr")
etaSquared(Accuracy_Stop_lm, type = 3)

Accuracy_Stoplog_lm <- lm(Accuracy_Stop_log ~ group + tobacco,
                          contrasts=list(group=contr.sum), data=behav)
Anova(Accuracy_Stoplog_lm, type="III")
library("lsr")
etaSquared(Accuracy_Stoplog_lm, type = 3)

# Homogeneity of Covariate effects can be tested via interaction term. 
# A significant interaction implies that the effects of treatements are different 
# at different covariate levels
Accuracy_Stop_lmint <- lm(Accuracy_Stop ~ group*tobacco,
                          contrasts=list(group=contr.sum), data=behav)
Anova(Accuracy_Stop_lmint, type="III")

# Normality 
shapiro.test(x = Accuracy_Stop_lm[["residuals"]] )
shapiro.test(x = Accuracy_Stoplog_lm[["residuals"]] ) # worse

# Equal variances
leveneTest(Accuracy_Stop ~ group, data = behav)

# post hoc pairwise comparison
library(emmeans)
emm_Accuracy_Stop = emmeans(Accuracy_Stop_lm, specs = pairwise ~ group + tobacco)
emm_options(opt.digits = FALSE) # show results with more decimal places
summary(emm_Accuracy_Stop)
confint(emm_Accuracy_Stop)

plot(emm_Accuracy_Stop) + theme_bw() + 
  labs(x = "Accuracy_Stop", 
       y = "Group")

###################################################################################   
##################### ONE-WAY ANCOVA GoRT tobacco = covariate #####################
###################################################################################

library("psych")
describeBy(behav$meanGoRT, behav$group)
hist(behav$meanGoRT)
behav$meanGoRT_log <- log10(behav$meanGoRT)
hist(behav$meanGoRT_log)

# ANCOVA: effect of group on ssrt, controlling for tobacco
library(car) # for Anova()
gort_lm <- lm(meanGoRT ~ group + tobacco,
              contrasts=list(group=contr.sum), data=behav)
Anova(gort_lm, type="III")
library("lsr")
etaSquared(gort_lm, type = 3)

gortlog_lm <- lm(meanGoRT_log ~ group + tobacco,
                 contrasts=list(group=contr.sum), data=behav)
Anova(gortlog_lm, type="III")
library("lsr")
etaSquared(gortlog_lm, type = 3)

# Homogeneity of Covariate effects can be tested via interaction term. 
# A significant interaction implies that the effects of treatements are different 
# at different covariate levels
gort_lmint <- lm(meanGoRT ~ group*tobacco,
                 contrasts=list(group=contr.sum), data=behav)
Anova(gort_lmint, type="III")

# Normality 
shapiro.test(x = gort_lm[["residuals"]] )
shapiro.test(x = gortlog_lm[["residuals"]] )

# Equal variances
leveneTest(meanGoRT ~ group, data = behav)

# post hoc pairwise comparison
library(emmeans)
emm_gort = emmeans(gort_lm, specs = pairwise ~ group + tobacco)
emm_options(opt.digits = FALSE) # show results with more decimal places
summary(emm_gort)
confint(emm_gort)

plot(emm_gort) + theme_bw() + 
  labs(x = "GoRT", 
       y = "Group")

###################################################################################   
##################### ONE-WAY ANCOVA GO ACC tobacco = covariate #####################
###################################################################################

library("psych")
describeBy(behav$Accuracy_Go, behav$group)
hist(behav$Accuracy_Go)
behav$Accuracy_Go_log <- log10(behav$Accuracy_Go) # tried many other transformation, didn't work
hist(behav$Accuracy_Go_log) 


# ANCOVA: effect of group on Accuracy_Go, controlling for tobacco
library(car) # for Anova()
Accuracy_Go_lm <- lm(Accuracy_Go ~ group + tobacco,
                     contrasts=list(group=contr.sum), data=behav)
Anova(Accuracy_Go_lm, type="III")
library("lsr")
etaSquared(Accuracy_Go_lm, type = 3)

Accuracy_Golog_lm <- lm(Accuracy_Go_log ~ group + tobacco,
                        contrasts=list(group=contr.sum), data=behav)
Anova(Accuracy_Golog_lm, type="III")
library("lsr")
etaSquared(Accuracy_Golog_lm, type = 3)

# Homogeneity of Covariate effects can be tested via interaction term. 
# A significant interaction implies that the effects of treatements are different 
# at different covariate levels
Accuracy_Go_lmint <- lm(Accuracy_Go ~ group*tobacco,
                        contrasts=list(group=contr.sum), data=behav)
Anova(Accuracy_Go_lmint, type="III")

# Normality 
shapiro.test(x = Accuracy_Go_lm[["residuals"]] )
shapiro.test(x = Accuracy_Golog_lm[["residuals"]] ) 

# Equal variances
leveneTest(Accuracy_Go ~ group, data = behav)

# post hoc pairwise comparison
library(emmeans)
emm_Accuracy_Go = emmeans(Accuracy_Go_lm, specs = pairwise ~ group + tobacco)
emm_options(opt.digits = FALSE) # show results with more decimal places
summary(emm_Accuracy_Go)
confint(emm_Accuracy_Go)

plot(emm_Accuracy_Go) + theme_bw() + 
  labs(x = "Accuracy_Go", 
       y = "Group")

###################################################################################   
##################### excluding 14 + 1 #####################
###################################################################################

behav <- behav[!(behav$SubID %in% c("5038", "3043", "3055", "3096", "4101", "3034", "3070", "3133", 
                           "5000", "5037", "5009", "5015", "5051", "5052", "5066")), ]         
