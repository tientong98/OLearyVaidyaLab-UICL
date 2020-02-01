
# BIDSification

Run heudiconv: details in **-Heudiconv.ipynb**

Then, check to see if heudiconv failed for any subject using **check_missing_outputs.ipynb**


# Exclude dummy TRs

Once you get the data in BIDS format, you need to get rid of the dummy TRs at the beginning of the run BEFORE running FMRIPREP

Run **/oleary/functional/UICL/BIDS/code/exclude_first_TRs.sh**. For example, for the SST task in UICL, we will truncate the first 5 TRs for each run. For the MID task in UICL, we will exclude the first 6 TRs

Remember to make a note of this in a task json file (task-stopsignal_bold.json) in the following fields:

"NumberOfVolumesDiscardedByUser": 6,
"NumberOfVolumesDiscardedByScanner": 2,


# Run MRIQC


pull the lastest version of mriqc


```bash
singularity pull docker://poldracklab/mriqc:latest

singularity run -H /Users/tientong/.singularity \
-B /Shared/oleary/:/mnt \
/Users/tientong/.singularity/docker/mriqc-latest.simg \
/mnt/functional/UICL/BIDS \
/mnt/functional/UICL/mriqc_result/stopsignal \
participant --participant-label $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/subjectstest.txt | tr '\n' ' ') \
-m bold --task-id stopsignal --no-sub \
-w /mnt/functional/UICL/mriqc_result/stopsignal --report-dir /mnt/functional/UICL/mriqc_result/stopsignal \
--verbose-reports --write-graph --mem_gb 55 \
--deoblique  --despike --correct-slice-timing --start-idx 5 \
--n_procs 8 --mem_gb 55
```

# Run FMRIPREP


```bash
# Run FMRIPREP

# Pull the lastest version of fmriprep

singularity pull docker://poldracklab/fmriprep:latest
        
# Run FMRIPREP on the cluster -- JAMES's WAY

#!/bin/sh
#$ -pe smp 10
#$ -q UI
#$ -m bea
#$ -M tien-tong@uiowa.edu
#$ -o /Users/tientong/logs/fmriprep/out/stopsignal
#$ -e /Users/tientong/logs/fmriprep/err/stopsignal
OMP_NUM_THREADS=8
singularity run -H /Users/tientong/.singularity \
-B /Shared/oleary/:/mnt \
/Users/tientong/.singularity/docker/fmriprep-latest.simg \
/mnt/functional/UICL/BIDS \
/mnt/functional/UICL/BIDS/derivatives/fmriprep/stopsignal \
participant --participant-label SUBJECT \
--task-id stopsignal --fs-license-file /mnt/functional/FreeSurferLicense/license.txt \
-w /mnt/functional/UICL/BIDS/derivatives/fmriprep/stopsignal --write-graph --use-syn-sdc \
--use-aroma --omp-nthreads 8 --nthreads 8 --mem_mb 22500
```


```bash
for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/subjects1.txt | tr '\n' ' ') ; do
    sed -e "s|SUBJECT|${sub}|" fmriprep_mid_TEMPLATE.job > fmriprep_mid_sub-${sub}.job
done


for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/subjects1.txt | tr '\n' ' ') ; do
    nohup qsub fmriprep_mid_sub-${sub}.job
done
```

# Edit confounds files

Confounds files are in:

```/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/TASK/fmriprep/SUB/SES/func```

We need to create a new confound file to include only the confounds we want (named `sub-SUB_ses-SES_task-TASK_run-RUN_bold_confounds-use.tsv`).

AS OF SEPT 17 2018: the results from FMRIPREP have already been motion corrected, slice timing corrected, smoothed, and denoised non-aggressively with ICA_AROMA. The confound file will be the 6 motion parameters.

The script to edit confounds files is:

`/Shared/oleary/functional/UICL/BIDS/code/edit_confounds.sh`



# Edit event files

We first have to extract behavioral data from txt file (E-Prime, presentation, etc.) to BIDS formatted event files, 

Use this script:

`/Shared/oleary/functional/UICL/BIDS/code/txt_2_BIDSevents-mid.R`

The output of this script is saved in BIDS directory, within the func directory of each subject:

`/Shared/oleary/functional/UICL/BIDS/sub-{sub}/ses-{ses}/func/sub-{sub}_ses-{ses}_task-mid_run-{run}_events.tsv`

__Important__: if we exclude the first couple of dummy TRs, we need to change the event timing files to reflect this. For examples, all time points for the MID will have to be substracted by 6 * 2 = 12s


