##### Calculate average number of positive cells per sample per channel #####

# Input data: output file (samples_all) from "clusters_analysis"
# Input file should be in "tables" folder

# The code will count a cell a "positive" when signal intensity is above 1

# Run each section at a time


#### 0. Load libraries ####

library(stringr) 
library(tidyverse)
library(readr)
library(stringr)
library("rqdatatable")
library(dplyr)
library(ggExtra)
library(gridExtra)
library(ggsignif)
library(naniar)


#### 1. Load data from previous analysis ####

setwd("~/Dropbox (The Francis Crick)/Alessia/Projects/UK DRI project/Image acquisitions/Image analysis/HistoCat analysis/R code")

samples_all <- read.csv("tables/samples_all.csv")

#### 2. Define the columns (# of channels) to consider for analysis ####

markers_number <- readline("How many markers are you analysing?") 

#### 3. Calculate average intensity of each channel per image/sample, plot and save ####

# change marker number to a numerical value
markers_number <- as.numeric(markers_number)

# calculate average of column intensity (per sample)
avg_int <- aggregate(samples_all[, 4:(markers_number + 3)], 
                     list(samples_all$sample_origin), mean)

# change name to first column
names(avg_int)[names(avg_int) == 'Group.1'] <- 'file_name'

# add two columns with sampleID and each replicate (taken from file_name)
avg_int$sampleID = str_extract(avg_int$file_name, "[^_]*_[^_]*")
avg_int$group = sub("_.*", "", avg_int$file_name)
avg_int$replicate = sub(".*_", "",avg_int$file_name)

# calculate average of column intensity (per group/sampleID)
avg_int_sample <- aggregate(avg_int[, 2:(markers_number + 1)], 
                            list(avg_int$sampleID), mean)

# change name to first column
names(avg_int_sample)[names(avg_int_sample) == 'Group.1'] <- 'file_name'

# add column with experimental group 
avg_int_sample$group = sub("_.*", "", avg_int_sample$file_name)

# save csv 
write_csv(avg_int,'tables/channel_intensity_avg_image.csv')
write_csv(avg_int_sample,'tables/channel_intensity_avg_sample.csv')

# reshape table to long for visualization
data_long_intensity <- 
  gather(avg_int_sample, 
         key ="cell_type", 
         value = "channel_intensity", 
         colnames(avg_int_sample[2:(markers_number+1)]))

# rename columns
colnames(data_long_intensity) <- paste0(c("SampleID", "Case", "Cell_type", "Pixel_intensity"))

# Generate plots for cell number/cluster/group
plot_intensity_sample <- ggplot(data = data_long_intensity,
                           aes(x = SampleID, 
                               y = Pixel_intensity,
                               fill = Case)) +
  geom_col() +
  facet_wrap(~Cell_type) +
  labs(title = "Channel intensity per sample", 
       x = "Sample ID", 
       y = "Pixel intensity")

# Print plot
pdf(paste0("plots/channel intensity per sample.pdf"))
print(plot_intensity_sample)
dev.off()


#### 4. Calculate total and average number of positive cells per sample, plot and save #####

# replace signal intensity values below 1 with N/A
positive_cells <- replace_with_na_if(samples_all[, 4:(markers_number + 3)], is.numeric, ~.x < 1)

# add few other informative columns
positive_cells$file_name <- samples_all$sample_origin
positive_cells$Y_position <- samples_all$Y_position
positive_cells$sampleID = str_extract(positive_cells$file_name, "[^_]*_[^_]*")
positive_cells$group = sub("_.*", "", positive_cells$file_name)
positive_cells$replicate = sub(".*_", "", positive_cells$file_name)

# calculate total number of positive cells per marker per sample
cell_number <- aggregate(. ~ file_name, positive_cells, 
                         FUN = function(x) sum(!is.na(x)), na.action = NULL)

# other option for keeping all columns and deciding signal intensity value
# cell_number_2 <- aggregate(. ~ file_name, df, FUN = function(x) sum(x>=1), na.action = NULL)

# add two columns with sampleID and replicate (taken from file_name)
cell_number$sampleID = str_extract(cell_number$file_name, "[^_]*_[^_]*")
cell_number$group = sub("_.*", "", cell_number$file_name)
cell_number$replicate = sub(".*_", "", cell_number$file_name)

# calculate average number of positive cells per marker per group
avg_cell_number <- aggregate(cell_number[, 2:(markers_number + 1)], 
                             list(cell_number$sampleID), mean)

# change name to first column
names(avg_cell_number)[names(avg_cell_number) == 'Group.1'] <- 'file_name'

# add column with experimental group 
avg_cell_number$group = sub("_.*", "", avg_cell_number$file_name)

# save csv 
write_csv(cell_number,'tables/positive_cell_per_image.csv')
write_csv(avg_cell_number,'tables/positive_cell_per_sample.csv')

# reshape table to long for visualization
data_long_cell <- 
  gather(avg_cell_number, 
         key ="cell_type", 
         value = "cell_number", 
         colnames(avg_cell_number[2:(markers_number+1)]))

# rename columns
colnames(data_long_cell) <- paste0(c("SampleID", "Case", "Cell_type", "Cell_number"))

# Generate plots for cell number/cluster/group
plot_cells_sample <- ggplot(data = data_long_cell,
                                aes(x = SampleID, 
                                    y = Cell_number,
                                    fill = Case)) +
  geom_col() +
  facet_wrap(~Cell_type) +
  labs(title = "Number of cell per sample", 
       x = "Sample ID", 
       y = "Pixel intensity")

# Print plot
pdf(paste0("plots/cell number per sample.pdf"))
print(plot_cells_sample)
dev.off()


#### 5. Calculate cell number normalized by cortex length (x1000), plot and save ####

# add max cortex length per sample
positive_cells <- positive_cells %>%
  group_by(file_name) %>%
  mutate(Y_position_max = max(Y_position)) %>%
  ungroup()

# calculate max cortex length of each sample
samples_max_y <- aggregate(positive_cells[,(markers_number + 6)], list(positive_cells$file_name), mean)

names(samples_max_y)[names(samples_max_y) == 'Group.1'] <- 'file_name'

# add max cortex length to table of average cell numbers
cell_number <- merge(cell_number, samples_max_y, by.x = 'file_name')

# calculate cell number normalized by total length of the cortex
cell_num_norm <- data.frame() 

e <- (markers_number + 6)

for (r in 1:nrow(cell_number)) {
  for (c in 2:(markers_number + 1)) {
    cell_num_norm[r,c-1] <- ((cell_number[r,c]/cell_number[r,(e)])*1000)
  }
}

# assign column and row names from previous data frame
cell_num_norm <- add_column(cell_num_norm, cell_number$file_name, .before = 'V1')
colnames(cell_num_norm)  <- colnames(cell_number[1:(markers_number+1)])

# add two columns with sampleID and tech replicate (taken from file_name)
cell_num_norm$sampleID = str_extract(cell_num_norm$file_name, "[^_]*_[^_]*")
cell_num_norm$group = sub("_.*", "", cell_num_norm$file_name)
cell_num_norm$replicate = sub(".*_", "", cell_num_norm$file_name)

# calculate average of column intensity (per sample)
cell_num_norm_avg <- aggregate(cell_num_norm[, 2:(markers_number + 1)], 
                               list(cell_num_norm$sampleID), mean)

# change name to first column
names(cell_num_norm_avg)[names(cell_num_norm_avg) == 'Group.1'] <- 'file_name'

# add column with experimental group (taken from first 2 letter of file_name)
cell_num_norm_avg$group = sub("_.*", "", cell_num_norm_avg$file_name)

# save csv 
write_csv(cell_num_norm,'tables/normalised_cell_number_image.csv')
write_csv(cell_num_norm_avg,'tables/normalised_cell_number_sample.csv')
write_csv(positive_cells,'tables/sample_all_cleared.csv')

# reshape table to long for visualization
data_long_cell_norm <- 
  gather(cell_num_norm_avg, 
         key ="cell_type", 
         value = "cell_number", 
         colnames(cell_num_norm_avg[2:(markers_number+1)]))

# rename columns
colnames(data_long_cell_norm) <- paste0(c("SampleID", "Case", "Cell_type", "Cell_number"))

# Generate plots for cell number/cluster/group
plot_cell_norm_sample <- ggplot(data = data_long_cell_norm,
                           aes(x = SampleID, 
                               y = Cell_number,
                               fill = Case)) +
  geom_col() +
  facet_wrap(~Cell_type) +
  labs(title = "Number of cells per sample, normalized by ROIs length", 
       x = "Sample ID", 
       y = "Number of cells")

# Print plot
pdf(paste0("plots/normalised cell number per sample.pdf"))
print(plot_cell_norm_sample)
dev.off()





