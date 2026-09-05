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
  ggplot2::ggplot(
    aes(x = Elevation_m,
        y = ClayDepth_cm, 
        color = factor(Year))) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) 

# ----------------03 fit lm model with standardized (beta) estimates-------------------
lm_spec <- parsnip::linear_reg() |>
  parsnip::set_engine("lm") |>
  parsnip::set_mode("regression")

lm_fit <- lm_spec |>
  parsnip::fit(ClayDepth_cm ~ Elevation_m * Year, data = FactVegClay)

# standardized (beta) coefficients require lm.beta on the underlying
# engine fit, since parsnip's "lm" engine has no standardized-coefficient option
lm_fit_beta <- lm.beta::lm.beta(parsnip::extract_fit_engine(lm_fit))
lm_fit_beta

broom::tidy(lm_fit_beta)
broom::glance(parsnip::extract_fit_engine(lm_fit))

# plot the data with the fitted regression lines (one per year, since
# the model includes an Elevation_m * Year interaction)
FactVegClay |>
  ggplot2::ggplot(aes(x = Elevation_m, y = ClayDepth_cm, color = factor(Year))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

# ----------------04 logistic regression of Limonium vulgare occurrence-------------------
# Limonium.vulgare is a presence/absence (0/1) variable, so we model it
# with a binomial (logistic) GLM against elevation.

glm_spec <- parsnip::logistic_reg() |>
  parsnip::set_engine("glm") |>
  parsnip::set_mode("classification")

glm_fit <- glm_spec |>
  parsnip::fit(factor(Limonium.vulgare) ~ Elevation_m, data = FactVegClay)

broom::tidy(glm_fit)
broom::glance(parsnip::extract_fit_engine(glm_fit)) # pull out the underlying glm object and glance at it

# plot the fitted logistic curve
FactVegClay |>
  ggplot2::ggplot(aes(x = Elevation_m, y = Limonium.vulgare)) +
  geom_point(shape = "|") +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), se = FALSE)

