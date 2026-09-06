#--------------------01 Setup-----------------------------------------
# pull the changes in the online repository to this local folder
# this is important when you collaborate on the project
# it updates all your scripts to the latest version, and ensures that you have the same versions of the scripts as your collaborators
system2("git", c("-C", here::here(), "pull"))

# Include the setup script with source(). This will run the code in the setup script, and load the packages and functions that are defined in this script and that we will lead later on in upcoming scripts that we use in this course.
source(here::here("scripts", "01-setup.R"))

# load required libraries for this script
library(lm.beta)
library(tidymodels)


# -----------------02 read and explore the dataset --------------------
Microtransect<-read_gsdb("https://docs.google.com/spreadsheets/d/1dJkH09imko9RgOkGzYQT74IeGY56QwiXjjBl7u0KcK0/")
FactVegClay<-Microtransect$FactVegClay
FactVegClay

# explore relation between elevation and claydepth
FactVegClay |>
  ggplot2::ggplot(aes(x = Elevation_m, y = ClayDepth_cm)) +
  geom_point(aes(color = factor(Year))) +
  geom_smooth(method = "lm", se = FALSE)

#explore the relation between claydepth and year with 
FactVegClay |>
  ggplot2::ggplot(aes(x = Year,y = ClayDepth_cm)) + 
  geom_point(aes(color=Elevation_m)) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_steps2(low = "blue", mid = "yellow", high = "red", 
                     midpoint = mean(FactVegClay$Elevation_m), n.breaks = 8)

# ----------------04 fit lm model with standardized (beta) estimates-------------------
# Center Elevation_m and Year before fitting. With an interaction term,
# leaving either predictor uncentered creates severe collinearity between
# the main effect and the interaction (inflated/misleading coefficients),
# so both predictors must be centered for stable, interpretable estimates.
# Fit the unstandardized model and the standardized (beta) version in one
# pipe: lm.beta() adds standardized.coefficients on top of the lm object,
# so lm_fit_beta still works anywhere lm_fit (an "lm") would, e.g. predict().
lm_fit_beta <- FactVegClay |>
  mutate(
    Elevation_m_c = Elevation_m - mean(Elevation_m),
    Year_c = Year - mean(Year)
  ) |>
  lm(ClayDepth_cm ~ Elevation_m_c * Year_c, data = _) |>
  lm.beta::lm.beta()

broom::tidy(lm_fit_beta)
broom::glance(lm_fit_beta)

# Fitted model equation (unstandardized coefficients):
# ClayDepth_cm = 4.13 + 24.8 * Elevation_m_c + 0.476 * Year_c
#                + 2.53 * Elevation_m_c * Year_c
# where Elevation_m_c and Year_c are Elevation_m and Year centered on
# their sample means.

# Interpretation: standardized coefficients are ~0.56 for elevation and
# ~0.50 for year, indicating comparably strong associations with clay
# depth (in SD units) when each predictor is considered at the mean of
# the other. The interaction is much smaller (~0.15), suggesting the
# elevation-clay depth relationship changes only modestly across years,
# though it is still statistically significant (see p-value above).

FactVegClay |>
  # lm_fit_beta$fitted.values are the unstandardized fitted values from
  # the underlying lm fit
  ggplot2::ggplot(aes(x = Elevation_m, y = ClayDepth_cm, color = factor(Year))) +
  geom_point() +
  geom_line(aes(y = lm_fit_beta$fitted.values), linewidth = 1) +
  labs(x = "Elevation (m)", y = "Clay depth (cm)", color = "Year") +
  theme_bw()

# check the difference if we would have used geom_smooth() with lm 
# this calculates a new lm fit for each year, 
# so the results differ from the interaction model
FactVegClay |>
  # lm_fit_beta$fitted.values are the unstandardized fitted values from
  # the underlying lm fit
  ggplot2::ggplot(aes(x = Elevation_m, y = ClayDepth_cm, color = factor(Year))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Elevation (m)", y = "Clay depth (cm)", color = "Year") +
  theme_bw()


# ----------------04 logistic regression of Limonium vulgare occurrence-------------------
# Limonium.vulgare is a presence/absence (0/1) variable, so we model it
# with a binomial (logistic) glmmTMB model against elevation.



