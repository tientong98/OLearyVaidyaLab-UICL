# Group Analysis

**Analysis folder**: Code of various group statistical tests, after rsFCs (using the Extended Power atlas) have been computed and extracted.

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

randomise -i <4D_input_data> -o <output_rootname> -d design.mat -t design.con -m <mask_image> -n 500 -D -T

Tutorial here: https://www.youtube.com/watch?v=Ukl1VWobviw
Need: group average nifti, design matrix and contrast file

Code: `/oleary/functional/UICL/BIDS/code/randomise/rest` 

### 40 Controls vs 180 Bingers

First, run `get_input.Rmd` to get list of files with subjects in the correct order
Then, run `fslmerge` with option `t` to concatnate all files to create the input of `randomise`

### 5 groups comparison: Control vs sBinge vs eBinge vs sBingeMJ vs eBinge MJ

## xcpEngine - not use this right now

https://xcpengine.readthedocs.io/overview.html

now downloaded in /oleary/xcpEngine-master

install the python wrapper: pip install xcpengine-container

download singularity image using the following code: 

singularity build xcpEngine.simg docker://pennbbl/xcpengine:latest

In order to incorporate the new atlas to xcpEngine pipeline, need to follow the instructions in: https://xcpengine.readthedocs.io/development.html

1. Clonning the source code: git clone https://github.com/PennBBL/xcpEngine.git
2. Create a new folder in the atlas directory to include the new atlas
3. change the design file /xcpEngine-master/designs/fc-36p_scrub_mergedatlas.dsn so that all lines of codes that used power264 now used the merged atlas

## xcpEngine Step 1 - create a cohort file

https://xcpengine.readthedocs.io/config/cohort.html#cohortfile


```bash
ls /oleary/functional/UICL/BIDS/derivatives/fmriprep/rest/fmriprep/sub-*/ses-*/func/*rest*MNI152NLin2009cAsym_preproc.nii.gz > /oleary/functional/UICL/BIDS/derivatives/xcpengine/cohort01.csv

awk '{gsub("/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest/fmriprep/", "");print}' /oleary/functional/UICL/BIDS/derivatives/xcpengine/cohort01.csv > /oleary/functional/UICL/BIDS/derivatives/xcpengine/cohort02.csv

```


```bash
# example script to run xcpengine on argon
# to understand the script, read this:
# https://sudoneuroscience.wordpress.com/2017/06/08/running-multiple-jobs-on-the-argon-cluster-example-with-fmriprep/



#!/bin/sh
#$ -pe smp 3
#$ -q PINC
#$ -m e
#$ -M tien-tong@uiowa.edu
#$ -o /Users/tientong/logs/uicl/xcpengine/out
#$ -e /Users/tientong/logs/uicl/xcpengine/err

singularity run \
  -B /Shared/oleary:/mnt \
  /Users/tientong/xcpEngine.simg \
  -d /Users/tientong/xcpEngine/designs/fc-36p_scrub.dsn \
  -c /mnt/functional/UICL/BIDS/derivatives/xcpengine/cohort.csv \
  -r /mnt/functional/UICL/BIDS/derivatives/fmriprep/rest/fmriprep \
  -i $TMPDIR \
  -o /mnt/functional/UICL/BIDS/derivatives/xcpengine
```

## Create an atlas

Download the following 3 atlases (now downloaded and are in **/oleary/atlas**):  
Buckner cerebellum: http://www.freesurfer.net/fswiki/CerebellumParcellation_Buckner2011  
Choi striatum: https://surfer.nmr.mgh.harvard.edu/fswiki/StriatumParcellation_Choi2012  
Schaefer cortical: https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/brain_parcellation/Schaefer2018_LocalGlobal  

Use James's script **/oleary/atlas/merge_atlas.py** by running the line of code below, when you're in /oleary/atlas   


```bash
./merge_atlas.py \
-a Schaefer/MNI/Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.nii.gz \
Choi_JNeurophysiol12_MNI152/Choi2012_17Networks_MNI152_FreeSurferConformed1mm_LooseMask.nii.gz \
Buckner_JNeurophysiol11_MNI152/Buckner2011_17Networks_MNI152_FreeSurferConformed1mm_LooseMask.nii.gz \
-r /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.11_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
-t schaefer_parcel-400_network-17.tsv -n Striatal Cerebellar

# Afterward, you'll have those files:  

# lut.tsv -- a look up table with the regions indexes and names    
# mergedAtlas.nii.gz -- a new atlas that are the combination of the 3 atlases
```


```bash
#!/bin/sh

#$ -pe smp 2
#$ -q PINC
#$ -m e
#$ -M tien-tong@uiowa.edu
#$ -o /Users/tientong/logs/uicl/xcpengine/out
#$ -e /Users/tientong/logs/uicl/xcpengine/err

singularity run -B /Users/tientong/xcpEngine/atlas/merged:/xcpEngine/atlas/merged \
-H /Users/tientong/singularity_home \
/Users/tientong/xcpEngine.simg \
-d /Users/tientong/xcpEngine/designs/fc-aroma_mergedatlas.dsn \
-c /Shared/oleary/functional/UICL/BIDS/derivatives/xcpengine/cohort.csv \
-o /Shared/oleary/functional/UICL/BIDS/derivatives/xcpengine/testmergedatlas \
-t 1 -r /Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest/fmriprep
```


```bash
singularity shell \
  -B /Shared/oleary:/mnt \
  -B `pwd`/xcpEngine:/xcpEngine \
  xcpEngine.simg
```


```bash
xcpEngine\
  -d /xcpEngine/designs/fc-36p_scrub_mergedatlas.dsn \
  -c /mnt/functional/UICL/BIDS/derivatives/xcpengine/cohort.csv \
  -i /mnt/functional/UICL/BIDS/derivatives/xcpengine \
  -o /mnt/functional/UICL/BIDS/derivatives/xcpengine
```
