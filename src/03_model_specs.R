source("src/02_feature_engineering.R")

seasonal_terms <- "trend + sin52_1 + cos52_1 + sin52_2 + cos52_2"

get_model_specs <- function() {
  list(
    M0 = list(
      type = "lm",
      formula = log_units ~ log_base_c + discount_c + DISPLAY + FEATURE + TPR_ONLY + MANUFACTURER + trend
    ),
    M1 = list(
      type = "poisson",
      formula = UNITS ~ log_base_c + discount_c + DISPLAY + FEATURE + TPR_ONLY + MANUFACTURER + trend
    ),
    M2 = list(
      type = "poisson",
      formula = UNITS ~ log_base_c + discount_c + DISPLAY + FEATURE + TPR_ONLY + MANUFACTURER +
        trend + sin52_1 + cos52_1 + sin52_2 + cos52_2
    ),
    M3 = list(
      type = "poisson",
      formula = UNITS ~ log_base_c + discount_c + DISPLAY + FEATURE + TPR_ONLY + UPC +
        trend + sin52_1 + cos52_1 + sin52_2 + cos52_2
    ),
    M4 = list(
      type = "poisson",
      formula = UNITS ~ log_base_c + discount_c + DISPLAY + FEATURE + TPR_ONLY + UPC + STORE_NUM +
        trend + sin52_1 + cos52_1 + sin52_2 + cos52_2
    ),
    M5 = list(
      type = "poisson",
      formula = UNITS ~ log_base_c + discount_c + DISPLAY + FEATURE + TPR_ONLY + UPC + STORE_NUM +
        trend + sin52_1 + cos52_1 + sin52_2 + cos52_2 +
        log_base_c:DISPLAY + discount_c:DISPLAY
    )
  )
}

get_nb_specs <- function() {
  list(
    M2_nb = list(
      type = "nb",
      formula = UNITS ~ log_base_c + discount_c + DISPLAY + FEATURE + TPR_ONLY + MANUFACTURER +
        trend + sin52_1 + cos52_1 + sin52_2 + cos52_2
    ),
    M4_nb = list(
      type = "nb",
      formula = UNITS ~ log_base_c + discount_c + DISPLAY + FEATURE + TPR_ONLY + UPC + STORE_NUM +
        trend + sin52_1 + cos52_1 + sin52_2 + cos52_2
    )
  )
}
