source("src/00_setup.R")

to_flag_factor <- function(x) {
  x_chr <- as.character(x)
  yes_like <- x_chr %in% c("1", "TRUE", "True", "true", "Yes", "YES")
  factor(ifelse(yes_like, "Yes", "No"), levels = c("No", "Yes"))
}

read_grocery_data <- function(path = "data/raw/grocery.csv") {
  dat <- readr::read_csv(path, show_col_types = FALSE)

  required_cols <- c(
    "BASE_PRICE", "PRICE", "WEEK_END_DATE", "STORE_NUM", "UPC",
    "MANUFACTURER", "DISPLAY", "FEATURE", "TPR_ONLY", "UNITS"
  )

  missing_cols <- setdiff(required_cols, names(dat))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  dat <- dat %>%
    mutate(
      BASE_PRICE = as.numeric(BASE_PRICE),
      PRICE = as.numeric(PRICE),
      WEEK_END_DATE = as.integer(WEEK_END_DATE),
      STORE_NUM = factor(STORE_NUM),
      UPC = factor(UPC),
      MANUFACTURER = factor(MANUFACTURER),
      DISPLAY = to_flag_factor(DISPLAY),
      FEATURE = to_flag_factor(FEATURE),
      TPR_ONLY = to_flag_factor(TPR_ONLY),
      UNITS = as.numeric(UNITS)
    ) %>%
    arrange(WEEK_END_DATE, STORE_NUM, UPC)

  if (any(dat$BASE_PRICE <= 0, na.rm = TRUE)) {
    stop("BASE_PRICE must be strictly positive.")
  }
  if (any(dat$PRICE <= 0, na.rm = TRUE)) {
    stop("PRICE must be strictly positive.")
  }
  if (any(dat$UNITS < 0, na.rm = TRUE)) {
    stop("UNITS must be non-negative.")
  }

  dat
}
