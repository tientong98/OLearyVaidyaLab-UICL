#/bin/bash
source ~/sourcefiles/fsl_source.sh

mask=/Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.8_multicore/data/standard/MNI152_T1_2mm_brain_mask.nii.gz
outdir=/oleary/functional/UICL/BIDS/derivatives/group_analysis/rest

randomise \
-i $outdir/input_ROI.nii.gz \
-o $outdir/ROI_CONTRAST \
-d CONTRAST.mat \
-t CONTRAST.con \
-m  $mask \
-n 5000 \
-T
