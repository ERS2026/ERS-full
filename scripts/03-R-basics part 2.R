# 01 Header ---------------------------------------------------------------------
# title: 03 R Basics part 2
# author: Han Olff
# date: 2026-08-29
# project: ERS2026
# purpose: Introduce variables, vectors, operators, data frames, tibbles,
#          data types, dates, functions, models, and methods
# ------------------------------------------------------------------------------


# 02 Setup your environment -----------------------------------------------------
# Run the common setup script and synchronize the local project with GitHub.
# ------------------------------------------------------------------------------

# Run the setup script containing package restoration, helper functions, etc.
source(here::here("scripts", "01-setup.R"))

# Pull changes from the online repository into this local project folder.
# This is especially important when collaborating on the same project.
system2("git",c("-C", here::here(), "pull"))


# 03 Variables, vectors, and operators ------------------------------------------
# Variables are named objects used to store values.
# ------------------------------------------------------------------------------

# Create a variable
class_size <- 32 # assign the value 32 to the variable class_size
print(class_size) # print the value stored in class_size

# The equals sign = can also be used for assignment, but <- is conventional in R.


# Logical comparison operators --------------------------------------------------

class_size == 32 # is class_size equal to 32? Returns TRUE or FALSE
class_size != 35 # is class_size different from 35?
class_size > 20 # is class_size greater than 20?
class_size < 20 # is class_size less than 20?
class_size >= 28 # is class_size greater than or equal to 28?
class_size <= 28 # is class_size less than or equal to 28?


# Calculations with variables ---------------------------------------------------

# Variables can be used in calculations.
double_class_size <- class_size * 2 # calculate twice the class size and store the result
double_class_size # display the value of double_class_size

# Calculations can also be performed directly.
(2+3-5+26)/5

# Variables can be combined with other variables in calculations.
half_class_size <- class_size / 2 # calculate half the class size
half_class_size # display the value of half_class_size

total_students <- class_size + double_class_size + half_class_size # add three variables
total_students # display the result


# Updating variables ------------------------------------------------------------

# An existing variable can be assigned a new value.
class_size
class_size <- 30 # replace the previous value of class_size with 30
class_size # display the new value


# Vectors -----------------------------------------------------------------------

# A vector is an ordered collection of values.
# Vectors can contain numeric, character, or logical values.
# The c() function ("combine") creates a vector.

numeric_vector <- c(1, 2, 3, 4) 
print(numeric_vector) # display the complete vector

# Operations on a vector are normally applied element by element.
numeric_vector*2

# Inspect the class of the object.
class(numeric_vector)


# 04 Data frames and tibbles ----------------------------------------------------
# Data frames organize variables as columns and observations as rows.
# ------------------------------------------------------------------------------

# A data frame is a table-like object.
# Each column is a vector and different columns can have different data types.
# A data frame is also a special type of list in which the columns have the
# same length, allowing them to form rows.

data_herbivores <- data.frame(
  id = c(1, 2, 3),
  species = c("Elephant", "Rhino", "Impala"),
  bodymass_kg = c(5400, 1200, 50),
  is_ungulate = c(FALSE, TRUE, TRUE)
)

# Inspect the data frame.
data_herbivores # display the complete data frame
names(data_herbivores) # display the names of its variables (columns)
class(data_herbivores) # inspect the class of the object
data_herbivores$species # extract the species column as a vector


# Selecting and filtering with dplyr --------------------------------------------

# The pipe operator |> passes the result on the left to the function on the right.
# allows a sequence of operations on a dataframe or tibble
megaherbivores<-data_herbivores |>
  dplyr::select(species, bodymass_kg) |> # select two columns
  dplyr::filter(bodymass_kg > 100) # keep rows with body mass > 100 kg
megaherbivores

# Tibbles -----------------------------------------------------------------------
# A tibble is a modern version of a data frame used by the tidyverse.
# Its print method displays variable types and limits the output to rows and
# columns that fit conveniently on screen.
tibble::as_tibble(data_herbivores) 
data_herbivores
data_herbivores<-tibble::as_tibble(data_herbivores) 
data_herbivores

# 05 Data types -----------------------------------------------------------------
# Common basic data types include numeric, integer, character, and logical.
# ------------------------------------------------------------------------------

