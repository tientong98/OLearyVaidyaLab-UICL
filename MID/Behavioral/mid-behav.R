rm(list=ls())
data.dir <- ("~/Documents/oleary/MIDnSST/Drug and Alcohol Dependence/MID/")
setwd(data.dir)

###################################################################################
################################ BEHAVIORAL DATA ##################################
###################################################################################

mid_behav = read.csv("MIDBehavData.csv", header = T)
mid_behav$group <- factor(mid_behav$DrugGroup_5cat, levels=c(1,2,3,4,5), 
                          labels=c("Control", "sBinge", "eBinge", "MJ+sBinge",
                                   "MJ+eBinge"))

mid_behav$Gain_RT <- rowMeans ((mid_behav[c("Gain0_RT_Sess1", "Gain.2_RT_Sess1", 
                                            "Gain1_RT_Sess1", "Gain5_RT_Sess1")]), 
                               na.rm = TRUE)
mid_behav$Gain_HR <- (rowMeans ((mid_behav[c("Gain0_HR_Sess1", "Gain.2_HR_Sess1", 
                                            "Gain1_HR_Sess1", "Gain5_HR_Sess1")]), 
                               na.rm = TRUE)) * 100
mid_behav$Loss_RT <- rowMeans ((mid_behav[c("Loss0_RT_Sess1", "Loss.2_RT_Sess1", 
                                            "Loss1_RT_Sess1", "Loss5_RT_Sess1")]), 
                               na.rm = TRUE)
mid_behav$Loss_HR <- (rowMeans ((mid_behav[c("Loss0_HR_Sess1", "Loss.2_HR_Sess1", 
                                            "Loss1_HR_Sess1", "Loss5_HR_Sess1")]), 
                               na.rm = TRUE)) * 100

write.csv(mid_behav, file = "mid_behav.csv")

describeBy(mid_behav$Gain_RT, mid_behav$group)
describeBy(mid_behav$Loss_RT, mid_behav$group)
describeBy(mid_behav$Gain_HR, mid_behav$group)
describeBy(mid_behav$Loss_HR, mid_behav$group)


for (i in 2:18) {
  print(names(mid_behav[i]))
  print(shapiro.test(unlist(mid_behav[i])))
}

library(tidyr)
library(ggplot2)
dv <- mid_behav[2:18]
dv %>% gather() %>% head()
ggplot(gather(dv), aes(value)) + 
  geom_histogram(bins = 10) + 
  facet_wrap(~key, scales = 'free_x')

http://www.alexanderdemos.org/ANOVA13.html
https://ademos.people.uic.edu/Chapter21.html#1210_afex_defaults
https://www.r-bloggers.com/anova-in-r-afex-may-be-the-solution-you-are-looking-for
https://cran.r-project.org/web/packages/afex/vignettes/afex_mixed_example.html