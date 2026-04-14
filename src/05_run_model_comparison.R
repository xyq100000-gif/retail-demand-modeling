source("src/04_validation_helpers.R")

extract_terms <- function(fit, model_name) {
  broom::tidy(fit) %>%
    dplyr::filter(term %in% c(
      "log_base_c", "discount_c", "DISPLAYYes",
      "log_base_c:DISPLAYYes", "discount_c:DISPLAYYes"
    )) %>%
    dplyr::mutate(model = model_name)
}

run_stage2 <- function(input_path = "data/raw/grocery.csv") {
  dat <- read_grocery_data(input_path)
  panel <- make_features(dat)
  specs <- get_model_specs()
  nb_specs <- get_nb_specs()
  splits <- make_time_splits(panel)

  rolling_summary <- list()
  coef_rows <- list()

  for (model_name in names(specs)) {
    spec <- specs[[model_name]]

    rolling_eval <- purrr::map(splits$rolling, ~ evaluate_split(spec, .x))
    rolling_metrics <- dplyr::bind_rows(purrr::map(rolling_eval, "metrics"))

    if (model_name %in% c("M1", "M3", "M4", "M5")) {
      coef_rows[[model_name]] <- dplyr::bind_rows(
        purrr::imap(rolling_eval, function(ev, idx) {
          extract_terms(ev$fit, model_name) %>% dplyr::mutate(split_id = ev$metrics$split_id)
        })
      )
    }

    holdout_eval <- evaluate_split(spec, splits$holdout)
    holdout_metrics <- slice_metrics(holdout_eval$predictions)

    rolling_summary[[model_name]] <- tibble::tibble(
      model = model_name,
      rolling_mean_rmse = mean(rolling_metrics$rmse),
      rolling_sd_rmse = stats::sd(rolling_metrics$rmse),
      rolling_mean_mae = mean(rolling_metrics$mae)
    ) %>%
      dplyr::bind_cols(holdout_metrics)
  }

  model_summary <- dplyr::bind_rows(rolling_summary) %>%
    dplyr::arrange(holdout_rmse)

  coef_stability <- dplyr::bind_rows(coef_rows) %>%
    dplyr::group_by(model, term) %>%
    dplyr::summarise(
      mean_coef = mean(estimate),
      sd_coef = stats::sd(estimate),
      min_coef = min(estimate),
      max_coef = max(estimate),
      sign_consistent = dplyr::n_distinct(sign(estimate)) == 1,
      .groups = "drop"
    )

  nb_checks <- purrr::imap_dfr(nb_specs, function(spec, model_name) {
    fit <- fit_model(spec, splits$holdout$train)
    pred <- predict_units(fit, spec, splits$holdout$test)

    tibble::tibble(
      model = model_name,
      alpha = if ("theta" %in% names(fit)) 1 / fit$theta else NA_real_,
      aic = AIC(fit),
      holdout_rmse = rmse(splits$holdout$test$UNITS, pred),
      holdout_mae = mae(splits$holdout$test$UNITS, pred)
    )
  })

  readr::write_csv(model_summary, "results/stage2_model_summary.csv")
  readr::write_csv(coef_stability, "results/stage2_coef_stability.csv")
  readr::write_csv(nb_checks, "results/stage2_nb_checks.csv")

  message("Saved results to results/stage2_model_summary.csv")
  message("Saved coefficient stability to results/stage2_coef_stability.csv")
  message("Saved NB checks to results/stage2_nb_checks.csv")

  invisible(list(
    model_summary = model_summary,
    coef_stability = coef_stability,
    nb_checks = nb_checks
  ))
}

if (sys.nframe() == 0) {
  run_stage2()
}
