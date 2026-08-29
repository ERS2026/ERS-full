##### ----------------------------description---------------------------------
# # 01-setup.R - Han Olff - June 2026
# This script is the first script to run in the project. 
# this is typically done by sourcing the script in the R console or in the RStudio IDE by putting at the start of every script: source("scripts/01-setup.R")
# Functionally in this script is that it clears the environment,
#  restores the packages in the renv.lock file, sets the timezone to UTC, loads the required libraries and defines user functions.
# user functions defined here can be used in any other script in the project after sourcing this script.
# Functions defined here are for example the function read_gsdb() to read a Google Sheets database and the function gsheets_auth() to authenticate Google Sheets access.
#####-------------------------------------------------------------------------

# ============================================================
# Project setup
# ============================================================

# Clear the current R workspace
rm(list = ls())

# Set CRAN mirror explicitly to avoid package installation issues
options(repos = c(CRAN = "https://cran.r-project.org"))

# Set timezone to UTC to avoid date/time inconsistencies
Sys.setenv(TZ = "UTC")


# ============================================================
# Install required setup packages if missing
# ============================================================

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

if (!requireNamespace("pkgbuild", quietly = TRUE)) {
  install.packages("pkgbuild")
}


# ============================================================
# Check system build tools
# ============================================================

# Windows:
# R packages installed from source may require Rtools.
# If this check fails, install the correct Rtools version from:
# https://cran.r-project.org/bin/windows/Rtools/

if (.Platform$OS.type == "windows") {
  message("Checking Rtools RTools installation status...")
  pkgbuild::has_rtools(debug = TRUE)
  } else {
  message("Not running on Windows; Rtools is not applicable.")
}

# macOS:
# Rtools is not used on macOS.
# Source package compilation uses Xcode Command Line Tools instead.
# See:
# https://github.com/OlffLab/2026_OlfflabRepoTemplate/blob/main/docs/building%20packages%20on%20MacOS.pdf


# ============================================================
# Restore project package environment
# ============================================================

packages <- c(
  "here",
  "renv",
  "pkgbuild",
  "googlesheets4",
  "purrr",
  "tidyverse",  # tidyverse is a metapackage loading a family of related packages: ggplot, dplyr etc
  "lubridate",
  "patchwork",
  "httpuv"
)

missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing)) {
  install.packages(missing)
}


# Restore packages recorded in renv.lock if needed. This ensures that the project uses the same package versions as specified in the lockfile.
message("Checking and restoring project package environment using renv...")
renv::restore()

# ============================================================
# Load required libraries
# ============================================================

suppressPackageStartupMessages({
  library(googlesheets4)
  library(purrr)
  library(tidyverse)
  library(patchwork)
  library(httpuv)
})

# ============================================================
# Define helper functions
# ============================================================

##### 1) Function read_gsdb to read specific sheets from a gsheets database or the whole database
# 
# Usage examples : 
#
# 1 - Read all sheets in a database, no filter, all sheets are put in a list object (default)
# database_link <- "https://docs.google.com/spreadsheets/d/<SHEET_ID>"
# database <- read_gsdb(database_link)
# names(database)
# 
# 2- Read two specific sheets:
# subset <- read_gsdb(database, sheets = c("Species", "Transects"))
# 
# 3 - Read three specific sheets, with a specific filter for each sheet
# filtered <- read_gsdb(database_link,sheets = c("Species", "Transects", "Observations"),
#    filter = list(
#                  Species      = ~ !is.na(Species_ID),
#                  Transects    = ~ Region == "Loita",
#                  Observations = ~ cover > 0))


library(googlesheets4)
library(purrr)

read_gsdb <- function(database, sheets = NULL, separate = FALSE, verbose = TRUE) {
  if (is.null(sheets)) {
    sheets <- googlesheets4::sheet_names(database)
  }
  
  n <- length(sheets)
  start_time <- Sys.time()
  
  # always print duration at the end
  on.exit({
    elapsed <- as.integer(difftime(Sys.time(), start_time, units = "secs"))
    cat(sprintf("\nDone in %d:%02d (mm:ss)\n", elapsed %/% 60, elapsed %% 60))
  }, add = TRUE)
  
  if (verbose) {
    cat(sprintf("Reading %d sheet%s...\n", n, if (n == 1) "" else "s"))
    pb <- utils::txtProgressBar(min = 0, max = n, style = 3)
    on.exit(close(pb), add = TRUE)
  }
  
  res <- vector("list", n)
  names(res) <- sheets
  
  for (i in seq_along(sheets)) {
    sh <- sheets[i]
    if (verbose) {
      utils::setTxtProgressBar(pb, i - 1)
      cat(sprintf("\r[%d/%d] %s ...", i, n, sh))
      flush.console()
    }
    res[[i]] <- googlesheets4::read_sheet(database, sheet = sh)
    if (verbose) utils::setTxtProgressBar(pb, i)
  }
  
  if (separate) {
    list2env(res, envir = .GlobalEnv)
    invisible(res)
  } else {
    res
  }
}


##### --- Function to authenticate with Google Sheets (googlesheets4) ----------------------------
suppressPackageStartupMessages(library(googlesheets4))

gsheets_auth <- function(
    mode = c("auto", "public", "user", "service"),
    email = Sys.getenv("GS_EMAIL", ""),                     # for user OAuth
    sa_json = Sys.getenv("GS_SERVICE_ACCOUNT_JSON", ""),    # for service account
    cache = Sys.getenv("GARGLE_OAUTH_CACHE", "~/.R/gargle"),
    verbose = TRUE
) {
  mode <- match.arg(mode)
  
  # Where to cache OAuth tokens (user mode). Create the folder if needed.
  cache <- path.expand(cache)
  if (!dir.exists(cache)) dir.create(cache, recursive = TRUE, showWarnings = FALSE)
  options(gargle_oauth_cache = cache)
  
  if (mode == "public") {
    googlesheets4::gs4_deauth()
    if (verbose) message("gs4: deauthed (public read-only).")
    return(invisible(TRUE))
  }
  
  if (mode == "service" || (mode == "auto" && nzchar(sa_json))) {
    sa_json <- path.expand(sa_json)
    if (!file.exists(sa_json)) stop("GS_SERVICE_ACCOUNT_JSON not found: ", sa_json)
    googlesheets4::gs4_auth(path = sa_json)
  } else if (mode == "user" || (mode == "auto" && nzchar(email))) {
    googlesheets4::gs4_auth(email = email)   # if email="", Google will prompt interactively
  } else if (interactive()) {
    # No env vars set; interactively pick an account in your browser
    googlesheets4::gs4_auth()
  } else {
    stop("No credentials available. Set GS_SERVICE_ACCOUNT_JSON or GS_EMAIL, ",
         "or call gsheets_auth(mode = 'public') for public sheets.")
  }
  
  if (verbose) {
    message("gs4: ", paste(capture.output(googlesheets4::gs4_user()), collapse = " "),
            " | cache: ", normalizePath(cache, winslash = "/"))
  }
  invisible(TRUE)
}