##### Calculate average number of cells per cluster per sample and per group #####


### Input data: output file from "1. number of cells per cluster per picture" - soft code - HistoCat"

# samples_summary = clusters_summary.csv
# samples_all = samples_all.csv
#
# all files should be in "table" in R code folder


### Run each section at a time


##### 0. Load libraries #####

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

##### 1. Load data ####

# set working directory
# setwd("~/Dropbox (The Francis Crick)/Alessia/Projects/UK DRI project/Image acquisitions/Image analysis/HistoCat analysis/R code")

# load data set
clusters_summary <- read_csv('tables/clusters_summary.csv')
samples_all <- read_csv('tables/samples_all.csv')


##### 2. Calculate average of column intensity (per sample), plot and save ####

# Test quantification is correct
sum(clusters_summary[1,4:ncol(clusters_summary)]) == clusters_summary[1, 3]

# Calculate number of clusters identified
cluster_number <- (ncol(clusters_summary)-3)

# add two columns with sampleID and each replicate (taken from file_name)
clusters_summary$replicate = str_sub(clusters_summary$Sample, -1, -1)
clusters_summary$sampleID = str_sub(clusters_summary$Sample, 1, -3)
clusters_summary$group = str_sub(clusters_summary$Sample, 1, 2)

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


##### 3. Calculate average of column intensity (per group), plot and save ####

# add column with group 
clusters_avg$group = str_sub(clusters_avg$Sample, 1, 2)

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
  labs(title = "Number of cells per cluster per sample", 
       x = "Sample ID", 
       y = "Number of cells")

plot_group

# Print plot
pdf(paste0("plots/cells per cluster per group.pdf"))
print(plot_group)
dev.off()


