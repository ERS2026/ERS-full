# 01 Header ------------------------------------------------------
# title: "03-organizing and importing data.R"
# author: "Han Olff"
# date: "2025-8-22"
# description: "How to import data into R from different sources, including local files and online databases."
# input: "No input files, but the script reads data from an online Google Sheets database"
# output: "No output files, but the script produces some plots"


# 02 Setup your environment -----------------------------------------------------
# Run the common setup script and synchronize the local project with GitHub.
# ------------------------------------------------------------------------------

# Run the setup script containing package restoration, helper functions, etc.
source(here::here("scripts", "01-setup.R"))

# Pull changes from the online repository into this local project folder.
# This is especially important when collaborating on the same project.
system2("git",c("-C", here::here(), "pull"))

# show which package namespaces are loaded to memory with library()
search()

# authenticate your @student.rug.nl google account
gsheets_auth()


# 03 Different ways to enter data ----------------
# Data can be imported in different ways in R:\
# 1. entering data directly in your script\
# 2. reading data from a .csv or .xlsx file from your local computer or online source\
# 3. reading data from a published csv link in a Google Sheets database\
#  We will mostly use the last method during this course. When reading data, we prefer the readr::read_csv()
# function, as it reads data directly into a tibble instead of a dataframe. A tibble is more compact when printed # and shows the variable types directly.


# 04 Method 1 - enter data directly in your script  ----------------
# This is only practical for small datasets, but not for large datasets.
# we did this already in the previous scripts 

# 05 Method 2 - read data from a local file ----------------
# If you want to read a file from a drive from your computer, 
# it is a good idea to set a working directory to point where your different datasets are located
EVI2001_2023 <- readr::read_csv(
  here::here("data", "EVI2001_2023.csv")
)
print(EVI2001_2023)
# This reads the file EVI2001_2023.csv from the folder data on my local folder  
# although it is synchronized through git/github, that is only possible for small files
# and also it lacks all kind of metadata, it is a loose file, not a database
# also it is not a good idea to keep data outside the git folder, as then we are not sure we work on the same data

# 06 Method 3 - read data from an online database -------------------------------
# This is the hihgly recommended choice of these three methods. 
# in this case the data are in one online database, in our course mostly a Google Sheets database.
# This means that there is only one version of the data, and all collaborators read the same data.
# This is the preferred method for collaborative projects, and also for your own projects.
# Google Sheets is a Spreadsheet app, similar to Microsoft Excel. But Google Sheets files "live" in the cloud
# associated with your Google account. A spreadsheet app is formally not a database app.
# But a Google Sheets document can be set up quite well as a 'lightweight' relational database. 
# When done well according to a couple of clear principles (as described here),
# A handy feature is that Google Sheets can  be set up to "publish" online tables (=sheets) as a .CSV (Comma
# Separated Values ascii text) file, that can be directly read into R. 
# For this use in Google Sheets menu File/ Share / Publish to web, choose the sheet to publish and as type
# choose Comma-separated values. This produces a link, that you put in your R script to read that datafile.
# This comes with large benefits of managing the data in one place in a relational database. 
# It is best practice to give the dataframe that you read in R the same name as the online table (sheet).
# In this way, data can be read on any computer, and multiple computers can read the same datafile.
# That is what you want in a collaborative project.

# 07 Introduction example online database ----------------
# We explore this  with this example database  - open in your browser with crtl + click :
# https://docs.google.com/spreadsheets/d/1m-liu8omZMewqz_YP9j_YUmQ0zwATl3z4aRLnZFnfWc/edit?usp=sharing

# This is a Google Sheets database that only exists in one location in the cloud.
# so all of us view the same database - there is only one version of the data
# It is a relational database, with multiple tables (sheets) that are linked to each other.
# The database is set up as a Star Schema, which is a particular way of organising data in a relational database.
# The database contains data on a study on the effects of wildlife on vegetation in East Africa.
# The database contains the following tables (sheets):
# - MetStudyInfo: short descriptions of the key features of your study
# - MetStill2Do: list of what you still need to do, your ToDo list for the database
# - MetTables: the list of tables (sheets) in your database, with for each table a short contents description
# - DimTransect: the list of transects in the study, with their properties
# - DimPlot: the list of plots in the study, with their properties
# - DimSpecies: the list of species in the study, with their properties
# - DimSection: the list of sections in the study, with their properties
# - FactSectionAnimals: the data on the number of animals observed in each section of each transect
# - FactSectionVegetation: the data on the vegetation in each section of each transect
# - FactPlotVegetation: the data on the vegetation in each plot of each transect

# 08 Star schema database organization ----------------
# This example database is organized as a Star Schema database, which is explained in detail in [this document](https://docs.google.com/document/d/1UbUMVFfF4muRqt_YOT73NT7xt-vsoLHs0xNza_Le56U/edit?usp=sharing).
# This is a particular type of organisation of data into a relational database using Dim and Fact tables.
# In addition I also recommend Met tables. These **Met tables** contain documents, 'data about data'.
# Dim tables: contain information on lists of objects and subjects that you study with their properties
# Fact tables: are the data that you collect on the objects or subjects listed in your Dim tables.
# The Dim tables are the points of the star, and the Fact tables are at the center of the star.
# The Dim tables are linked to the Fact tables using the unique ID variable in each Dim table.