# Numeric: numbers, including values with decimal points.
num_var <- 3.14 # assign a numeric value
num_var # display the value
class(num_var) # inspect its class

# Integer: whole numbers explicitly marked with L.
int_var <- 42L # L tells R to store 42 as an integer
int_var # display the value
class(int_var) # inspect its class

# Character: text enclosed in quotation marks.
char_var <- "Hello, R!" # assign a character value
char_var # display the value
class(char_var) # inspect its class

# Logical: TRUE or FALSE.
log_var <- TRUE # assign TRUE
log_var # display the value
class(log_var) # inspect its class

log_var2 <- FALSE # assign FALSE
log_var2 # display the value
class(log_var2) # inspect its class


# 06 Dates and time -------------------------------------------------------------
# Dates written between quotation marks start as character strings.
# lubridate provides functions for converting them into date/time objects.
# ------------------------------------------------------------------------------

# A date written as text is still a character object.
date_var<-"2023-01-12"
class(date_var)

# Arithmetic does not work as date arithmetic while the value is character.
date_var + 40

# Convert year-month-day text into a Date object.
date_var <- lubridate::ymd("2023-01-12") # convert the character date to a Date
date_var # display the date
class(date_var) # inspect its class

# Date objects support date arithmetic.
date_var + 40

# Different input formats for dates and times

# dmy() parses dates written as day-month-year.
date_var <- lubridate::dmy("18-Dec-2023") 
date_var

# ymd_hms() parses year-month-day plus hours, minutes, and seconds.
date_var <- lubridate::ymd_hms("2023-12-18 14:30:00")
date_var

# Time zones 

# Interpret the stated clock time as local time in the Netherlands.
date_var <- lubridate::ymd_hms("2023-12-18 14:30:00", 
                                tz = "Europe/Amsterdam") 
date_var

# Interpret the stated clock time as local time in Kenya.
# Time zones in R use standard Olson/IANA time-zone names.
grep("Nairobi", OlsonNames(), value = TRUE)

date_var <- lubridate::ymd_hms("2023-12-18 14:30:00",tz="Africa/Nairobi")
date_var


# 07 Statistical functions -------------------------------------------
# Functions take inputs (arguments), perform operations, and return results.
# ------------------------------------------------------------------------------

# R contains many built-in functions.
base::sqrt(16) # calculate the square root of 16

# Statistical analyses are also implemented as functions.
# simple one: calculate the mean
mean(c(1,4,8))
# but also more complex statistical analysis
# lm() fits a linear model and returns an object containing the model results.
# define the x and y variables
x<-c(1,2,3,4,5)
y<-c(3,5,4,8,11)

model1<-stats::lm(y~x) # fit a linear model of y as a function of x using the lm() function

# model1 is an object of class "lm".
# Internally, an lm object is a named list containing many model components
# each model component as the original data, fitted coefficients, residuals, fit etc are stored as list elements
str(model1) 
class(model1)
print(unclass(model1))

# Individual elements of the model named list object can be accessed with $
# so that they can be used in further data analyses
model1$coefficients # coefficients: intercept and slope
model1$coefficients[2] # slope
model1$coefficients[1] # intercept

# summary() provides a more complete statistical summary of the fitted model.
summary(model1)

# Functions themselves are objects and their definitions can often be inspected.
print(lm) # display the lm function definition

# Open the help page to inspect its arguments, description, and examples.
?lm


# 08 Methods of a function -------------------------------------------------------
# A generic function can behave differently for different classes of objects.
# These class-specific implementations are called methods.
# ------------------------------------------------------------------------------

# summary() is a generic function with methods for many classes of objects.

# Create a numeric vector.
vector<-c(1,2,3)

# The numeric vector has class "numeric".
# NOTE: the following line currently summarizes model1 rather than vector.
summary(model1) 

# Apply summary() to an object of class "lm".
summary(model1)


# Inspecting methods -------------------------------------------------------------

# methods() lists the available methods for a generic function.
methods("summary") # display methods available for summary()

# R examines the class of an object and dispatches the appropriate method.
# For a numeric vector, summary() falls back to summary.default().
# For an lm object, it uses summary.lm().

summary.default(vector)
summary.lm(model1)
