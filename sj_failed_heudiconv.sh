/Shared/pinc/sharedopt/apps/MRIcroGL/Linux/x86_64/20180614/dcm2niix -b y -z y -f "%t_%p_%s" /Shared/oleary/functional/UICL/dicomdata/3003/60844114/
______

mv 5002/20141015 5002/64157414
mv 5002/20141022 5002/64257314

for ses in 64157414 64257314 ; do
mv 5002/$ses/SCANS/* 5002/$ses/
rm -rf 5002/$ses/SCANS
rm -rf 5002/$ses/SNAPSHOTS
done


for n in 2 3 5 7 8 9 10 11 ; do
dicom=/Shared/oleary/functional/UICL/dicomdata/tien/5002/64157414/$n/DICOM/
out=/Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414
mkdir -p $out
/Shared/pinc/sharedopt/apps/MRIcroGL/Linux/x86_64/20180614/dcm2niix -b y -z y -f "%t_%p_%s" -o $out $dicom
done

for n in 2 3 4 ; do
dicom=/Shared/oleary/functional/UICL/dicomdata/tien/5002/64257314/$n/DICOM/
out=/Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64257314
mkdir -p $out
/Shared/pinc/sharedopt/apps/MRIcroGL/Linux/x86_64/20180614/dcm2niix -b y -z y -f "%t_%p_%s" -o $out $dicom
done

######

mv 5008/20141015 5008/64657514
mv 5008/20141022 5008/64685714

for ses in 64657514 64685714 ; do
mv 5008/$ses/SCANS/* 5008/$ses/
rm -rf 5008/$ses/SCANS
rm -rf 5008/$ses/SNAPSHOTS
done

for n in 2 3 5 7 8 9 10 11 ; do
dicom=/Shared/oleary/functional/UICL/dicomdata/tien/5008/64657514/$n/DICOM/
out=/Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514
mkdir -p $out
/Shared/pinc/sharedopt/apps/MRIcroGL/Linux/x86_64/20180614/dcm2niix -b y -z y -f "%t_%p_%s" -o $out $dicom
done

for n in 2 3 4 ; do
dicom=/Shared/oleary/functional/UICL/dicomdata/tien/5008/64685714/$n/DICOM/
out=/Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64685714
mkdir -p $out
/Shared/pinc/sharedopt/apps/MRIcroGL/Linux/x86_64/20180614/dcm2niix -b y -z y -f "%t_%p_%s" -o $out $dicom
done

### Putting things into BIDS

sub=(5002 5002 5008 5008)
ses=(64157414 64257314 64657514 64685714)

for n in 0 1 2 3 ; do
mkdir -p /oleary/functional/UICL/BIDS/sub-${sub[$n]}/ses-${ses[$n]}/anat
mkdir -p /oleary/functional/UICL/BIDS/sub-${sub[$n]}/ses-${ses[$n]}/func
mkdir -p /oleary/functional/UICL/BIDS/sub-${sub[$n]}/ses-${ses[$n]}/dwi
done

sub=(5002 5008)
ses=(64157414 64657514)
for n in 0 1 ; do
bids=/oleary/functional/UICL/BIDS/sub-${sub[$n]}/ses-${ses[$n]}
mv $bids/*MID*RUN_1*.json $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-mid_run-1_bold.json
mv $bids/*MID*RUN_1*.nii.gz $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-mid_run-1_bold.nii.gz
mv $bids/*MID*RUN_2*.json $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-mid_run-2_bold.json
mv $bids/*MID*RUN_2*.nii.gz $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-mid_run-2_bold.nii.gz
mv $bids/*MID*RUN_3*.json $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-mid_run-3_bold.json
mv $bids/*MID*RUN_3*.nii.gz $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-mid_run-3_bold.nii.gz
mv $bids/*REST*.json $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.json
mv $bids/*REST*.nii.gz $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.nii.gz
mv $bids/*Stop_Signal*5*.json $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-stopsignal_run-1_bold.json
mv $bids/*Stop_Signal*5*.nii.gz $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-stopsignal_run-1_bold.nii.gz
mv $bids/*Stop_Signal*7*.json $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-stopsignal_run-2_bold.json
mv $bids/*Stop_Signal*7*.nii.gz $bids/func/sub-${sub[$n]}_ses-${ses[$n]}_task-stopsignal_run-2_bold.nii.gz
mv $bids/*T2_SAGITTAL_2*.json $bids/anat/sub-${sub[$n]}_ses-${ses[$n]}_acq-TE11_T2w.json
mv $bids/*T2_SAGITTAL_2*.nii.gz $bids/anat/sub-${sub[$n]}_ses-${ses[$n]}_acq-TE11_T2w.nii.gz
mv $bids/*T2_in_Plane_of_fMR*.json $bids/anat/sub-${sub[$n]}_ses-${ses[$n]}_acq-TE54_T2w.json
mv $bids/*T2_in_Plane_of_fMR*.nii.gz $bids/anat/sub-${sub[$n]}_ses-${ses[$n]}_acq-TE54_T2w.nii.gz
done


sub=(5002 5008)
ses=(64257314 64685714)
for n in 0 1 ; do
bids=/oleary/functional/UICL/BIDS/sub-${sub[$n]}/ses-${ses[$n]} 
mv $bids/*MPRAGE*.json $bids/anat/sub-${sub[$n]}_ses-${ses[$n]}_T1w.json
mv $bids/*MPRAGE*.nii.gz $bids/anat/sub-${sub[$n]}_ses-${ses[$n]}_T1w.nii.gz
mv $bids/*T2-PREP*.json $bids/anat/sub-${sub[$n]}_ses-${ses[$n]}_acq-TE406_T2w.json
mv $bids/*T2-PREP*.nii.gz $bids/anat/sub-${sub[$n]}_ses-${ses[$n]}_acq-TE406_T2w.nii.gz
mv $bids/*ep2d_diff*.json $bids/dwi/sub-${sub[$n]}_ses-${ses[$n]}_dwi.json
mv $bids/*ep2d_diff*.nii.gz $bids/dwi/sub-${sub[$n]}_ses-${ses[$n]}_dwi.nii.gz
mv $bids/*ep2d_diff*.bvec $bids/dwi/sub-${sub[$n]}_ses-${ses[$n]}_dwi.bvec
mv $bids/*ep2d_diff*.bval $bids/dwi/sub-${sub[$n]}_ses-${ses[$n]}_dwi.bval
done

########
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 24 DICOM file(s)
Convert 24 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414/20141015170954_T2_SAGITTAL_2 (256x256x24x1)
Conversion required 0.602265 seconds (0.370000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 180 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 180 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414/20141015170954_RESTING_STATE_3 (64x64x32x180)
Conversion required 6.749415 seconds (5.740000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 205 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 205 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414/20141015170954_Stop_Signal_5 (128x128x31x205)
Conversion required 25.972996 seconds (23.510000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 205 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 205 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414/20141015170954_Stop_Signal_7 (128x128x31x205)
Conversion required 25.871910 seconds (23.340000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 31 DICOM file(s)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 31 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414/20141015170954_T2_in_Plane_of_fMR_-23_DEG_8 (256x256x31x1)
Conversion required 0.749803 seconds (0.550000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 246 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 246 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414/20141015170954_MID_RUN_1_9 (64x64x32x246)
Conversion required 8.852588 seconds (7.690000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 246 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 246 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414/20141015170954_MID_RUN_2_10 (64x64x32x246)
Conversion required 8.852345 seconds (7.620000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 246 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 246 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64157414/20141015170954_MID_RUN_3_11 (64x64x32x246)
Conversion required 8.886510 seconds (7.660000 for core code).

Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 256 DICOM file(s)
Convert 256 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64257314/20141022153359_MPRAGE_T1_COR_2 (256x256x256x1)
Conversion required 5.753881 seconds (4.780000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 176 DICOM file(s)
Convert 176 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64257314/20141022153359_T2-PREP_3D_SAG_1X1X1_3 (224x256x176x1)
Conversion required 3.649515 seconds (2.990000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 79 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Warning: Saving 79 DTI gradients. Validate vectors (image slice orientation not reported, e.g. 2001,100B).
Convert 79 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5002/ses-64257314/20141022153359_ep2d_diff_71b1000_8b0_4 (128x128x70x79)
Conversion required 24.888608 seconds (23.209999 for core code).

#####

Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 24 DICOM file(s)
Convert 24 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514/20141015170954_T2_SAGITTAL_2 (256x256x24x1)
Conversion required 0.480603 seconds (0.340000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 180 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 180 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514/20141015170954_RESTING_STATE_3 (64x64x32x180)
Conversion required 6.424282 seconds (5.510000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 205 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 205 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514/20141015170954_Stop_Signal_5 (128x128x31x205)
Conversion required 26.260904 seconds (23.879999 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 205 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 205 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514/20141015170954_Stop_Signal_7 (128x128x31x205)
Conversion required 25.361993 seconds (22.910000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 31 DICOM file(s)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 31 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514/20141015170954_T2_in_Plane_of_fMR_-23_DEG_8 (256x256x31x1)
Conversion required 0.837122 seconds (0.490000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 246 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 246 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514/20141015170954_MID_RUN_1_9 (64x64x32x246)
Conversion required 8.685194 seconds (7.370000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 246 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 246 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514/20141015170954_MID_RUN_2_10 (64x64x32x246)
Conversion required 9.301827 seconds (8.090000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 246 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Convert 246 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64657514/20141015170954_MID_RUN_3_11 (64x64x32x246)
Conversion required 8.986270 seconds (7.700000 for core code).

Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 256 DICOM file(s)
Convert 256 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64685714/20141022153359_MPRAGE_T1_COR_2 (256x256x256x1)
Conversion required 5.939008 seconds (4.880000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 176 DICOM file(s)
Convert 176 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64685714/20141022153359_T2-PREP_3D_SAG_1X1X1_3 (224x256x176x1)
Conversion required 3.674913 seconds (3.040000 for core code).
Compression will be faster with 'pigz' installed
Chris Rorden's dcm2niiX version v1.0.20180614 GCC4.9.2 (64-bit Linux)
Found 79 DICOM file(s)
slices stacked despite varying acquisition numbers (if this is not desired please recompile)
Warning: Weird CSA 'ProtocolSliceNumber' (System/Miscellaneous/ImageNumbering reversed): VALIDATE SLICETIMING AND BVECS
Warning: Saving 79 DTI gradients. Validate vectors (image slice orientation not reported, e.g. 2001,100B).
Convert 79 DICOM as /Shared/oleary/functional/UICL/BIDS/sub-5008/ses-64685714/20141022153359_ep2d_diff_71b1000_8b0_4 (128x128x70x79)
Conversion required 25.318525 seconds (22.000000 for core code).

