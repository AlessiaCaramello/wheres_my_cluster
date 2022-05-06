# Analysis of clusters and channels cell number and distribution from HistoCat output files

## Introduction

Hi everyone and thank you for your interest!

**wheres_my_cluster** is a simple code for analysing .csv output files from HistoCat, typically generated from immunofluorescence (IF), multiplexIF and Imaging Mass Cytometry (IMC) experiments. 

**wheres_my_cluster** quantifies total and average cell number for all clusters ([clusters_analysis](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/scripts/cluster_analysis.R)) and channels ([channels_analysis](link)) separately, averaging for ROIs/sample/group. Cell clustering is done with HistoCat using the Phenograph function, so make sure to to do this before exporting .csv files and note down the Phenograph number to use for the analysis. 

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
- Run ([clusters_analysis](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/scripts/cluster_analysis.R))
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


