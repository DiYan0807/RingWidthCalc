# RingWidthCalc
Identify Z-ring or other ring like structure from rod-shape bacteria and calculate their width.

# mainScript
This is the main script to identify the Zring peaks and calculate the ring width
The input of the script :
XXX.mat is a structure from MicrobeJ containing multiple cells' fluorescence intensity scan profile along their long axis.
The output is:
one result is automatically saved in the same structure with All_Data variable (containing cell index, file index, ring width, intensity peak height, peak location, and cell length).
The other is the images of the cell and intensity profile are saved to a tiff file.
Parameters to adjust:
minP: Threshold for minimum peak intensity, used for findpeaks(Intensity_pass,'MinPeakHeight',minP ,...)
D: Threshold of the minimum distance between two rings, used for zringpeakfinder(Intensity_pass,minP,D); in pixel
fpass: Threshold for the highpass filter, used for highpass(Intensity_final,fpass,1,'steepness',0.95);

## Request
  1. Cell segmentation software [Cellpose 2.0] (https://github.com/MouseLand/cellpose).
  2. Cell intensity profiles along the long aixs using imageJ plugin [MicrobeJ] (https://www.microbej.com/download-2/).
  3. Require Matlab 2020a or newer for some functions in the GUI.
  4. Bright field (or PhaseContrast) images of bacteria cells are required for cell segmentation.

 # How to use
 **Step 1:** User opens a phase-contrast image in cellpose 2.0 and segmentate the cells, the result should be saved as xxx_cp_outlines.txt (how to use cellpose 2.0 refers to https://github.com/MouseLand/cellpose).
 **Step 2:** Cell outlines segmented by Cellpose 2.0 were converted to binary masks using the Mask from roi(s) function in Fiji. Then, the midlines along the long axis of each cell were determined using Microbe J (how to use MicrobeJ refers to https://www.microbej.com/). The result should be saved as xxx.mat.
 **Step 3:** Open mainScript.m in MATLAB and run it.Select the data from MicrobeJ, and the ring width will be calculated.
 **Step 4:** According to the images from step 3, choose the well defined rings and delete the bad ones.

 # How to cite
[![DOI](    )

# License
See [license](   ) file