# 09 MET tables: metadata ----------------
# Met tables are a special type of table that contain meta-data, which is data about the data in your database.
# Met tables are not part of the Star Schema, but they are highly recommended to use in your database.
# Met tables are used to document the study design, the variables, and the data collection process.
# They are also used to keep track of what still needs to be done in the database, such as entering data, checking data, etc.
# Met tables are typically filled in at the start of the project, and updated during the project.
# The following Met tables are recommended to use in your database: 
# - MetStudyInfo: short descriptions of the key features of your study, such as primary investigator, starting date.
# - MetStill2Do: list of what you still need to do, your ToDo list for the database, such as entering data, checking something still in your field book, etc. In this table, keep track of who will do it of your team, in which table, for which variable and put a date when it is complete.
# - MetTables: the list of tables (sheets) in your database, with for each table a short contents description and a CSV link to read the table in an R script. This link for each table you produce from the menu File /Share /Publish to web and then selecting the table name (instead of entire document) and Comma separated values (instead of Web page). This then shows the link. If you put this link in your browser, it gives a download as a csv file. But you can also use this link directly in R to read the data using readr::read_csv(link). So this avoids the use of intermediary data files. Anyone with a script containing that link can read the data. Because such links are impossible to guess this is still sufficiently safe for regular ecological data. If you however want additional security, you can also set up access to tables using the google_drive package in R, allowing user authentication.
# - MetVariables: the list of variables in your database, with for each variable a short description, the unit, the type of variable (numeric, character, factor), and the Dim table it is linked to. This is useful to document the variables in your database. 

# 10 DIM tables: dimensions ----------------
# Dim tables contain information on lists of objects and subjects that you study with their properties.
# Dim tables are the points of the star, and the Fact tables are at the center of the star.
# The Dim tables are linked to the Fact tables using the unique ID variable in each Dim table.
# In this example database, the following Dim tables are used:
# - DimTransect: the list of transects in the study, with their properties such as length, habitat type, etc.
# - DimPlot: the list of plots in the study, with their properties such as size, habitat type, etc.
# - DimSpecies: the list of species in the study, with their properties such as common name, scientific name, etc.
# - DimSection: the list of sections in the study, with their properties such as length, habitat type, etc.
# Each Dim table has a unique ID variable that is used to link to the Fact tables.
# For example, the DimSpecies table has a unique ID variable SpeciesID that is used to link to the FactSectionAnimals table.

# 11 FACT tables: data ----------------
# Fact tables are the data that you collect on the objects or subjects listed in your Dim tables.
# Fact tables are at the center of the star, and are linked to the Dim tables using the unique ID variable in each Dim table.
# In this example database, the following Fact tables are used:
# - FactSectionAnimals: the data on the number of animals observed in each section of each transect, with the SpeciesID linking to the DimSpecies table and the SectionID linking to the DimSection table.
# - FactSectionVegetation: the data on the vegetation in each section of each transect, with the SectionID linking to the DimSection table.
# - FactPlotVegetation: the data on the vegetation in each plot of each transect, with the PlotID linking to the DimPlot table.
# Each Fact table has several ID variables that  to link to the Dim tables, characterising the observation 
# as which species is observed, at which transect, etc

# 12 Reading data from an online database ----------------
# We will now read in an entire  database of transect data with multiple tables, including metadata
# this used the function read_gsdb that you defined in the script 01-setup.r
# this produced a named list object, where the elements of the object are different tibbles
transdat<-read_gsdb("https://docs.google.com/spreadsheets/d/1m-liu8omZMewqz_YP9j_YUmQ0zwATl3z4aRLnZFnfWc")
# it contains the following tibbles
names(transdat)
# show the tibble FactSectionAnimals (or explore in the panel Variables)
transdat$FactSectionAnimals


# 13 Using ggplot for plotting  -----------------------------------------------------
# ggplot2 is a powerfull library allowing all kind of scientific visualisations/plots
ggplot2::ggplot(data=transdat$FactSectionAnimals, 
                mapping=aes(x=SpCode2,y=CountLeft)) +
  geom_boxplot()
# or use with the same outcome 
ggplot2::ggplot() +
  geom_boxplot(data=transdat$FactSectionAnimals, 
               mapping=aes(x=SpCode2,y=CountLeft))
# This makes a boxplot of the number of animals observed (CountLeft) for each species (Spcode6)
# You can see that the species codes are not very informative.
# We can link the species codes to the DimSpecies table to get the full species names

# the species codes are in the table DimSpecies
transdat$DimSpecies

# 14 joining data from different tables ---------------------------------------------
# join the two tables using a left_join with SpCode2 as the key variable linking the tables 
# always put the table with the most rows first, so that you do not lose any rows
alldata<-dplyr::left_join(transdat$FactSectionAnimals,transdat$DimSpecies,by=c("SpCode2"="SpCode2"))
# check the 'environment' tab in R Studio topright in your screen that you are adding variables not rows!
# inspect the data by printing the first few lines

names(alldata)
# now make the boxplot again, but now with the full species names, flip the plot 90 degrees


ggplot2::ggplot(data=alldata, 
                mapping=aes(x=Name_eng,y=CountLeft)) +
  geom_boxplot() +
  labs(x="Species",y="Transect count") +
  coord_flip()

# This makes a boxplot of the number of animals observed (CountLeft) for each species (CommonName)