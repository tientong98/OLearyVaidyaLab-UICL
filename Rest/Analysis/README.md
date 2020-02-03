Inputs for the group analysis = Outputs from the Subject level analysis pipeline, which are are outputs from AFNI 3dNetCorr.

* `01-CleanData.Rmd` Read and clean the data, only include 267 ROIs (out of the original 300) that all subjects have data for. Then, calculate 91 between (off diagonal) and within (on diagonal) correlations from the 13 networks (from the [extended Power atlas](https://wustl.app.box.com/s/twpyb1pflj6vrlxgh3rohyqanxbdpelw), 13 actual networks, 1 for the unassigned ROIs).
  * [Group average correlation matrix](https://github.com/tientong98/OLearyVaidyaLab-UICL/blob/master/Rest/Analysis/plot.pdf) - pretty comparable to the orginial paper (https://doi.org/10.1016/j.neuroimage.2019.116290), except:
      * They used Gobal Signal Regression --> They have more negative correlations than our sample
      * They plotted the ROIs with NULL data (white rows/columns), while I excluded those from the beginning.
* `02-GroupAnalysis-BetweenWithinNetwork.Rmd` Write a for loop to test 1-way anova (5 groups) for each of the 91 DVs, store the p values of those F tests in a vector, then run `p.adjust` using this pvalues vector as input.
* `03-GroupAnalysis-ROI2ROI.Rmd` The correlation matrix is 267 x 267, resulting in 35511 unique elements. This script test 1-way anova (5 groups) for each of those 35511 DVs, just out of morbid curiosity.
* `04-Correlation.Rmd` correlation between the 91 within- and between-network correlation with self-reported substance use and negative consequences related to alcohol use.
* `05-SexAge.Rmd` Testing the effect of sex and age on Functional connectivity, YAACQ, drug use frequency
* `CCAanalysis_code.Rmd` Canonical correlation analysis between 91 rsFCs and YAACQ+drug use frequency
