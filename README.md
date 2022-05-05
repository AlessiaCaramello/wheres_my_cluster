# wheres_my_cluster

Hi everyone and thank you for your interest!

wheres_my_cluster is written to analyse .csv output files from HistoCat for quantifying total and average cell number for each cluster/channel in each ROIs/sample/group typically generated with immunofluorescence (IF), multiplexIF and Imaging Mass Cytometry (IMC) experiments.

## 1. Prepare csv. input files

- In HistoCat, select samples of interest in "Samples/Populations"
- Click Save -> "Export gates as CSV"
- Find exported .csv files in "custom_gates" folder
- Copy  exported .csv files in "input/samples/" R folder
- Rename each .csv file as: group_sampleID_replicate#.csv

**group** = indicate the group you want to compare (we will average by group, e.g. CTRL vs AD)

**sampleID** = string (number or letters) identifying the single sample in that group

**replicate** = consecutive number indicating the replicate experiment of that sample (we will average replicates for each sample/ROI first)  

*example: CTRL_1072_1.csv*

## 2. Calculate average number of cells per cluster per sample/ROI

- **INPUT FILES:** 
  - .csv files from HistoCat
- Run [1. number of cells per cluster per picture](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/1.%20number%20of%20cells%20per%20cluster%20per%20picture.R)
- When prompted with "Phenograph name" insert the Phenograph number assigned by HistoCat for the clustering 

*example: Phenograph532086026*
- **OUTPUT FILES:** 
  - *samples_all* (merged .csv file of all input .csv files)
  - *clusters_summary* (.csv file with average number of cells per cluster in each sample/ROI)
  - *cells per cluster per image* (plot of *clusters_summary*)

## 3. Plot distribution of cells in each cluster
- **INPUT FILES:** 
  - .*samples_all* from Step 1
- Run [2. number of cells per cluster per picture]

