################################################################################################################################
# 
# Mosaic, Mapbiomas v2 land use time series for Brazil in R
#
#
# Renata Muylaert  
#
# Source of raster data: http://mapbiomas.org > Downloads
#	# Before running, remove .aux and .ogr files from workdir
#	
################################################################################################################################

# Clean objects and memory size, vanish with scinot, load package

rm(list = ls())
gc() 
options(digits=7, scipen=999)
memory.limit(size= 1.75e13)

library(raster)
library(rgdal)
library(sp) 
library(gdalUtils)

# Set begin and end of time series

years <- paste(2013:2016)

# Set dir where mapbiomas files were downloaded

workdir = "F://__data//muylaert//___BASES//"
setwd(workdir)

start.time <- Sys.time()

suppressPackageStartupMessages(library(rgdal)) 
i <- NULL
for(i in years)
	{
		
	files_list <- paste(dir(workdir, pattern=c(paste(i))))
	nome.arq.wgs84 <- paste("MAPBIOMAS_wgs84_",i,".tif", sep="")
	mosaic_rasters(gdalfile = files_list, dst_dataset = nome.arq.wgs84, of = "GTiff")
	print("Mosaicou")
	print(i)
	}
 	

#####################################################################################################

