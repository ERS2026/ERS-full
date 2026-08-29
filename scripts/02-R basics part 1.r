# 01 Header ---------------------------------------------------------------------
# title: "Using the renv library for making R predictable"
# author: "Han Olff"
# date: "2025-08-22"
# project: ERS2026

# Collapsing or expanding sections of your script 
# When a line in your script starts ---- (4 or more -) then you can collapse and expand it, 
# try this by clicking on the small triangle next to the line number 8 above. 
# Combine this by numbering the sections of your script, and always make section 01 the Header
# This allows you to show an outline of your script, in the R Studio menu use /Code/Show document outline 
# and allows quick naviations through your script
# in the Explorer panel on the left in Positron, you can view the outline of your script that uses the headers
# while also showing defined variables and functions in each section of your script

# Using renv for making R predictable 
# A major strength, but also potential challenge of R is that the software changes all the time. 
# All functionality # of R comes from packages, and these are improved, expanded, updated all the time. 
# Say that you develop a set of scripts in R now, for example to analyse the data in your master project,
# and you develop a publication from the results. But you get several revisions, and finally complete
# the paper two years later. By that time, you will have updated your versions of R and your 
# packages several times.This may change the functionality of your scripts, they may not work anymore. 
# And when you publish the paper and deposit the data and scripts in a  repository, 
# even 10 years from now you want to be able to replicate your analyses, with the "old" versions of the
# packages that you used at the time when you did the analysis for the paper.

# A similar problem works when working on scripts and data in a collaborative project with multiple people. Then
# typically, not every every collaborator will have exactly the same packages and samve versions of the same
# package installed in their R library. This means only one person can improve the scripts
# and run them, instead of  everyone contributing.

# The renv package solves this in combination with using an R Studio project and Git/Github. 
# for the basis see https://rstudio.github.io/renv/
# In a "fresh" project, you first create an renv.lock file with renv::init(). 
# You typically only do this once. This initialization of your project 
# This serves two goals:
# 1) new packages are installed from then on in a library in the local folder of your project, not anymore in your
# general R installation. So the packages "belong" to the project
# 2) you, or your collaborators, can use renv::restore() to create now or later exactly the same R library 
# (same versions of the packages) as you are using to develop the scripts, where these version numbers are read
# from the renv.lock file. If certain packages are not installed yet on that specific computer, they will be
# installed.
# This ensures that your project uses the exact same package versions and dependencies that were initially 
# recorded, making it easier to reproduce analyses and maintain consistency across different environments or
# collaborators. The version of packages in the library can be update by yourself or your collaborator, but then
# then renv::restore() causes all to use the same versions of all libraries. Be carefull with this, only update
# your library when really nescessary (eg a package contains an error or missing functionality). Otherwise just
# stick to the version that you used when you started the project.
# You do not need to do this renv::init() now, because you have cloned an existing project. 

# Make sure that before you use renv::restore() on a Windows machine, you have RTools installed. This is a set of tools that are 
# needed to compile some packages from source. Install the RTools version that matches your R version. 
# So if you have R version 4.6.x you need RTools45 (it works with R 4.5 and R 4.6 )
# You can download RTools from the [CRAN website at 
# this link: https://cran.r-project.org/bin/windows/Rtools
# and choose the Rtools installer, using default installation settings.
# Note that this works different on a Mac, there you do not work with RTools, but with 
# Appl's developer toolchain instead
# see https://mac.r-project.org/tools/
# ----------------------------------------------------------------

# 02 Set up your environment -------------------------------------
# run the setup script, authenticate google etc
source(here::here("scripts", "01-setup.R"))
# ----------------------------------------------------------------

# 03 the here package --------------------------------------------
# to get the root folder of your project
# use this instead of absolute file locations
# for example do NOT use 
# source("c:\github\ERS2026\01-setup.R"))
# as this will cause problems on collaborating on your project
# ----------------------------------------------------------------

# show the root folder of your git-enabled project
here::here()


# 04 Simple calculations -----------------------------------------
# assigning variables, using functions from a core package
# ----------------------------------------------------------------
1+3
# use built-in function from a package
sqrt(9)
# the full specification would be 
base::sqrt(9)
# but for core packages as base (that come with the default R installation)
# you typicallly do not specify from which package the function comes

# assigning and printing (show the contents) of variables
a<-1
b<-3
print(a+b)
c<-a+b
print(c)
base::sum(a,b) 
c<-sum(a,b)
print(c)
# check the class of a variable
class(a)

# 05 using non-core package functions ---------------------------
# then specify ALWAYS as package::function(parameter1, parameter2)
# because the same function may exist in different packages
# ----------------------------------------------------------------
# calculate the date of the monday of the same week of a date
lubridate::floor_date(lubridate::dmy("29-Aug-2026"), 
                                      unit = "week",
                                      week_start = 1)

# 06 writing your own functions -----------------------------------
# function days_between to calculate the number of days between two dates
# usage example: 
# days_between("31-Aug-2026", "4-Apr-2026")

# define the function days_between
days_between <- function(from, to) {
  as.integer(lubridate::dmy(to) - lubridate::dmy(from))
}
# use the function for a calculation
days_between("1-Apr-2026", "31-Aug-2026")

# 07 datasets in packages -------------------------------------------
# most packages contain especially functions, but sometime also (example) datasets
# ----------------------------------------------------------------

# list what a package contains
ls("package:dplyr")
# print the dataset starwars that is in the dplyr package
print(dplyr::starwars)
# show all variable names of the dataset
names(dplyr::starwars)
# show all levels of the variable name as a vector
dplyr::starwars$name
# frequency table of home world
table(dplyr::starwars$homeworld)