#

Then, convert BIDS event files to 3 columns formatted event files, using 
    
`/Shared/oleary/functional/UICL/BIDS/code/BIDSto3col-allsub.sh`
    
Event files (for each trialt types separately) are saved in: 
    
`/Shared/oleary/functional/UICL/BIDS/sub-3003/ses-60844114/func/sub-3003_ses-60844114_task-mid_run-1_events-Gain0Hit.txt`

## Resample FMRIPREP Output without ICA

Before running first level analysis, we need to resample it first

1 Run --> Across runs --> Group Analysis, at which point we get coordinates of peak activations. The coordinates of peak activations HAVE to be on the same grid between different analyses (with vs. without ICA AROMA) 

THEREFORE, the data needs to be resample before first level analysis (1 run 1 sub). This is because FSL want a specific data structure, only resampling some COPES or VARCOPES might break something


3dresample -master -prefix -input


```bash
%%bash

source ~/sourcefiles/afni_source.sh

subj=(3003 3004 3005 3006 3009 3011 3013 3016 3017 3018 3021 3022 3023 3024 3025 3026 3027 3029 3030 3031 3032 3034 3036 3037 3039 3040 3041 3042 3043 3044 3045 3046 3050 3051 3052 3055 3056 3057 3058 3059 3060 3061 3062 3063 3066 3067 3068 3069 3070 3071 3072 3073 3074 3075 3076 3077 3078 3079 3080 3081 3082 3083 3084 3085 3086 3087 3089 3091 3093 3094 3095 3096 3097 3098 3099 3100 3101 3102 3103 3104 3106 3107 3108 3110 3111 3112 3113 3114 3116 3117 3118 3120 3123 3125 3126 3127 3128 3129 3130 3132 3133 3134 3136 3137 3138 3139 3140 3141 3142 3144 3145 3148 3149 3150 3151 3152 3153 3155 3157 3158 3160 3161 3163 3164 3165 3166 3167 3168 3169 3171 3172 3173 3175 3176 3177 3181 3182 3183 3184 3185 3186 3187 3188 3189 3192 3193 3195 3197 3198 3199 3200 3201 3202 3203 3204 3205 3206 3207 3208 3209 4101 5000 5001 5002 5003 5004 5006 5007 5008 5009 5010 5011 5012 5014 5015 5016 5017 5018 5020 5022 5024 5025 5026 5027 5028 5029 5030 5031 5032 5034 5035 5036 5037 5038 5039 5040 5041 5043 5044 5047 5048 5050 5051 5052 5054 5055 5059 5061 5062 5064 5065 5066 5067 5068 5069 5070 5072 5073 5074 5075 5076)
mrqid=(60844114 60642114 60730114 61218714 60946214 60913814 61230414 61319014 61449114 61434514 61032114 61145414 61432614 61722814 61549914 61521914 61535914 61620714 61750814 61721914 61708114 61822714 61763914 63926214 62369814 64069714 64182514 64184914 64125314 64272114 64066514 64243014 64559714 64444714 64442614 64342014 64558514 64459014 64744514 64977014 64645914 64572314 64747014 65047514 64975114 64990514 64932914 65147714 65060914 65076014 60223115 65062714 60641315 65248914 60093215 60527515 60498815 60628415 60483615 60512015 60597115 60595615 60526115 60700715 60540315 60585615 60926915 61045415 60801315 60712915 60743615 60900715 60930815 61027015 61031615 61348315 60988915 61032515 61231215 61290115 61017415 61333815 61230315 61491515 61001215 61346915 61636915 61388015 61435015 61535415 61635515 61620715 61705915 61693915 61895515 61835415 61822415 61907115 62137915 63764115 63551315 63937815 63954715 63853815 63739515 63710315 63940415 64040415 63825815 63969115 64012615 64128115 64153315 64154215 64415115 63868015 64069515 64024015 64356315 64416115 64573115 64743515 64457015 64917015 64632215 64470115 64875115 65050315 64859015 64948715 64731715 64861115 65061515 60511116 60585716 60667716 60527716 60683216 60727216 60815816 60700916 60900316 60898816 61029516 61101116 61304416 61636716 61680116 61507016 61491816 61835516 61632616 61693416 61722516 61708616 61823616 61837616 61924316 61936216 61807916 64874513 63969514 64024314 64157414 64427014 64343414 64670814 64557614 64657514 64544814 64672514 64746014 64628814 64661014 64686414 64974114 65074914 60439215 60643215 60842315 61331615 61144615 61101215 60885915 61102415 61044415 60927915 61216515 61303315 61447415 61518315 61736215 61723415 61807915 63537915 61851815 63750515 61794415 63939515 64053115 64227215 64357315 64443515 64340315 64224815 65059715 64617215 64831215 64659615 64934915 64958315 60094116 60423316 60830516 61190016 61014516 61088816 61204616 61405416 61319516 61780216)

for n in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 ; do
for run in 1 2 3 ; do

fmriprepdir=/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/mid/fmriprep/sub-${subj[$n]}/ses-${mrqid[$n]}/func

cd $fmriprepdir
3dresample -master sub-${subj[$n]}_ses-${mrqid[$n]}_task-mid_run-${run}_bold_space-MNI152NLin2009cAsym_variant-smoothAROMAnonaggr_preproc.nii.gz -prefix sub-${subj[$n]}_ses-${mrqid[$n]}_task-mid_run-${run}_bold_space-MNI152NLin2009cAsym_preproc_resampled.nii.gz -input sub-${subj[$n]}_ses-${mrqid[$n]}_task-mid_run-${run}_bold_space-MNI152NLin2009cAsym_preproc.nii.gz

done
done
```


