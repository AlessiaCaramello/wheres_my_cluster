# Analysis of clusters cell number and distribution from HistoCat output files

Hi everyone and thank you for your interest!

**wheres_my_cluster** is a simple code for analysing .csv output files from HistoCat for quantifying total and average cell number for each cluster/channel in each ROIs/sample/group typically generated with immunofluorescence (IF), multiplexIF and Imaging Mass Cytometry (IMC) experiments. Clustering can be done on HistoCat with the Phenograph function, make sure to to do this before exporting .csv files. 

## Prepare csv. input files

- In HistoCat, select samples of interest in "Samples/Populations"
- Click Save -> "Export gates as CSV"
- Find exported .csv files in "custom_gates" folder
- Copy  exported .csv files in "input/samples/" R folder
- Rename each .csv file as: group_sampleID_replicate#.csv

**group** = indicate the group you want to compare (we will average by group, e.g. CTRL vs AD)

**sampleID** = string (number or letters) identifying the single sample in that group

**replicate** = consecutive number indicating the replicate experiment of that sample (we will average replicates for each image/ROI first)  

*example: CTRL_1072_1.csv*

## Calculate average number of cells per cluster per image/ROI

Based on cell clustering made in HistoCat (obtained with Phenograph function, remember to note down which Phenograph analysis you want to refer to), this code calculates the average number of cells in each cluster per image/ROI. 

- **INPUT FILES:** 
  - .csv files from HistoCat
- Run [1. number of cells per cluster per image](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/1.%20number%20of%20cells%20per%20cluster%20per%20image.R)
- When prompted with "Phenograph name" insert the Phenograph number assigned by HistoCat for the clustering 

*example: Phenograph532086026*
- **OUTPUT FILES:** 
  - *samples_all* (merged .csv file of all input .csv files)
  - *clusters_summary* (.csv file with average number of cells per cluster in each image/ROI)
  - *cells per cluster per image* (.pdf file with plot of *clusters_summary*)


## Calculate average number of cells per cluster per sample and per group 

- **INPUT FILES:** 
  - *samples_all* from Step 1 (in *tables* folder)
  - *clusters_summary* from Step 1 (in *tables* folder)
- Run [2. number of cells per cluster per sample and per group](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/2.%20number%20of%20cells%20per%20cluster%20per%20sample%20and%20per%20group.R)
- **OUTPUT FILES:**
  - *average_cells_per_cluster* (.csv file with average number of cell per cluster per sample)
  - *cells per cluster per sample* (.pdf file with plot of *average_cells_per_cluster*)
  - *cells per cluster per group* (.pdf file with plot of average cell per group)


## Plot distribution of cells in each cluster

This code will plot the distribution on the Y axis, of all cells automatically detected with HistoCat (this is based on their Y_position, you can change to X_position in line 28), regardless of their image or sample origin.

- **INPUT FILES:** 
  - *samples_all* from Step 1 (in *tables* folder)
- Run [3. clusters distribution](https://github.com/AlessiaCaramello/wheres_my_cluster/blob/main/3.%20clusters%20distribution.R)
- **OUTPUT FILES:**
  - *clusters distribution* (.pdf file with plot of cells ditribution along the y axis of the image/ROI)


