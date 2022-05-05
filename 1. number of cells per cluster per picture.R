##### Calculate number of cells per cluster per picture #####


### Input data: HistoCat .csv files of samples 


### How to get .csv files from HistoCat: 
# 1. select samples of interest in "Samples/Populations"
# 2. click Save -> "Export gates as CSV"
# 3. find exported .csv files in "custom_gates" folder
# 4. copy  exported .csv files in "input/samples/" R folder
# 5. rename each .csv file as: group_sampleID_replicate#.csv
#    group = indicate the group you want to compare 
#            (we will average by group, e.g. CTRL vs AD)
#    sampleID = string (number or letters) identifying the single sample in that group
#    replicate = consecutive number indicating the replicate experiment of that sample
#                (we will average replicates for each sample first)  
#
#    example: CTRL_1072_1.csv


### Run each section at a time


#### 0. Load libraries ####

install.packages("tidyverse")
library(tidyverse)
library(gridExtra)

####  1. Pick phenograph to analyse  ####

# Pick which phenograph experiment to analyse
phenograph <- readline("Phenograph name?")  

####  2. Create dataframes from csv files and create a sample summary table  ####

# set working directory
# setwd("~/Dropbox (The Francis Crick)/Alessia/Projects/UK DRI project/Image acquisitions/Image analysis/HistoCat analysis/R code")

csv_to_df_samples <- function(){
  filelist = list.files(path = "input/samples",  pattern = ".csv") # Identify input files
  result <- data.frame() # create a dataframe to store results
  samples_info <- data.frame() # create a dataframe to store samples info
  
  for (i in 1:length(filelist)){ #Loop through the files 
    input <- filelist[i] # Extract file to work on
    print(paste("Processing file:", input)) # Show file being processed
    data = read.csv(paste0(file.path(("input/samples"), input)))   # make data frame from csv file
    
    # change phenograph column name 
    colnames(data)[which(colnames(data)==phenograph)] <- "Cluster_assigned"
    
    # save info in a summary table
    sample_name <- gsub(".csv", "", input)
    
    # add column with sample name
    samples_info[i,1] <- paste0(sample_name) 
    
    # add column with number of clusters in that sample
    clusters_in_sample <- length(unique(data$Cluster_assigned))
    samples_info[i,2] <- paste0(clusters_in_sample) 
    
    # add column with number of cells in that sample
    samples_info[i,3] <- paste0(nrow(data))
    
    # add column with name of sample of origin
    data['sample_origin'] <- paste0(sample_name)
    
    # create dataframe for each sample to hold results
    dfname <- paste0(sample_name) # define dataframe name from sample origin name
    assign(paste(dfname),data) # create a data frame to hold results
    
    # append current sample to result dataframe of all samples analysed
    result <- bind_rows(result, data)
  }
  
  # change name of samples_info column
  colnames(samples_info) <- paste0(c("Sample", "Clusters_in_sample", "Cells_in_sample"))
  
  # calculate number of cells per cluster per sample
  cells_per_cluster = data.frame(table(result$Cluster_assigned, result$sample_origin)) # use for ggplot
  
  colnames(cells_per_cluster) <- paste0(c("Cluster", "Sample", "Cells"))
  
  # reshape table to wide
  cells_per_cluster_wide = reshape(cells_per_cluster, idvar = "Sample", timevar = "Cluster", direction = "wide") 
  
  # rename table columns with clusters name
  tot_clusters <- (ncol(cells_per_cluster_wide)-1)
  colnames(cells_per_cluster_wide) <- c("Sample", paste0("Cluster_", 1:tot_clusters))
  
  # merge with samples_info
  samples_info <- merge(samples_info, cells_per_cluster_wide, by.x = "Sample", by.y = "Sample", all.x = TRUE, all.y = FALSE)
  
  # Save dataframes for later use
  samples_summary <<- samples_info
  samples_all <<- result
  for_plotting <<- cells_per_cluster
}

csv_to_df_samples()

# Save summary table 
pdf(paste0("tables/samples summary.pdf"))
print(samples_summary)
dev.off()

write_csv(samples_summary, paste0("tables/clusters_summary.csv"))
write_csv(samples_all, paste0("tables/samples_all.csv"))


####  3. Plot results  ####

plot_cells_cluster_samples <- function(){
  
  # Generate plots for cell number/cluster/sample
  plot <- ggplot(data = for_plotting,
                 aes(x = Sample, 
                     y = Cells,
                     fill = Sample)) +
    geom_col() +
    facet_wrap(~Cluster) +
    labs(title = "Number of cells per cluster per sample", 
         x = "Sample ID", 
         y = "Number of cells")
  
  # Print plot
  pdf(paste0("plots/cells per cluster per image.pdf"))
  print(plot)
  dev.off()
  
}

plot_cells_cluster_samples()