```python
cd /oleary/functional/UICL/BIDS/code/subject_glm/stopsignal/subject_glm_1run/6regressors
bash
source ~/sourcefiles/fsl_source.sh
feat batch
```

# Run first level GLM for each subject for each run

## Create a template GLM via Feat GUI:


__For FMIRPREP output WIHTOUT ICA AROMA__

    Code saved in: /oleary/functional/UICL/BIDS/code/subject_glm/mid/subject_glm_1run/noICA
    Results saved in: /Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/noICA/


    
### Feat GUI Data tab
4D input data


__For FMIRPREP output WIHTOUT ICA AROMA__

/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/mid/fmriprep/sub-3004/ses-60642114/func/sub-3004_ses-60642114_task-mid_run-1_bold_space-MNI152NLin2009cAsym_preproc_resampled.nii.gz


Output directory: 


__For FMIRPREP output WIHTOUT ICA AROMA__

/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/noICA/sub-3004_ses-60642114_task-mid_run-1



Total volumes: 246-6 = 240 (exclude the first 6 TRs)

TR: 2s

Delete volumes: 0

High pass filter cutoff: 100s (= .01 Hz)

### Feat GUI Pre-stats tab

__For FMIRPREP output WIHTOUT ICA AROMA__
Turn off everything except BET and High pass, and spatial smoothing (6mm)
Note: previous AFNI analysis use smoothing kernel = 4mm, we're using 6mm now to keep things consistent with the SST

### Feat GUI Registration tab

Change to 6DOF - faster registration, because we don't care about the result of registration anyway. The 4D input was already registered to MNI

### Feat GUI Stats tab

Use FILM prewhitening
 
Add additional confound EVs = 6 motion parameters NEED TO CREATE THIS FILE by running /Shared/oleary/functional/UICL/BIDS/code/edit_confounds.sh, which will create confound files we actually want to use:

`/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/mid/fmriprep/sub-3004/ses-60642114/func/sub-3004_ses-60642114_task-mid_run-1_bold_confounds-use.tsv`

Full Model Setup: use 3 column format, convolved with double-gamma HRF, add temporal derivative and temporal filtering

    Note: in order to have event files, we first have to extract behavioral data from txt file (E-Prime, presentation, etc.) to BIDS formatted event files, then convert BIDS event files to 3 columns formatted event files, using 
    
    /Shared/oleary/functional/UICL/BIDS/code/BIDSto3col-allsub.sh
    
    Event files are in: 
    
    /Shared/oleary/functional/UICL/BIDS/sub-3003/ses-60844114/func/sub-3003_ses-60844114_task-mid_run-1_events-CorGo.txt
    
### Feat GUI Post-stats tab

Uncorrected Thresholding + turn off Create time series plots

## Save this set up as a template `subject_glm_TEMPLATE.fsf`

## Write subject specific Feat then run it

change subject number, session, task name, and run number into place holder that can be replaced using `/Shared/oleary/functional/UICL/BIDS/code/subject_glm/mid/subject_glm_1run/noICA/run_subject_glm.sh`

Make sure that you have turned off motion correction, slice time correction.

Change EPI TE to 29 (stopsignal)


