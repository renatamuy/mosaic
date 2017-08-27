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

library(raster)
library(rgdal)
library(sp) 
library(gdalUtils)

##### First part
# Load packages
# Set timer
# Increase memory space
# Load raster list in loop
# Reclass
# Set resolution
# Export raster files 

#Set begin and end of time series

anos<-paste(2000:2016)

#Set dir where mapbiomas files were downloaded

workdir = "F://__data//muylaert//___BASES//"
setwd(workdir)

start.time <- Sys.time()
dir.create("outputs")
memory.limit(size= 1.75e13)

for(i in anos)
	{
		
	#Before running, remove .aux and .ogr files from workdir
	
	files_list <- paste(dir(workdir,pattern=c(paste(i))))
	
	nome.arq<-paste("MAPBIOMAS_wgs84_",i,".tif", sep="")
	
	r <- mosaic_rasters(gdalfile = files_list, dst_dataset = nome.arq, of = "GTiff")
	
	#Reproject

	alb <- "+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs" 
	   
	ropen <- raster ( nome.arq )
	
	setwd(paste(workdir,"outputs//", sep=""))

	ralb <- projectRaster(ropen, crs = alb,  res=10000)

	nome.arq<-paste("MAPBIOMAS_albers_",i,".tif", sep="")
	
	writeRaster(ralb, filename = nome.arq, format="GTiff", overwrite=T)
		
	end.time <- Sys.time()
	
	time.taken <- end.time - start.time
	
	print(c("Time taken to reproject the year of", i,"was", time.taken))
	
	#Reclass in native forest and forestry independent rasters 

	ralb[ralb<5] <- NA
	
	for <- ralb
	for[for  > 8] <- 0
	for[for != 0] <- 1

	nome.arq.for <-paste("mapbiomas_forest_",i,".txt", sep="")
	writeRaster(for, filename = nome.arq.for, format="GTiff",overwrite=T)
	
	euca <- ralb
	euca[euca != 9] <- 0
	euca[euca == 9] <- 1
	
	nome.arq.euca <- paste("mapbiomas_euca_",i,".txt", sep="")
	writeRaster(euca, filename = nome.arq.euca, format="GTiff",overwrite=T)
	
	setwd(workdir)
	
	rm(ropen)
	rm(ralb)
	rm(for)
	rm(euca)
	print(i)

	}

#####################################################################################################

