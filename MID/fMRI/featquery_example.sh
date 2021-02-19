#!/bin/bash

source ~/sourcefiles/fsl_source.sh

##########################################################################################
########################## First run featquery for each subject ##########################
##########################################################################################

# syntax pasted below
# featquery <N_featdirs> <featdir1> ... <N_stats> <stats1> ... <outputrootname>  <mask> [-vox <X> <Y> <Z>]


subj=(3025 3026 3027 3029 3030 3031 3032 3034 3036 3037 3039 3040 3041 3042 3043)
mrqid=(61549914 61521914 61535914 61620714 61750814 61721914 61708114 61822714 61763914 63926214 62369814 64069714 64182514 64184914 64125314)

for n in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ; do
  for roi in lInsula lMPFC lVS rInsula rMPFC rVS ; do
    for run in 1 2 3 ; do
     
    featdir=/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/noICA/sub-${subj[$n]}_ses-${mrqid[$n]}_task-mid_run-${run}.feat/
    maskdir=/Shared/oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/AllGainvs0/5groupsF.gfeat/roi
    featquery 1 ${featdir} 4 stats/cope3 stats/cope6 stats/cope7 stats/cope8 ${roi} -p $maskdir/$roi.nii.gz

    done
  done
done

##########################################################################################
########## Then aggregate all subjects to create a whole-sample data file ################
##########################################################################################

subj=(3025 3026 3027 3029 3030 3031 3032 3034 3036 3037 3039 3040 3041 3042 3043)
mrqid=(61549914 61521914 61535914 61620714 61750814 61721914 61708114 61822714 61763914 63926214 62369814 64069714 64182514 64184914 64125314)

for n in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ; do
  for roi in lInsula lMPFC lVS rInsula rMPFC rVS ; do
    for run in 1 2 3 ; do

    querydir=/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/noICA/sub-${subj[$n]}_ses-${mrqid[$n]}_task-mid_run-$run.feat/$roi
    outdir=/Shared/oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/roi

    Gain5v0Hit=$(cat $querydir/report.txt | grep stats/cope3 | awk '{print $7}')
    Loss5v0Hit=$(cat $querydir/report.txt | grep stats/cope6 | awk '{print $7}')
    AllGainv0Hit=$(cat $querydir/report.txt | grep stats/cope7 | awk '{print $7}')
    AllLossv0Hit=$(cat $querydir/report.txt | grep stats/cope8 | awk '{print $7}')

    echo "${subj[$n]},$roi,$run,$Gain5v0Hit" >> $outdir/Gain5v0Hit_noICA.csv
    echo "${subj[$n]},$roi,$run,$Loss5v0Hit" >> $outdir/Loss5v0Hit_noICA.csv
    echo "${subj[$n]},$roi,$run,$AllGainv0Hit" >> $outdir/AllGainv0Hit_noICA.csv
    echo "${subj[$n]},$roi,$run,$AllLossv0Hit" >> $outdir/AllLossv0Hit_noICA.csv

    done
  done
done
