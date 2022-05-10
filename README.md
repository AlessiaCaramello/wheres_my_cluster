# Analysis of clusters and channels cell number and distribution from HistoCat output files

## Introduction

Hi everyone and thank you for your interest!

**wheres_my_cluster** is a simple code for analysing .csv output files from HistoCat, typically generated from immunofluorescence (IF), multiplexIF and Imaging Mass Cytometry (IMC) experiments. 

**wheres_my_cluster** quantifies total and average cell number for clusters ([clusters_analysis](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/scripts/clusters_analysis.R)) and channels ([channels_analysis](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/scripts/channels_analysis.R)) separately, averaging for ROIs/sample/group. Cell clustering is done with HistoCat using the Phenograph function, so make sure to to do this before exporting .csv files and note down the Phenograph number to use for the analysis. 

**wheres_my_cluster** will also plot the distribution of cells in each cluster (regardless of group origin) on X or Y axis.


## Prepare csv. input files

- In HistoCat, select samples of interest in "Samples/Populations"
- Click Save -> "Export gates as CSV"
- Find exported .csv files in "custom_gates" folder
- Copy  exported .csv files in "input/samples/" R folder
- Rename each .csv file as: group_sampleID_replicate#.csv

**group** = indicate the group you want to compare (e.g. CTRL vs TREATED)

**sampleID** = string (number or letters) identifying the single sample in each group

**replicate** = consecutive number indicating the replicate experiment of that sample (we will average replicates for each image/ROI first)  

*example: CTRL_1072_1.csv*

## Calculate average number of cells per cluster per image/sample/group and cell ditribution

Based on cell clustering made with HistoCat Phenograph function, this code first calculates the average number of cells in each cluster per image, then averagaring per sample and per group. Lastly, the code will also produce a plot of cell ditribution on the Y axis, regardless of their image or sample origin. This is based on their Y_position, which can be changed to X_position in section 5., line 219), 

- **INPUT FILES:** 
  - .csv files from HistoCat
- Run [clusters_analysis](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/scripts/clusters_analysis.R)
- When prompted with "Phenograph name" insert the Phenograph number assigned by HistoCat for the clustering 

*example: Phenograph532086026*
- **OUTPUT TABLES:** 
  - *samples_all* (merged .csv input files)
  - *clusters_summary* (.csv file with total clusters and cells per sample, average cells per cluster in each image)
  - *average_cells_per_cluster* (.csv file with average number of cell per cluster per sample)
- **OUTPUT PLOTS:** 
  - *cells per cluster per image* (.pdf file, average cell number per image, from *clusters_summary*)
  - *cells per cluster per sample* (.pdf file, average cell number per sample, from *average_cells_per_cluster*)
  - *cells per cluster per group* (.pdf file, average cell per group)
  - *clusters distribution* (.pdf file, ditribution along the y axis of the image/ROI)


## Calculate channels intensity and average number of positive cells per channel per image/sample/group

Based on the channel intensity in each identified cell, this code will calculate the intensity of each channel, number of positive cells per channel  both total and normalised for image/ROIs length, averaged for each image/sample. Cells are considered positive when their pixel intensity is above zero, this can be changed to any other value in the code. Normalization by ROIs length is then multipled by 1000, for having bigger numbers.

- **INPUT FILES:** 
  - *samples_all* (output table from [clusters_analysis](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/scripts/clusters_analysis.R))

- Run [channels_analysis](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/scripts/channels_analysis.R)
- When prompted, indicate the number of channels to analyse (e.g. 14)

- **OUTPUT TABLES:** 
  - *channel_intensity_avg_image* (.csv file with average pixel intensity per image)
  - *channel_intensity_avg_sample* (.csv file with average pixel intensity per sample)
  - *positive_cell_per_image* (.csv file with total number of cell type per image)
  - *positive_cell_per_sample* (.csv file with average number of cell type per sample)
  - *normalised_cell_number_image* (. csv file with average number of cell types per sample, normalised by ROIs length)
  - *normalised_cell_number_sample* (. csv file with average number of cell types per image, normalised by ROIs length)
  - *sample_all_cleared* (.csv file with channels intesity with 0 values replaced with N/A, Y_position and max_Y_position, file_name, sampleID, group and replicate indicated)

- **OUTPUT PLOTS:** 
  - *channel intensity per sample* (.pdf file, pixel intesity per channel per sample)
  - *cell number per sample* (.pdf file, average number of cell types per sample)
  - *normalised cell number per sample* (.pdf file, average number of cell types per sample, normalised by ROIs length)

