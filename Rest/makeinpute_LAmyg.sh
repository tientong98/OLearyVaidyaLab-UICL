#/bin/bash
source ~/sourcefiles/fsl_source.sh

output=/oleary/functional/UICL/BIDS/derivatives/group_analysis/rest/input_LAmyg

fslmerge \
   -t $output \
   $(cut -f2 /oleary/functional/UICL/BIDS/code/randomise/rest/LAmyg.txt | tr '\n' ' ')


