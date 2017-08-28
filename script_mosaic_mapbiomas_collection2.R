################################################################################################################################
# 
# Mosaic, reproject and reclass Mapbiomas v2 land use time series for Brazil in R
#
# Get Native forest and forestry from original raster of land use
#
# Renata Muylaert  
#
# Source of raster data: http://mapbiomas.org > Downloads
#
################################################################################################################################

##### First part
# Load packages
# Set timer
# Increase memory space
# Load raster list in loop
# Reclass
# Set resolution
# Export classified raster files 

# Clean objects and memory size, vanish with scinot

rm(list = ls())
gc() 
options(digits=7, scipen=999)
memory.limit(size= 1.75e13)

library(raster)
library(rgdal)
library(sp) 
library(gdalUtils)

# Set begin and end of time series

years<-paste(2000:2016)

# Set dir where mapbiomas files were downloaded

workdir = "F://__data//muylaert//___BASES//"
setwd(workdir)

start.time <- Sys.time()
dir.create("outputs")

for(i in years)
	{
		
	# Before running, remove .aux and .ogr files from workdir
	# Finding a pattern

	files_list<-paste(dir(workdir,pattern=c(paste(i))))
	
	nome.arq.wgs84<-paste("MAPBIOMAS_wgs84_",i,".tif", sep="")
	
	r<- c()
	r <- mosaic_rasters(gdalfile = files_list, dst_dataset = nome.arq.wgs84, of = "GTiff")
	# Exporting the mosaic raster
	 
	writeRaster(r, filename = nome.arq, format="GTiff",overwrite=T)
	
	alb <- "+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs" 

	ropen<- raster(nome.arq.wgs84)

	plot(ropen)	
	
	# Requires a lot of power to reproject the total land use mosaic, so go careful
	# Number of cells for 30 m resolution raster: 24263091385 cells!
	# ralb <- projectRaster(ropen, crs = alb,  res = 600 )
	# nome.arq<-paste("MAPBIOMAS_albers",i,".tif", sep="")
	# writeRaster(ralb, filename = nome.arq, format="GTiff",overwrite=T)
	# ralb<- raster(nome.arq)
	# end.time <- Sys.time()
	# time.taken <- end.time - start.time
	# time.taken
	# print(c("Time taken to reproject the year of", i,"was", round(time.taken), "minutes"))

	#Reclass

	ralb[ralb<5] <- NA
	forest <- c()
	forest <- ropen
	forest[forest  > 8] <- 0
	forest[forest != 0] <- 1
	start.time <- Sys.time()
	forest.alb <- projectRaster(forest, crs = alb,  res = 600 )
	
	nome.arq.for <-paste("mapbiomas_forest_albers_",i,".tif", sep="")
	writeRaster(forest.alb, filename = nome.arq.for, format="GTiff", overwrite=T)
	
	end.time <- Sys.time()
	time.taken <- end.time - start.time
	time.taken
	print(c("Time taken to reproject forest the year of", i,"was", round(time.taken), "minutes"))

	start.time <- Sys.time()
	#ralb[ ]<- if(ralb != 1:8, 1, 0)
	print(i)
	
	euca<- c()
	euca<- ralb
	euca[euca != 9] <- 0
	euca[euca == 9] <- 1

	euca.alb <- projectRaster(euca.alb, crs = alb,  res = 600 )
	nome.arq.euca<-paste("mapbiomas_euca_albers_",i,".tif", sep="")
	writeRaster(euca.alb, filename = nome.arq.euca, format="GTiff",overwrite=T)
	
	end.time <- Sys.time()
	time.taken <- end.time - start.time
	print(c("Time taken to reclass and reproject EUCA the year of", i,"was", round(time.taken), "minutes"))
	time.taken
	print(i)

	}

#####################################################################################################
