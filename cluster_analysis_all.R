####  Calculate number of cells per cluster per picture #####


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


####  0. Load libraries ####

install.packages("tidyverse")
library(stringr) 
library(tidyverse)
library(plyr)
library(readr)
library(stringr)
library("rqdatatable")
library(dplyr)
library(ggplot2)
library(ggExtra)
library(gridExtra)
library(ggsignif)
library(ggpubr)
library(naniar)
library(data.table)

####  1. Pick phenograph to analyse  ####

# Pick which phenograph experiment to analyse
phenograph <- readline("Phenograph to use?")  

####  2. Import and bind .csv files, calculate average number of cell per cluster (per image/ROI), plot and save  ####

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
  clusters_summary <<- samples_info
  samples_all <<- result
  for_plotting <<- cells_per_cluster
}

csv_to_df_samples()

# Save summary table 
write_csv(clusters_summary, paste0("tables/clusters_summary.csv"))
write_csv(samples_all, paste0("tables/samples_all.csv"))


# Generate plots for cell number/cluster/sample
plot <- ggplot(data = for_plotting,
               aes(x = Sample, 
                   y = Cells,
                   fill = Sample)) +
  geom_col() +
  facet_wrap(~Cluster) +
  labs(title = "Number of cells per cluster per image", 
       x = "Sample ID", 
       y = "Number of cells")

# Print plot
pdf(paste0("plots/cells per cluster per image.pdf"))
print(plot)
dev.off()


####  3. Calculate average number of cell per cluster (per sample), plot and save ####

# Test quantification is correct
sum(clusters_summary[1,4:ncol(clusters_summary)]) == clusters_summary[1, 3]

# Calculate number of clusters identified
cluster_number <- (ncol(clusters_summary)-3)

# add two columns with sampleID and each replicate (taken from file_name)
clusters_summary$sampleID = str_extract(clusters_summary$Sample, "[^_]*_[^_]*")
clusters_summary$group = sub("_.*", "", clusters_summary$Sample)
clusters_summary$replicate = sub(".*_", "", clusters_summary$Sample)

# calculate average cells per sample
clusters_avg <- aggregate(clusters_summary[, 4:(cluster_number + 3)], 
                          list(clusters_summary$sampleID), mean)

names(clusters_avg)[names(clusters_avg) == 'Group.1'] <- 'Sample'

# reshape table to long
clusters_avg_long <- melt(setDT(clusters_avg), id.vars = "Sample", variable.names = "cells")

# rename columns
colnames(clusters_avg_long) <- paste0(c("Sample", "Cluster", "Cells"))

# Generate plots for cell number/cluster/sample
plot_samples <- ggplot(data = clusters_avg_long,
                       aes(x = Sample, 
                           y = Cells,
                           fill = Sample)) +
  geom_col() +
  facet_wrap(~Cluster) +
  labs(title = "Number of cells per cluster per sample", 
       x = "Sample ID", 
       y = "Number of cells")

# Print plot
pdf(paste0("plots/cells per cluster per sample.pdf"))
print(plot_samples)
dev.off()

# Save data
write_csv(clusters_avg, paste0("tables/average_cells_per_cluster.csv"))


####  4. Calculate average number of cell per cluster (per group), plot and save ####

# add column with group 
clusters_avg$group = sub("_.*", "", clusters_avg$Sample)

# calculate average cells per group
clusters_avg_group <- aggregate(clusters_avg[, 2:(cluster_number + 1)], 
                                list(clusters_avg$group), mean)

# reshape table to long
clusters_avg_group_long <- melt(setDT(clusters_avg_group), id.vars = "Group.1", variable.names = "Cells")

# rename columns
colnames(clusters_avg_group_long) <- paste0(c("Sample", "Cluster", "Cells"))


# Generate plots for cell number/cluster/group
plot_group <- ggplot(data = clusters_avg_group_long,
                     aes(x = Sample, 
                         y = Cells,
                         fill = Sample)) +
  geom_col() +
  facet_wrap(~Cluster) +
  labs(title = "Number of cells per cluster per group", 
       x = "Sample ID", 
       y = "Number of cells")

# Print plot
pdf(paste0("plots/cells per cluster per group.pdf"))
print(plot_group)
dev.off()

####  5. Plot distribution of clusters ####

# Plot clusters
  plot <- ggplot(data = samples_all, 
                 mapping = aes(x = Y_position),
                 fill = Cluster_assigned) +
    labs(title = "Distibution of cells along the cortex", 
         x = "Distance from bottom of the cortex (um)", 
         y = "no. of cells") +
    geom_histogram(binwidth = 50, 
                   alpha = 0.6) +
    coord_flip() +
    scale_x_reverse() +
    facet_wrap(~Cluster_assigned)

  
  pdf(paste0("plots/clusters distribution.pdf"))
  print(plot)
  dev.off()
  
