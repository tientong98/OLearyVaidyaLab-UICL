import json
import pydicom
import os
import glob
import numpy as np
import pandas as pd
import sys


def main():
    """
    Function to get the slice timing of scans from GE scanner.
    Usage: python get_slice_time.py "path_to_dicom_pattern" "output_path"
    E.g.: python get_slice_time.py "/Shared/oleary/functional/UICL/dicomdata/3040/63910816/FMRI_004/63910816_004_*" "/Shared/oleary/functional/UICL/BIDS/code/time2/"
    """
    
    bold_pattern = sys.argv[1]
    output_path = sys.argv[2]   
    bold = sorted(glob.glob(bold_pattern))
    outpath = output_path

    slicetime = []
    for img in bold:
        ds = pydicom.dcmread(img)
        slicetime.append([ds[0x0020, 0x0013].value, ds[0x0020,0x1041].value, ds[0x0021, 0x105e].value])

    slicetime_df = pd.DataFrame.from_records(slicetime)
    final = slicetime_df[slicetime_df[2] < 2].sort_values(by=[1], ascending=False)

    outputlist =[]
    final.columns = ['img number', 'slice location', 'Slice Timing']
    for time in final['Slice Timing']:
        outputlist.append(time)
        

    with open(outpath + 'SliceTiming.json', "w") as write_file:
        json.dump({'SliceTiming': outputlist}, write_file)

if __name__ == '__main__':
    main()
