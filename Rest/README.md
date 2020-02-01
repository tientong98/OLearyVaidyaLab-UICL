Code for the resting state data

1. Non-aggressively denoise unsmooth BOLD with ICA-AROMA. Code: `rest01_aromaunsmooth.sh`
2. Extract WM and CSF time series from the output of 1. Code: `rest02_WMCSFts.sh and rest03_confound.R`
3. Nuisance regression and bandpass filter of the output from 2. Code: `rest04_bpreg.sh`
4. Calculate correlation matrix of the 300 ROIs from the extended Power atlas. Code: `rest05_ROIts.sh`
