#!/bin/bash

source ~/sourcefiles/afni_source.sh
source ~/sourcefiles/fsl_source.sh

3dUndump -prefix greene300-5.nii.gz -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
-orient LPI -srad 5 -xyz afniinput5.txt

3dUndump -prefix greene300-4.nii.gz -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
-orient LPI -srad 4 -xyz afniinput4.txt

fslmaths greene300-5.nii.gz -add greene300-4.nii.gz greene300.nii.gz


3dUndump -prefix greene300-5oldindex.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 5 -xyz afniinput5oldindex.txt

3dUndump -prefix greene300-4oldindex.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz afniinput4oldindex.txt

fslmaths greene300-5oldindex.nii.gz -add greene300-4oldindex.nii.gz greene300oldindex.nii.gz

###### create seed

echo "-20.3 -2.27 -22.21" | 3dUndump -prefix LAmyg_mask.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz -

echo "19.51 -1.85 -23.11" | 3dUndump -prefix RAmyg_mask.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz -

echo "-12.49 17.05 -4.49" | 3dUndump -prefix LNAcc_mask.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz -

echo "12.66 17.32 -5.06" | 3dUndump -prefix RNAcc_mask.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz -

