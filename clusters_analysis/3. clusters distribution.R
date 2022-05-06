##### Analysis of clusters distribution in the cortex #####


### Input data: output files from "1. number of cells per cluster per sample":

# samples_all = samples_all.csv

# Input file should be in "tables" folder



##### 0. Load libraries #####

install.packages("tidyverse")
library(tidyverse)
library(gridExtra)


#### 1. Load data from previous analysis ####

samples_all <- read.csv("tables/samples_all.csv")

#### 2. Plot distribution of clusters ####

make_plots <- function(){
  
  # create a directory for saving pdf files
  
  dir.create("plots")
  
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
  
  plot
  
  pdf(paste0("plots/clusters distribution.pdf"))
  print(plot)
  dev.off()
  
}

make_plots()