NOTE: `run_subject_glm.sh` use subject list (subjectstest.txt) and session list (session1test.txt) in `/Shared/oleary/functional/UICL/BIDS/subject_list/`. Remember to check and modify those text files to run the subjects you want.

Run the .fsf script with:
`feat SCRIPTNAME.fsf`. 

Run multiple scripts at once to speed things up.

`ls *sub-*.fsf | xargs -i{} -P10 feat {}`

# Second level GLM for each subject across run

If we run Fixed Effect model -> get the average across runs for each subject.

## Delete unnecessary registration files

Since outputs from FMRIPREP were already registerd to MNI, we need to stop FSL from doing registration one more time.

To do this, run 


__noICA__
/Shared/oleary/functional/UICL/BIDS/code/subject_glm/mid/skip_registration.sh


This script will make modification in the `reg/` directory of Feat outputs. In particular, it will replace the EPI --> MNI matrix by an identity matrix to make sure the there would be no transformation. Secondly, it will replace the standard.nii.gz by a random EPI volume, to make sure that there would be no interpolation.

For more information, watch this: https://www.youtube.com/watch?v=U3tG7JMEf7M 


For FMIRPREP output WIHTOUT ICA AROMA 
the script is in /oleary/functional/UICL/BIDS/code/subject_glm/mid/across_run_glm/noICA


## Make 2nd level .fsf script

script: /Shared/oleary/functional/UICL/BIDS/code/subject_glm/mid/acrossruns/avg_across_runs_TEMPLATE.fsf
outputs saved to: /Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/acrossruns

### Data tab

Inputs are lower-level FEAT directories

Number of inputs = number of runs



__For FMIRPREP output WIHTOUT ICA AROMA__ 
inputs: 
/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/noICA/sub-3004_ses-60642114_task-mid_run-1.feat

/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/noICA/sub-3004_ses-60642114_task-mid_run-2.feat

/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/noICA/sub-3004_ses-60642114_task-mid_run-3.feat

output:
/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/acrossruns-noICA/3004



### Stats tab

Choose Fixed effects model so that the results we get are just the average of all runs (mixed effects will take into account variance across runs.

Model setup: EV1 = subject ID
Contrast = subject mean

### Post-stats tab

Uncorrected thresholding

## Save this set up as a template `avg_across_runs_TEMPLATE.fsf`

change subject number, session, task name, and run number into place holder that can be replaced using `/Shared/oleary/functional/UICL/BIDS/code/subject_glm/mid/acrossruns/run_subject_avg_across_run.sh`



## Run run_across_runs.sh

run 2nd level for everybody

`ls *sub-*.fsf | xargs -i{} -P10 feat {}`

## Transform and binarize Neurosynth z-stat map

Before running the group analysis, we want to restrict group analysis to only important voxels --> need to create a pre-threshold mask first

Download z-stat map with search term 
"reward" -- 992 studies
"loss" -- 396 studies

Download uniformity test:

uniformity test map: z-scores from a one-way ANOVA testing whether the proportion of studies that report activation at a given voxel differs from the rate that would be expected if activations were uniformly distributed throughout gray matter.

association test map: z-scores from a two-way ANOVA testing for the presence of a non-zero association between term use and voxel activation.

Long answer: The uniformity test and association test maps are statistical inference maps; they display z-scores for two different kinds of analyses. The uniformity test map can be interpreted in roughly the same way as most standard whole-brain fMRI analysis: it displays the degree to which each voxel is consistently activated in studies that use a given term. For instance, the fact that the uniformity test map for the term 'emotion' displays high z-scores in the amygdala implies that studies that use the word emotion a lot tend to consistently report activation in the amygdala--at least, more consistently than one would expect if activation were uniformly distributed throughout gray matter. Note that, unlike most meta-analysis packages (e.g., ALE or MKDA), z-scores aren't generated through permutation, but using a chi-square test. (We use the chi-square test solely for pragmatic reasons: we generate thousands of maps at a time, so it's not computationally feasible to run thousands of permutations for each one.)

The association test maps provides somewhat different (and, in our view, typically more useful) information. Whereas the uniformity test maps tell you about the consistency of activation for a given term, the association test maps tell you whether activation in a region occurs more consistently for studies that mention the current term than for studies that don't. So for instance, the fact that the amygdala shows a large positive z-score in the association test map for emotion implies that studies whose abstracts include the word 'emotion' are more likely to report amygdala activation than studies whose abstracts don't include the word 'emotion'. That's important, because it controls for base rate differences between regions. Meaning, some regions (e.g., dorsal medial frontal cortex and lateral PFC) play a very broad role in cognition, and hence tend to be consistently activated for many different terms, despite lacking selectivity. The association test maps let you make slightly more confident claims that a given region is involved in a particular process, and isn't involved in just about every task.

