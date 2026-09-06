#--------------------01 Setup-----------------------------------------
# pull the changes in the online repository to this local folder
# this is important when you collaborate on the project
# it updates all your scripts to the latest version, and ensures that you have the same versions of the scripts as your collaborators
system2("git", c("-C", here::here(), "pull"))

# Include the setup script with source(). This will run the code in the setup script, and load the packages and functions that are defined in this script and that we will lead later on in upcoming scripts that we use in this course.
source(here::here("scripts", "01-setup.R"))

# load required libraries for this script
library(lm.beta)


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

# ----------------03 fit lm model with interaction term-------------------
FactVegClay |>
  lm(ClayDepth_cm ~ Elevation_m * Year, data = _) -> lm_fit 

broom::tidy(lm_fit)
broom::glance(lm_fit)
car::vif(lm_fit)

# Fitted model equation:
# ClayDepth_cm = 4821.64 - 5091.16 * Elevation_m - 2.40 * Year
#                + 2.53 * Elevation_m * Year
# where Elevation_m and Year are the original (uncentered) variables.
# Note: Elevation_m and the interaction term are severely collinear here
# (variance inflation factors - VIFs - in the hundreds of thousands) because 
# Year is not centered, so these individual coefficients are numerically unstable 
# and the coefficients of the model are not reliable.
# For the centered version with stable, interpretable estimates, see next section.

# ----------------05 fit lm model with standardized (beta) estimates-------------------
# Center Elevation_m and Year before fitting. With an interaction term,
# leaving either predictor uncentered creates severe collinearity between
# the main effect and the interaction (inflated/misleading coefficients),
# so both predictors must be centered for stable, interpretable estimates.
# Fit the unstandardized model and the standardized (beta) version in one
# pipe: lm.beta() adds standardized.coefficients on top of the lm object,
# so lm_fit_beta still works anywhere lm_fit (an "lm") would, e.g. predict().
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


FactVegClay |>
  ggplot2::ggplot(aes(x = Elevation_m, y = ClayDepth_cm, color = factor(Year))) +
  geom_point() +
  geom_line(aes(y = lm_fit_beta$fitted.values), linewidth = 1) +
  labs(x = "Elevation (m)", y = "Clay depth (cm)", color = "Year") +
  theme_bw()
# Interpretation: standardized coefficients are ~0.56 for elevation and
# ~0.50 for year, indicating comparably strong associations with clay
# depth (in SD units) when each predictor is considered at the mean of
# the other. The interaction is much smaller (~0.15), suggesting the
# elevation-clay depth relationship changes only modestly across years,
# though it is still statistically significant (see p-value above).

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


# ----------------06 logistic regression of Limonium vulgare occurrence-------------------
# Limonium.vulgare is a presence/absence (0/1) variable, so we model it
# with a binomial (logistic) glmmTMB model against elevation.



