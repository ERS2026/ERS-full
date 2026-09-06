#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# pull the changes in the online repository to this local folder
# this is important when you collaborate on the project
# it updates all your scripts to the latest version, and ensures that you have the same versions of the scripts as your collaborators
system2("git", c("-C", here::here(), "pull"))

# Include the setup script with source(). This will run the code in the setup script, and load the packages and functions that are defined in this script and that we will lead later on in upcoming scripts that we use in this course.
source(here::here("scripts", "01-setup.R"))

# load required libraries for this script
library(lm.beta)

#authenticate with Google Drive to read the dataset from the Google Sheet
googledrive::drive_auth()
#
#
#
#
#
Microtransect <- read_gsdb("https://docs.google.com/spreadsheets/d/1dJkH09imko9RgOkGzYQT74IeGY56QwiXjjBl7u0KcK0/")
FactVegClay <- Microtransect$FactVegClay
FactVegClay
#
#
#
#
#
FactVegClay |>
  ggplot2::ggplot(aes(x = Elevation_m, y = ClayDepth_cm)) +
  geom_point(aes(color = factor(Year))) +
  geom_smooth(method = "lm", se = FALSE)
#
#
#
#
#
FactVegClay |>
  ggplot2::ggplot(aes(x = Year, y = ClayDepth_cm)) +
  geom_point(aes(color = Elevation_m)) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_steps2(low = "blue", mid = "yellow", high = "red", 
                     midpoint = mean(FactVegClay$Elevation_m), n.breaks = 8)
#
#
#
#
#
FactVegClay |>
  lm(ClayDepth_cm ~ Elevation_m * Year, data = _) -> lm_fit 

broom::tidy(lm_fit)
broom::glance(lm_fit)
car::vif(lm_fit)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
FactVegClay |>
  mutate(
    Elevation_m_c = Elevation_m - mean(Elevation_m),
    Year_c = Year - mean(Year)
  ) |>
  lm(ClayDepth_cm ~ Elevation_m_c * Year_c, data = _) |>
  lm.beta::lm.beta() -> lm_fit_beta

broom::tidy(lm_fit_beta)
broom::glance(lm_fit_beta)
str(lm_fit_beta)
#
#
#
FactVegClay |>
  ggplot2::ggplot(aes(x = Elevation_m, y = ClayDepth_cm, color = factor(Year))) +
  geom_point() +
  geom_line(aes(y = lm_fit_beta$fitted.values), linewidth = 1) +
  labs(x = "Elevation (m)", y = "Clay depth (cm)", color = "Year") +
  theme_bw()
#
#
#
#
#
#
#
FactVegClay |>
  # lm_fit_beta$fitted.values are the unstandardized fitted values from
  # the underlying lm fit
  ggplot2::ggplot(aes(x = Elevation_m, y = ClayDepth_cm, color = factor(Year))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Elevation (m)", y = "Clay depth (cm)", color = "Year") +
  theme_bw()
#
#
#
#
#
#
#
#
