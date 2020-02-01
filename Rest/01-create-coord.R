rm(list=ls())
library(dplyr)
library(tidyverse)

# read coordiates
coord <- read.table(file = "orig/ROIs_300inVol_MNI_allInfo.txt", sep = "")
colnames(coord) <- as.character(unlist(coord[1,]))
coord = coord[-1, ] 
rownames(coord) <- NULL
colnames(coord)[colnames(coord)=="radius(mm)"] <- "radius"
coord["oldindex"] <- rownames(coord)
# sort by network -- so all networks are now grouped together
coord <- coord %>% arrange(netName)
coord["newindex"] <- rownames(coord)

# change back to old order to incoporate other information
coord <- coord %>% arrange(oldindex)
# get regional information
region <- read.table(file = "orig/ROIs_anatomicalLabels.txt", sep = "", stringsAsFactors = F)
region <- region[-1, ]
region <- as.data.frame(region)
colnames(region)[colnames(region)=="region"] <- "reg.value"
region["oldindex"] <- rownames(region)
region["region"] <- ifelse(region$reg.value == 0, "MidCortex", 
                    ifelse(region$reg.value == 1, "LeftCortex",
                    ifelse(region$reg.value == 2, "RightCortex",
                    ifelse(region$reg.value == 3, "Hippocampus",
                    ifelse(region$reg.value == 4, "Amygdala",
                    ifelse(region$reg.value == 5, "BasalGanglia",
                    ifelse(region$reg.value == 6, "Thalamus",
                    ifelse(region$reg.value == 7, "Cerebellum", NA))))))))

# merge coordination and region, then sort by new index so that all nodes of the same network are clustered
network <- merge(region, coord, by="oldindex")
network$oldindex <- as.numeric(network$oldindex)
network$newindex <- as.numeric(network$newindex)
network <- network %>% arrange(newindex)

# select xyz and new index
afniinput5 <- network %>% filter(radius == 5) %>% select(c(4:6,11))
afniinput4 <- network %>% filter(radius == 4) %>% select(c(4:6,11))



write.table(afniinput5, file = "afniinput5.txt", col.names = F, row.names = F, sep = " ", quote = F)
write.table(afniinput4, file = "afniinput4.txt", col.names = F, row.names = F, sep = " ", quote = F)
write.table(network, file = "network.txt", col.names = T, row.names = F, sep = " ", quote = F)


######################################################### USING OLD INDEX TO CREATE THEIR FIGURE ON OUR DATA
#########################################################

networkoldindex <- network %>% arrange(oldindex)

# select xyz and new index
afniinput5oldindex  <- networkoldindex %>% filter(radius == 5) %>% select(c(4:6,1))
afniinput4oldindex  <- networkoldindex %>% filter(radius == 4) %>% select(c(4:6,1))


write.table(afniinput5oldindex, file = "afniinput5oldindex.txt", col.names = F, row.names = F, sep = " ", quote = F)
write.table(afniinput4oldindex, file = "afniinput4oldindex.txt", col.names = F, row.names = F, sep = " ", quote = F)
write.table(networkoldindex, file = "networkoldindex.txt", col.names = T, row.names = F, sep = " ", quote = F)


