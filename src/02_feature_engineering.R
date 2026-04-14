source("src/01_data_prep.R")

make_features <- function(dat) {
  unique_weeks <- sort(unique(dat$WEEK_END_DATE))
  week_index <- setNames(seq_along(unique_weeks), unique_weeks)

  dat %>%
    mutate(
      log_units = log1p(UNITS),
      log_base = log(BASE_PRICE),
      discount = (BASE_PRICE - PRICE) / BASE_PRICE,
      trend = unname(week_index[as.character(WEEK_END_DATE)]),
      sin52_1 = sin(2 * pi * trend / 52),
      cos52_1 = cos(2 * pi * trend / 52),
      sin52_2 = sin(4 * pi * trend / 52),
      cos52_2 = cos(4 * pi * trend / 52),
      promo_any = factor(
        ifelse(DISPLAY == "Yes" | FEATURE == "Yes" | TPR_ONLY == "Yes", "Promo", "NoPromo"),
        levels = c("NoPromo", "Promo")
      )
    ) %>%
    mutate(
      log_base_c = log_base - mean(log_base, na.rm = TRUE),
      discount_c = discount - mean(discount, na.rm = TRUE)
    )
}
