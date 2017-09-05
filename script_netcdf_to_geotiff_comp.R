############################################################
# My little big rasterbricks <3
# muylaert at unesp.rc.br
# CAUTION: Slow extraction
# Extract zonal statistics for BHALU data base on Land use in Brazil
# Database from Dias et al 2015 GBC
# Download of netcdf files in http://www.biosfera.dea.ufv.br/en-US/banco/uso-do-solo-agricola-no-brasil-1940-2012---dias-et-al-2016
############################################################

library(ncdf4)
library(raster)
library(sp)
require(rgdal)

ogrListLayers(workdir<-"F://__data//muylaert//___BASES//bahlu//")

setwd("F://__data//muylaert//___BASES//bahlu//")
workdir<-"F://__data//muylaert//___BASES//bahlu//"

files_list <- as.data.frame(dir(workdir,pattern="*.nc"))
p <- shapefile("malha_mun_15_wgs84.shp")
a <- 1
armazena <- NULL

	for(n in 4:nrow(files_list))
		#for(shp in shapefiles){	
		{
	name <- paste(workdir,gsub('.nc', '', files_list[n,1]), ".nc", sep="")
	nc <- nc_open(name)
	print(attributes(nc$var)$names)
	ncbrick <- brick(name, varname=attributes(nc$var)$names) #o brick é no name!		
		substrRight <- function(x, n){
  		substr(x, nchar(x)-n+1, nchar(x))	
				}
	nomedireita <- substrRight(name, 11) 	
	periodo <- substr(nomedireita, 1,8)
	ultimoano <-substrRight(periodo, 4)
	
		for(a in 1:length(names(ncbrick))){
		print(a)
		paste(ncbrick@data@names[a])
		ncyear<-subset(ncbrick, a)	#já é raster@
		#r[] <- 1:ncell(r)	
		#cada pixel tem 1 km x 1 km (100 hectares), e o valor do pixel é em ha, então é tantos ha/pixel
		#depois dividir o valor de v por 100, ignorando os NAS :D
		#v <- extract(r, p,  fun=mean) raster com valores errados :(
		#teste
		vt<-extract(ncyear, p, fun=mean, na.rm=TRUE, small=TRUE) #funciona!! mas gera alguns NA para pasto!
		vt<- round(vt,digits=3)
		d <- data.frame(id=rep(1:length(vt), sapply(vt, length)), value=unlist(vt))
		pd <- cbind(id=1:length(p), data.frame(p))
		m <- merge(pd, d)
		m$anocod<-rep(a, nrow(m))
		#rep(seq(begin,end, 1), each=12)
		#colnames(m$value)<- print(attributes(nc$var)$names)
		armazena<-rbind(armazena, m)
		rm(m)
		rm(ncyear)
		rm(vt)
		}
	
	print(files_list[n,1])
	aux<-as.character(files_list[n,1])
	nome.arq<- paste("zonal1_15_", substr(aux,1,nchar(aux)-3),".txt", sep="")
	print(nome.arq)
	colnames(armazena$value)<- paste(attributes(nc$var)$names, periodo, sep="")
	write.table(armazena, nome.arq,col.names=T)
	nome.arq<-  paste("zonal1_15_", substr(aux,1,nchar(aux)-3),".csv", sep="")
	write.csv(armazena, nome.arq, row.names=FALSE)
	rm(v)
	rm(nc)
	rm(armazena)
	armazena<-NULL
	#}
	

write.csv(armazena, nome.arq, row.names=FALSE)

###################################
