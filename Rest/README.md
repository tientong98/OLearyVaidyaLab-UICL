# Group Analysis

**[Analysis folder](https://github.com/tientong98/OLearyVaidyaLab-UICL/tree/master/Rest/Analysis)**: Code of various group statistical tests, after rsFCs (using the [Extended Power atlas](https://wustl.app.box.com/s/twpyb1pflj6vrlxgh3rohyqanxbdpelw)) have been computed and extracted.

# Subject level analysis

Step-by-step analysis (raw -> subject level analysis) was detailed below.

## BIDSification

Run heudiconv. Scripts stored in:
`/oleary/functional/UICL/BIDS/code`

details in **Heudiconv.ipynb**

Then, check to see if heudiconv failed for any subject using **check_missing_outputs.ipynb**


## Exclude dummy TRs

Once you get the data in BIDS format, you need to get rid of the dummy TRs at the beginning of the run BEFORE running FMRIPREP

Run **/oleary/functional/UICL/BIDS/code/exclude_first_TRs.sh**. For the resting state scanes in UICL, we will exclude the first 3 TRs (6 seconds)

Remember to make a note of this in a task json file (/oleary/functional/UICL/BIDS/task-rest_bold.json) in the following fields:

`"NumberOfVolumesDiscardedByUser": 3,
"NumberOfVolumesDiscardedByScanner": 2,`

Rest data = 177 volumes x 2s TR = 354s = 5.9 mins

## Run MRIQC


```bash
# pull the lastest version of mriqc

singularity pull docker://poldracklab/mriqc:<version number>



# run the code below on Argon

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

## Run FMRIPREP

Note: As of Sep 5 2019 fmriprep version 1.4.1 the ANTs command for fieldmap-less distortion correction (`--use-syn-sdc`) didn't work with the new MNI152 template (details here https://github.com/poldracklab/fmriprep/issues/1665)

Therefore for UICL time 1 resting state data, this option was turned OFF.


```bash
# First create a template file for submitting jobs on argon


#!/bin/sh
#$ -pe smp 10
#$ -q PINC,UI
#$ -m e
#$ -M tien-tong@uiowa.edu
#$ -o /Users/tientong/logs/uicl/fmriprep/out/rest
#$ -e /Users/tientong/logs/uicl/fmriprep/err/rest
OMP_NUM_THREADS=8 
singularity run -H /Users/tientong/singularity_home \
-B /Shared/oleary/:/mnt \
/Users/tientong/poldracklab_fmriprep_1.4.1-2019-07-09-86bf8bc4b7d5.img \
/mnt/functional/UICL/BIDS \
/mnt/functional/UICL/BIDS/derivatives/fmriprep/rest \
participant --participant-label SUBJECT --skip_bids_validation \
-t rest --fs-license-file /mnt/functional/FreeSurferLicense/license.txt --fs-no-reconall \
-w /mnt/functional/UICL/BIDS/derivatives/fmriprep/rest --write-graph \
--use-aroma --error-on-aroma-warnings --output-spaces T1w func MNI152NLin6Asym:res-2 --stop-on-first-crash \
--omp-nthreads 8 --nthreads 8 --mem_mb 22500 --notrack
```


```bash
# then run this on argon

for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/subjects.txt | tr '\n' ' ') ; do
sed -e "s|SUBJECT|${sub}|" fmriprep_rest_TEMPLATE.job > fmriprep_rest_sub-${sub}.job
done

for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/subjects.txt | tr '\n' ' ') ; do
    nohup qsub fmriprep_rest_sub-${sub}.job
done 

```


```bash
# check if FMRIPREP failed for any subject, try to rerun

touch /Shared/oleary/functional/UICL/BIDS/subject_list/fails.txt
echo -e "3027\n3037\n3182" > /Shared/oleary/functional/UICL/BIDS/subject_list/fails.txt
cat /Shared/oleary/functional/UICL/BIDS/subject_list/fails.txt

# then run this on argon

for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/fails.txt | tr '\n' ' ') ; do
    nohup qsub fmriprep_rest_sub-${sub}.job
done 
```

## Use the extended Power ROI 

Links: https://greenelab.wustl.edu/data_software

Downloaded to: /oleary/atlas/greeneatlas/orig

Then run 

* 01-create-coord.R
* 02-3dundump.sh

to create 300 spherical ROIs

## Nuisance Regression

Code in: /oleary/functional/UICL/BIDS/code

1. Non-aggressively denoise unsmooth BOLD with ICA-AROMA. Code: `rest01_aromaunsmooth.sh`
2. Extract WM and CSF time series from the output of 1. Code: `rest02_WMCSFts.sh and rest03_confound.R`
3. Nuisance regression and bandpass filter of the output from 2. Code: `rest04_bpreg.sh`
4. Calculate correlation matrix of the 300 ROIs from the extended Power atlas. Code: `rest05_ROIts.sh`


```bash

sh rest04_bpreg.sh 2>&1 | tee /oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/3dTprojectlog.txt

sh rest05_ROIts.sh 2>&1 | tee /oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/extendedPowerlog.txt
```

## Seed-whole brain correlation analysis

Code: `/oleary/functional/UICL/BIDS/code/rest07_seedbased.sh`
    
First, use `3dmaskave` to get time series of interested ROIs.
Then, use `3dTcorr1D` to get correlation between ROIs timeseries and the rest of the brain
Lastly, use `3dcalc` to do Fisher's r to z transformation 

## Group analysis of seed based analysis: randomise

User guide hereL https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Randomise/UserGuide

`randomise -i <4D_input_data> -o <output_rootname> -d design.mat -t design.con -m /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.8_multicore/data/standard/MNI152_T1_2mm_brain_mask.nii.gz -n 5000 -T`

Tutorial here: https://www.youtube.com/watch?v=Ukl1VWobviw
Need: group average nifti, design matrix and contrast file

Code: `/oleary/functional/UICL/BIDS/code/randomise/rest` 

First, run [get_input.Rmd](https://github.com/tientong98/OLearyVaidyaLab-UICL/blob/master/Rest/get_input.Rmd) to get list of files with subjects in the correct order

Then, run `fslmerge` with option `t` to concatnate all files to create the input of `randomise`. [Example](https://github.com/tientong98/OLearyVaidyaLab-UICL/blob/master/Rest/makeinpute_LAmyg.sh)

Lastly, run randomise scripts
    * Creat [template file](https://github.com/tientong98/OLearyVaidyaLab-UICL/blob/master/Rest/randomise_TEMPLATE.sh) to run randomise across different ROIs and Contrasts
    * Run the for loop below for specific ROI and Contrast
    ```
    for roi in LAmyg RAmyg LNAcc RNAcc ; do
        for contrast in ConvBinge 5group ; do
            sed -e "s|ROI|${roi}|" -e "s|CONTRAST|${contrast}|" randomise_TEMPLATE.sh > randomise_${roi}_${contrast}.sh
        done
    done
    ```
