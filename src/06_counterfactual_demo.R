source("src/05_run_model_comparison.R")

fit_main_portfolio_model <- function(input_path = "data/raw/grocery.csv") {
  dat <- read_grocery_data(input_path)
  panel <- make_features(dat)
  spec <- get_model_specs()[["M4"]]
  fit_model(spec, panel)
}

run_counterfactual_demo <- function(
  input_path = "data/raw/grocery.csv",
  upc_id = "7192100337",
  store_id = "8263",
  week_id = 39995
) {
  dat <- read_grocery_data(input_path)
  panel <- make_features(dat)
  spec <- get_model_specs()[["M4"]]
  fit <- fit_model(spec, panel)

  target <- panel %>%
    dplyr::filter(as.character(UPC) == upc_id,
                  as.character(STORE_NUM) == store_id,
                  WEEK_END_DATE == week_id)

  if (nrow(target) != 1) {
    stop("Target row was not uniquely identified.")
  }

  pred_base <- predict(fit, newdata = target, type = "response")

  cf <- target
  cf$PRICE <- 0.9 * cf$PRICE
  cf$discount <- (cf$BASE_PRICE - cf$PRICE) / cf$BASE_PRICE
  cf$discount_c <- cf$discount - mean(panel$discount, na.rm = TRUE)

  pred_cut <- predict(fit, newdata = cf, type = "response")

  tibble::tibble(
    UPC = upc_id,
    STORE_NUM = store_id,
    WEEK_END_DATE = week_id,
    baseline_pred_units = as.numeric(pred_base),
    price_cut_pred_units = as.numeric(pred_cut),
    pct_change = 100 * (as.numeric(pred_cut / pred_base) - 1)
  )
}

if (sys.nframe() == 0) {
  print(run_counterfactual_demo())
}
