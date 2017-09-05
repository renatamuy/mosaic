################################################################
# Zonal statistics for CHIRPS temporal series
# Pluviosity data (mean, range)
# Before running, remove .aux and .ogr files from dir
# Renata Muylaert
# renatamuy at gmail.com
#################################################################

################################################################
library(raster)
library(rgdal)
library(sp) 
library(maptools)
################################################################

rm(list=ls())
setwd("F:/__data/muylaert/___BASES/CHIRPS_outputs")
dir<- "F:/__data/muylaert/___BASES/CHIRPS_outputs"

anos<-paste(1993:2014)
armazena <- NULL
pattern<- c("mean", "ampl")
lista<- list.files(path= dir, pattern=c("shp"))

for (shapes in lista){
	for(i in anos)
	for (p in pattern){
      	print(i)
		print(p)
    		files  <- list.files(path= dir, pattern=c(i,"tif"))
      
		myraster <- raster(grep(p, files, value=TRUE))
      	mun <- shapefile(shapes)
      	mun@data$FIDR<- c(1:nrow(mun@data))
     
		mun.r <- raster(extent(myraster))
		res(mun.r) <- res(myraster)[1]
		crs(mun.r) <- crs(myraster)

		mun.r <- rasterize(mun, mun.r, field = "FIDR")
     		zonal.mun <- zonal(myraster, mun.r, "mean")

      	nomecol<- paste(p)
      	#identify ID column
     		colnames(zonal.mun) <- c("FIDR", nomecol)
      
     		mun.merge <- mun
      	mun.merge@data <- merge(mun@data, zonal.mun, by = "FIDR")
      
      	linhas<- mun.merge@data 
		linhas$ano<- i
      	armazena<- rbind(armazena, linhas)  
      	
    		}
  	substrRight <- function(x, n){
    	substr(x, nchar(x)-n+1, nchar(x))	
  			}
  	shapeinfo<-substrRight(shapes, 9) 	
  	nome.arq <- paste(shapeinfo,"_CHIRPS", p , ".csv", sep="")
  	write.csv(armazena, nome.arq)
	armazena<- NULL  
	}

# Remember to apply a mean function later using municipality code, since one municipality can have more than one polygon in shapefile
##################################################################################################################################### 
