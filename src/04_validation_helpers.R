source("src/03_model_specs.R")

rmse <- function(y, yhat) sqrt(mean((y - yhat)^2, na.rm = TRUE))
mae <- function(y, yhat) mean(abs(y - yhat), na.rm = TRUE)

assert_no_new_levels <- function(train, test, vars) {
  for (v in vars) {
    if (!v %in% names(train) || !v %in% names(test)) next
    train_vals <- unique(as.character(train[[v]]))
    test_vals <- unique(as.character(test[[v]]))
    new_vals <- setdiff(test_vals, train_vals)
    if (length(new_vals) > 0) {
      stop("New levels in test for ", v, ": ", paste(new_vals, collapse = ", "))
    }
  }
}

make_time_splits <- function(dat, initial_weeks = 72, assess_weeks = 12, n_splits = 5, holdout_weeks = 24) {
  unique_weeks <- sort(unique(dat$WEEK_END_DATE))
  if (length(unique_weeks) < initial_weeks + assess_weeks * n_splits + holdout_weeks) {
    stop("Not enough distinct weeks for the requested split design.")
  }

  train_val_weeks <- unique_weeks[seq_len(length(unique_weeks) - holdout_weeks)]
  rolling_splits <- vector("list", n_splits)

  for (i in seq_len(n_splits)) {
    train_end <- initial_weeks + assess_weeks * (i - 1)
    val_start <- train_end + 1
    val_end <- train_end + assess_weeks

    train_weeks <- train_val_weeks[seq_len(train_end)]
    val_weeks <- train_val_weeks[val_start:val_end]

    rolling_splits[[i]] <- list(
      split_id = paste0("rolling_", i),
      train = dat %>% dplyr::filter(WEEK_END_DATE %in% train_weeks),
      test = dat %>% dplyr::filter(WEEK_END_DATE %in% val_weeks)
    )
  }

  holdout_split <- list(
    split_id = "future_holdout",
    train = dat %>% dplyr::filter(WEEK_END_DATE %in% train_val_weeks),
    test = dat %>% dplyr::filter(WEEK_END_DATE %in% tail(unique_weeks, holdout_weeks))
  )

  list(rolling = rolling_splits, holdout = holdout_split)
}

fit_model <- function(spec, train_data) {
  if (spec$type == "lm") {
    return(lm(spec$formula, data = train_data))
  }
  if (spec$type == "poisson") {
    return(glm(spec$formula, data = train_data, family = poisson(link = "log")))
  }
  if (spec$type == "nb") {
    return(MASS::glm.nb(spec$formula, data = train_data, link = log))
  }
  stop("Unknown model type: ", spec$type)
}

predict_units <- function(fit, spec, test_data) {
  if (spec$type == "lm") {
    pred_log <- predict(fit, newdata = test_data)
    return(pmax(exp(pred_log) - 1, 0))
  }
  predict(fit, newdata = test_data, type = "response")
}

evaluate_split <- function(spec, split_obj) {
  vars_in_model <- all.vars(spec$formula)
  factor_candidates <- c("DISPLAY", "FEATURE", "TPR_ONLY", "MANUFACTURER", "UPC", "STORE_NUM")
  factor_vars <- intersect(vars_in_model, factor_candidates)

  assert_no_new_levels(split_obj$train, split_obj$test, factor_vars)

  fit <- fit_model(spec, split_obj$train)
  pred <- predict_units(fit, spec, split_obj$test)

  out <- split_obj$test %>%
    mutate(.pred = pred)

  list(
    fit = fit,
    predictions = out,
    metrics = tibble::tibble(
      split_id = split_obj$split_id,
      rmse = rmse(out$UNITS, out$.pred),
      mae = mae(out$UNITS, out$.pred)
    )
  )
}

slice_metrics <- function(pred_df) {
  q90 <- as.numeric(stats::quantile(pred_df$UNITS, probs = 0.9, na.rm = TRUE))

  tibble::tibble(
    holdout_rmse = rmse(pred_df$UNITS, pred_df$.pred),
    holdout_mae = mae(pred_df$UNITS, pred_df$.pred),
    holdout_rmse_promo = rmse(pred_df$UNITS[pred_df$promo_any == "Promo"], pred_df$.pred[pred_df$promo_any == "Promo"]),
    holdout_rmse_nonpromo = rmse(pred_df$UNITS[pred_df$promo_any == "NoPromo"], pred_df$.pred[pred_df$promo_any == "NoPromo"]),
    holdout_rmse_top_decile = rmse(pred_df$UNITS[pred_df$UNITS >= q90], pred_df$.pred[pred_df$UNITS >= q90])
  )
}
