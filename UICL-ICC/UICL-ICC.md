# UICL-ICC
ICC of several self-reported and behavioral variables in the UICL study

UICL\_ICC
================

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
spss <- foreign::read.spss("~/Documents/oleary/Complete_Dataset_fix_missing_values_fixed_MJ_TB_Binge_FU_addAge.sav", to.data.frame = T, stringsAsFactors = F)
```

age, gender, binge status, NEO, UPPS, BIS, SSS, and all the behavioral
tasks (DDT, BART, cog task)

``` r
demo <- c("Subject_ID", "age_time1", "age_time2", "Sex", "BingeGroup_5cat")
neo <- grep(paste(c("V1_NEO", "V2_NEO"),collapse="|"), names(spss), value=TRUE)
upps <- grep(paste(c("V1_UPPSP", "V2_UPPSP"),collapse="|"), names(spss), value=TRUE)
bis <- grep(paste(c("V1_BIS", "V2_BIS"),collapse="|"), names(spss), value=TRUE)
sss <- grep(paste(c("V1_SSS", "V2_SSS"),collapse="|"), names(spss), value=TRUE)

behav <- grep(paste(c("DDT", "BART"),collapse="|"), names(spss), value=TRUE)

neuropsy <- grep(paste(c("StroopEffect", "DigitSpan_Correct_Forward", "DigitSpan_Correct_Reverse", "DigitSpan_Total_Correct", "LetterFluency_Total_In_Set", "Elapsed_Time_Trails_BminusA"),collapse="|"), names(spss), value=TRUE)[-c(9,10,16,18)]
```

``` r
# 122 subjects came back, 3 didn't have imaging data (3084, 3102, 3198) --> 119 with rest data
icc.short <- spss[c(demo, neo, upps, bis, sss, behav, neuropsy)] %>% filter(!is.na(age_time2))


######################### some V1 variables need to be renamed #########################
oldname <- c("BART_PumpsAvgAdj",                                     
 "DDT_K_Values",                                         
 "StroopEffect_ColorSquare",                             
 "StroopEffect_Non_ColorWord",                           
 "DigitSpan_Correct_Forward",                            
 "DigitSpan_Correct_Reverse",                            
 "DigitSpan_Total_Correct",                              
 "LetterFluency_Total_In_Set")
newname <- unname(sapply(oldname, function(x) paste0("V1_", x)))
colnames(icc.short)[colnames(icc.short) %in% oldname] <- newname


################################## Time 1 Data ##################################

icc.short.t1 <- icc.short[c("Subject_ID", "age_time1", "Sex", "BingeGroup_5cat",
            grep("V1_", names(icc.short), value = T))] %>%
  rename(id=Subject_ID, age=age_time1, group=BingeGroup_5cat)
names(icc.short.t1) <- sub("V1_", "", names(icc.short.t1))


################################## Time 2 Data ##################################

icc.short.t2 <- icc.short[c("Subject_ID", "age_time2", "Sex", "BingeGroup_5cat",
            grep("V2_", names(icc.short), value = T))] %>%
  rename(id=Subject_ID, age=age_time2, group=BingeGroup_5cat)
names(icc.short.t2) <- sub("V2_", "", names(icc.short.t2))
# make sure order of the columns match between T1 and T2 data
icc.short.t2 <- icc.short.t2[names(icc.short.t2)[order(match(names(icc.short.t2), names(icc.short.t1)))]]
#test
names(icc.short.t1)==names(icc.short.t2)
```

    ##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
    ## [16] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
    ## [31] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE

``` r
write.table(icc.short, row.names = F, col.names = T, sep = "\t", quote = F, 
            file = "~/Documents/oleary/UICL_ICC.txt")
```

### ICC interpretation

below 0.50: poor  
between 0.50 and 0.75: moderate  
between 0.75 and 0.90: good  
above 0.90: excellent

``` r
icc_func <- function(x, y){
  irr::icc(cbind(x, y), model = "oneway", type = "consistency", unit = "single", r0 = 0, 
           conf.level = 0.95)$value
}


for (i in 5:41) {
  print(paste0("ICC of ", names(icc.short.t1)[i],
              ": ", icc_func(icc.short.t1[i], icc.short.t2[i])))
}
```

    ## [1] "ICC of NEO_N: 0.688648991065419"
    ## [1] "ICC of NEO_E: 0.718785650035201"
    ## [1] "ICC of NEO_O: 0.764126484786028"
    ## [1] "ICC of NEO_A: 0.739712336505454"
    ## [1] "ICC of NEO_C: 0.688319079686264"
    ## [1] "ICC of UPPSP_Negative_Urgency: 0.636194029850746"
    ## [1] "ICC of UPPSP_Lack_of_Premeditation: 0.40675178222571"
    ## [1] "ICC of UPPSP_Lack_of_Perseverance: 0.698994853968334"
    ## [1] "ICC of UPPSP_Sensation_Seeking: 0.801823706269528"
    ## [1] "ICC of UPPSP_Positive_Urgency: 0.519325845235092"
    ## [1] "ICC of BIS_Attention: 0.585405672197122"
    ## [1] "ICC of BIS_Cognitive_instability: 0.589341484484019"
    ## [1] "ICC of BIS_Motor: 0.482032218091698"
    ## [1] "ICC of BIS_Perseverance: 0.365977511788176"
    ## [1] "ICC of BIS_Self_control: 0.52875894788017"
    ## [1] "ICC of BIS_Cognitive_complexity: 0.599662281010343"
    ## [1] "ICC of BIS_Motor_Combined: 0.483089610250562"
    ## [1] "ICC of BIS_Attentional_Combined: 0.638238254320019"
    ## [1] "ICC of BIS_Nonplanning_Combined: 0.612064435736912"
    ## [1] "ICC of SSS_Boredom_Susceptibility: 0.51390103164889"
    ## [1] "ICC of SSS_Disinhibition: 0.540655676977218"
    ## [1] "ICC of SSS_Experience_Seeking: 0.53761761636074"
    ## [1] "ICC of SSS_Thrill_Adventure_Seeking: 0.800174022622941"
    ## [1] "ICC of SSS_Overall_Score: 0.721461049974023"
    ## [1] "ICC of SSS_Disinhibition_without_substance_questions: 0.425410045552265"
    ## [1] "ICC of SSS_Experience_Seeking_without_substance_questions: 0.497419689920767"
    ## [1] "ICC of SSS_Overall_Score_no_substances: 0.693283503590329"
    ## [1] "ICC of BART_PumpsAvgAdj: 0.284866288236741"
    ## [1] "ICC of DDT_K_Values: 0.0596550475332446"
    ## [1] "ICC of DDT_K_Values_log: 0.614912950824225"
    ## [1] "ICC of StroopEffect_ColorSquare: 0.518937808549587"
    ## [1] "ICC of StroopEffect_Non_ColorWord: 0.461857716287378"
    ## [1] "ICC of DigitSpan_Correct_Forward: 0.669978537150023"
    ## [1] "ICC of DigitSpan_Correct_Reverse: 0.594458438287154"
    ## [1] "ICC of DigitSpan_Total_Correct: 0.727980875191967"
    ## [1] "ICC of LetterFluency_Total_In_Set: 0.719708140212309"
    ## [1] "ICC of Elapsed_Time_Trails_BminusA: 0.459173903648544"

No difference in task versus self-report ICC values
