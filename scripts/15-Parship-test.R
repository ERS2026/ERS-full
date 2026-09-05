#--------------------01 Setup-----------------------------------------
# pull the changes in the online repository to this local folder
# this is important when you collaborate on the project
# it updates all your scripts to the latest version, and ensures that you have the same versions of the scripts as your collaborators
system2("git", c("-C", here::here(), "pull"))

# Include the setup script with source(). This will run the code in the setup script, and load the packages and functions that are defined in this script and that we will lead later on in upcoming scripts that we use in this course.
source(here::here("scripts", "01-setup.R"))

# -----------------02 read the dataset --------------------
Microtransect<-read_gsdb("https://docs.google.com/spreadsheets/d/1dJkH09imko9RgOkGzYQT74IeGY56QwiXjjBl7u0KcK0/")
FactVegClay<-Microtransect$FactVegClay
class(FactVegClay)

# explore relation between elevation and claydepth
FactVegClay |>
  ggplot2::ggplot(
    aes(x = Elevation_m,
        y = ClayDepth_cm, 
        color = factor(Year))) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) 


