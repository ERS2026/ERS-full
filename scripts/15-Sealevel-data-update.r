# Script to update the sealevel data from the Schiermonnikoog tidal gauge
# data can be downloaded from https://waterinfo.rws.nl/
# To update the file with recent data 
# download the most recent data for the Schiermonnikoog station and use the following script to format the data as in the database: 
# use 'download historische data' at the website and use 'waterhoogte in oppervlaktewater ten opzichte van Normaal Amsterdams Peil in cm'

library(tidyverse)
newdat<-read_csv2("C:/Users/holff/Downloads/20260830-13879/20260830-13879.csv") |>
  dplyr::select(WAARNEMINGDATUM, WAARNEMINGTIJD, ALFANUMERIEKEWAARDE) |>
  as_tibble()
newdat2<- newdat |>
     dplyr::mutate(datetime=as.POSIXct(paste(WAARNEMINGDATUM, WAARNEMINGTIJD), format = "%d-%m-%Y %H:%M"),
                    sealevel=as.numeric(ALFANUMERIEKEWAARDE)) |>
     dplyr::select(datetime,sealevel) 
newdat2
write_csv(newdat2, "C:/Users/holff/Downloads/20260830-13879/waterlevel2026.csv")
# append the new data to the existing database. 