the script is:
/Shared/oleary/functional/UICL/BIDS/derivatives/group_analysis/neurosynth/reorient.sh

1) Transform Neurosynth anatomy (MNI 6th gen 2x2x2) --> EPI (MNI 2009c 2x2x2) --> save transformation matrix
2) Apply this transformation matrix to Neurosynth z stat map
3) binarized the transfomred z stat amp


# Group level GLM comparing subjects

Scripts are saved to

`/Shared/oleary/functional/UICL/BIDS/code/group_glm/mid`


__For FMIRPREP output WIHTOUT ICA AROMA__ 

/oleary/functional/UICL/BIDS/code/group_glm/mid


## Setting up the script using Feat GUI

Inputs are the gfeat directories of each participants:

eg `/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/sub-3003/ses-60844114/stopsignal/sub-3003_ses-60844114_task-stopsignal_allruns.gfeat/cope8.feat`

cope 8 = contrast parameter estimate CorStop-CorGo

Output directory:

`/Shared/oleary/functional/UICL/BIDS/derivatives/group_analysis/stopsignal/CorStop-CorGo`

### Stats tab

Mixed effects using Flame 1

Remember to turn off motion correction, etc., check TR, TE

### Post-stats tab

Use cluster thresholding, z = 3.1, p = .05

Save this script.

Replicate this script, but change cope 6 to cope 7 ( = contrast parameter estimate CorStop-IncStop)

# script to make figure from stat maps

/oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/mid-results.ipynb

# Randomise

https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Randomise/UserGuide

randomise -i <4D_input_data> -o <output_rootname> -d design.mat -t design.con -m <mask_image> -n 500 -D -T

design.mat and design.con are text files containing the design matrix and list of contrasts required; they follow the same format as generated by FEAT (see below for examples). The -n 500 option tells randomise to generate 500 permutations of the data when building up the null distribution to test against. The -D option tells randomise to demean the data before continuing - this is necessary if you are not modelling the mean in the design matrix. The -T option tells randomise that the test statistic that you wish to use is TFCE (threshold-free cluster enhancement - see below for more on this). 

