# O'Leary-Vaidya Lab - University of Iowa College Life study (UICL)

This repo contains code to analyze fMRI data of the UICL study:
* [Resting state](https://github.com/tientong98/OLearyVaidyaLab-UICL/tree/master/Rest)

* [Monetary Incentive Delay task - MID](https://github.com/tientong98/OLearyVaidyaLab-UICL/tree/master/MID)

* [Stop Signal Task - SST](https://github.com/tientong98/OLearyVaidyaLab-UICL/tree/master/SST)


Overall,the pipeline of all 3 fMRI datasets involve:
1. [Conversion to BIDS format](https://github.com/tientong98/OLearyVaidyaLab-UICL/blob/master/Heudiconv.ipynb)
2. [Run MRIQC](https://github.com/tientong98/OLearyVaidyaLab-UICL/blob/master/MRIQC.ipynb)
3. Run fMRIPrep
4. Run single subject GLM
5. Group analysis
  * Whole-brain
  * ROIs

### Participants

Participants from the study were divided into 5 groups:
1. Standard binge drinkers (4/5 drinks in 2 hours for females/males)
2. Extreme bingers (8+/10+ drinks in 2 hours for females/males)
3. Standard bingers with regular marijuana use
4. Extreme bingers with regular marijuana use
5. Non-bingers with no regular marijuana use