When using the demeaning option, -D, randomise will also demean the EVs in the design matrix, providing a warning if they initially had non-zero mean (and as long as this doesn't cause the matrix/contrasts to become rank deficient then this warning can be ignored). 

randomise has the following thresholding/output options:

    Voxel-based thresholding, both uncorrected and corrected for multiple comparisons by using the null distribution of the max (across the image) voxelwise test statistic. Uncorrected outputs are: <output>_vox_p_tstat / <output>_vox_p_fstat. Corrected outputs are: <output>_vox_corrp_tstat / <output>_vox_corrp_fstat. To use this option, use -x.

    TFCE (Threshold-Free Cluster Enhancement) is a new method for finding "clusters" in your data without having to define clusters in a binary way. Cluster-like structures are enhanced but the image remains fundamentally voxelwise; you can use the -tfce option in fslmaths to test this on an existing stats image. See the TFCE research page for more information. The "E", "H" and neighbourhood-connectivity parameters have been optimised and should be left unchanged. These optimisations are different for different "dimensionality" of your data; for normal, 3D data (such as in an FSL-VBM analysis), you should just just the -T option, while for TBSS analyses (that is in effect on the mostly "2D" white matter skeleton), you should use the --T2 option.

    Cluster-based thresholding corrected for multiple comparisons by using the null distribution of the max (across the image) cluster size (so passé!): <output>_clustere_corrp_tstat / <output>_clustere_corrp_fstat.
    To use this option, use -c <thresh> for t contrasts and -F <thresh> for F contrasts, where the threshold is used to form supra-threshold clusters of voxels.

    Cluster-based thresholding corrected for multiple comparisons by using the null distribution of the max (across the image) cluster mass: <output>_clusterm_corrp_tstat / <output>_clusterm_corrp_fstat.
    To use this option, use -C <thresh> for t contrasts and -S <thresh> for F contrasts. 

## Contrast Gain 5 vs 0 Hit: Control vs. 4 Binge groups combined


```bash
# list all subjects cope

ls /oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/acrossruns-noICA/*.gfeat/cope3.feat/stats/cope1.nii.gz
sed -i ':a;N;$!ba;s/\n/\t/g' file_with_line_breaks

# create 1 file that concatenate all subjects cope
# run this

/oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/makeinput_gain5v0_ctrl-binge.sh

# test if it's correct

fslnvols input_gain5v0_ctrl-binge.nii.gz


### EXCLUDING 14 SUBJECTS IN BINGE GROUPS THAT DID NOT REPORT BINGEING

# create 1 file that concatenate all subjects cope
# run this

/oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/makeinpute_gain5v0_ctrl-binge_excl14.sh

# test if it's correct

fslnvols input_gain5v0_ctrl-binge_excl14.nii.gz
```


```bash
randomise \
-i /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/input_gain5v0_ctrl-binge.nii.gz \
-o /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/gain5v0_ctrl-binge-D \
-d /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge.mat \
-t /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge.con \
-m /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.11_multicore/data/standard/MNI152_T1_2mm_brain_mask.nii.gz \
-D -n 5000 -T


randomise \
-i /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/input_gain5v0_ctrl-binge.nii.gz \
-o /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/gain5v0_ctrl-binge \
-d /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge.mat \
-t /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge.con \
-m /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.11_multicore/data/standard/MNI152_T1_2mm_brain_mask.nii.gz \
-n 5000 -T


### EXCLUDING 14 SUBJECTS IN BINGE GROUPS THAT DID NOT REPORT BINGEING
randomise \
-i /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/input_gain5v0_ctrl-binge_excl14.nii.gz \
-o /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/gain5v0_ctrl-binge_excl14 \
-d /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge_excl14.mat \
-t /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge_excl14.con \
-m /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.11_multicore/data/standard/MNI152_T1_2mm_brain_mask.nii.gz \
-n 5000 -T
```

## Contrast Loss 5 vs 0 Hit: Control vs. 4 Binge groups combined


```bash
ls /oleary/functional/UICL/BIDS/derivatives/subject_level_glm/mid/acrossruns-noICA/*.gfeat/cope6.feat/stats/cope1.nii.gz

# create 1 file that concatenate all subjects cope
# run this

/oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/makeinput_loss5v0_ctrl-binge.sh

# test if it's correct

fslnvols input_loss5v0_ctrl-binge.nii.gz


### EXCLUDING 14 SUBJECTS IN BINGE GROUPS THAT DID NOT REPORT BINGEING

# create 1 file that concatenate all subjects cope
# run this

/oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/makeinpute_loss5v0_ctrl-binge_excl14.sh

# test if it's correct

fslnvols input_loss5v0_ctrl-binge_excl14.nii.gz
```


```bash
randomise \
-i /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/input_loss5v0_ctrl-binge.nii.gz \
-o /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/loss5v0_ctrl-binge \
-d /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge.mat \
-t /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge.con \
-m /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.11_multicore/data/standard/MNI152_T1_2mm_brain_mask.nii.gz \
-n 5000 -T

### EXCLUDING 14 SUBJECTS IN BINGE GROUPS THAT DID NOT REPORT BINGEING
randomise \
-i /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/input_loss5v0_ctrl-binge_excl14.nii.gz \
-o /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/loss5v0_ctrl-binge_excl14 \
-d /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge_excl14.mat \
-t /oleary/functional/UICL/BIDS/derivatives/group_analysis/mid/Gain5vs0/randomise/ctrl-binge_excl14.con \
-m /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.11_multicore/data/standard/MNI152_T1_2mm_brain_mask.nii.gz \
-n 5000 -T
```

Viewing randomise results


```bash
fslstats gain5v0_ctrl-binge_tfce_corrp_tstat1.nii.gz -R
fslstats gain5v0_ctrl-binge_tfce_corrp_tstat2.nii.gz -R

fslstats loss5v0_ctrl-binge_tfce_corrp_tstat1.nii.gz -R
fslstats loss5v0_ctrl-binge_tfce_corrp_tstat2.nii.gz -R
```


```bash
fslstats gain5v0_ctrl-binge_excl14_tfce_corrp_tstat1.nii.gz -R
fslstats gain5v0_ctrl-binge_excl14_tfce_corrp_tstat2.nii.gz -R

fslstats loss5v0_ctrl-binge_excl14_tfce_corrp_tstat1.nii.gz -R
fslstats loss5v0_ctrl-binge_excl14_tfce_corrp_tstat2.nii.gz -R
```

