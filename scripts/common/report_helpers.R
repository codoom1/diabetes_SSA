suppressPackageStartupMessages({
  library(dplyr)
  library(forecast)
  library(ggplot2)
  library(knitr)
  library(readr)
  library(scales)
  library(tidyr)
})

# Core GBD measure order used consistently in tables and facets.
measure_levels <- c(
  "Prevalence",
  "Incidence",
  "Deaths",
  "DALYs (Disability-Adjusted Life Years)",
  "YLLs (Years of Life Lost)",
  "YLDs (Years Lived with Disability)"
)

# Short labels keep dense report tables and multi-panel figures readable.
measure_short <- c(
  "Prevalence" = "Prevalence",
  "Incidence" = "Incidence",
  "Deaths" = "Deaths",
  "DALYs (Disability-Adjusted Life Years)" = "DALYs",
  "YLLs (Years of Life Lost)" = "YLLs",
  "YLDs (Years Lived with Disability)" = "YLDs"
)

# Minimum column set expected in every GBD extract used by the report.
required_gbd_columns <- c(
  "measure_id", "measure_name", "location_id", "location_name", "sex_id",
  "sex_name", "age_id", "age_name", "cause_id", "cause_name", "metric_id",
  "metric_name", "year", "val", "upper", "lower"
)

lstm_backend_status <- function() {
  has_r_packages <- requireNamespace("keras", quietly = TRUE) &&
    requireNamespace("tensorflow", quietly = TRUE) &&
    requireNamespace("reticulate", quietly = TRUE)

  if (!has_r_packages) {
    return(tibble(
      lstm_available = FALSE,
      lstm_status = "R packages keras, tensorflow, and/or reticulate are not installed"
    ))
  }

  tf_config <- try(tensorflow::tf_config(), silent = TRUE)
  if (
    inherits(tf_config, "try-error") ||
      isFALSE(tf_config$available) ||
      is.null(tf_config$available)
  ) {
    return(tibble(
      lstm_available = FALSE,
      lstm_status = "R packages are installed, but the Python TensorFlow backend is not configured"
    ))
  }

  version <- if (is.null(tf_config$version)) "version not reported" else tf_config$version
  tibble(
    lstm_available = TRUE,
    lstm_status = paste("TensorFlow backend available:", version)
  )
}

make_lagged_matrix <- function(values, lag = 5) {
  if (length(values) <= lag) {
    stop("LSTM training requires more observations than the lag length.")
  }

  starts <- seq_len(length(values) - lag)
  x <- vapply(starts, function(i) values[i:(i + lag - 1)], numeric(lag))
  y <- values[(lag + 1):length(values)]

  list(
    x = array(t(x), dim = c(length(starts), lag, 1)),
    y = array(y, dim = c(length(y), 1))
  )
}

fit_lstm_difference_model <- function(training_values, lag = 5, epochs = 80, batch_size = 4, seed = 123) {
  if (!lstm_backend_status()$lstm_available) {
    stop("TensorFlow backend is not available for LSTM fitting.")
  }

  differenced_values <- diff(training_values)
  min_value <- min(differenced_values)
  max_value <- max(differenced_values)
  value_range <- max_value - min_value
  if (isTRUE(all.equal(value_range, 0))) {
    return(list(
      constant_difference = tail(differenced_values, 1),
      min_value = min_value,
      value_range = value_range,
      lag = lag,
      model = NULL
    ))
  }

  scaled_values <- (differenced_values - min_value) / value_range
  lagged <- make_lagged_matrix(scaled_values, lag = lag)

  tf <- reticulate::import("tensorflow")
  tf$random$set_seed(as.integer(seed))
  model <- tf$keras$Sequential(list(
    tf$keras$layers$Input(shape = reticulate::tuple(as.integer(lag), 1L)),
    tf$keras$layers$LSTM(units = 8L),
    tf$keras$layers$Dense(units = 1L)
  ))
  optimizer <- try(tf$keras$optimizers$legacy$Adam(learning_rate = 0.01), silent = TRUE)
  if (inherits(optimizer, "try-error")) {
    optimizer <- tf$keras$optimizers$Adam(learning_rate = 0.01)
  }
  model$compile(optimizer = optimizer, loss = "mse")
  model$fit(
    x = lagged$x,
    y = lagged$y,
    epochs = as.integer(epochs),
    batch_size = as.integer(batch_size),
    verbose = 0L
  )

  list(
    constant_difference = NA_real_,
    min_value = min_value,
    value_range = value_range,
    lag = lag,
    model = model
  )
}

predict_lstm_next_level <- function(model_info, history_values) {
  if (is.null(model_info$model)) {
    return(tail(history_values, 1) + model_info$constant_difference)
  }

  differenced_values <- diff(history_values)
  scaled_values <- (differenced_values - model_info$min_value) / model_info$value_range
  next_x <- array(tail(scaled_values, model_info$lag), dim = c(1, model_info$lag, 1))
  scaled_prediction <- as.numeric(model_info$model$predict(next_x, verbose = 0L))
  predicted_difference <- model_info$min_value + scaled_prediction * model_info$value_range
  tail(history_values, 1) + predicted_difference
}

fit_lstm_one_step <- function(training_values, lag = 5, epochs = 80, batch_size = 4, seed = 123) {
  model_info <- fit_lstm_difference_model(
    training_values, lag = lag, epochs = epochs,
    batch_size = batch_size, seed = seed
  )
  predict_lstm_next_level(model_info, training_values)
}

forecast_lstm_with_residual_interval <- function(
    training_values, forecast_years, residuals, lag = 5, epochs = 80,
    batch_size = 4, seed = 123, level = 0.95) {
  model_info <- fit_lstm_difference_model(
    training_values, lag = lag, epochs = epochs,
    batch_size = batch_size, seed = seed
  )

  history <- training_values
  point_forecasts <- numeric(length(forecast_years))
  for (i in seq_along(forecast_years)) {
    point_forecasts[i] <- predict_lstm_next_level(model_info, history)
    history <- c(history, point_forecasts[i])
  }

  residuals <- residuals[is.finite(residuals)]
  alpha <- 1 - level
  if (length(residuals) >= 2) {
    residual_quantiles <- as.numeric(quantile(
      residuals, probs = c(alpha / 2, 1 - alpha / 2), na.rm = TRUE,
      names = FALSE
    ))
  } else {
    residual_sd <- stats::sd(residuals, na.rm = TRUE)
    if (!is.finite(residual_sd) || residual_sd == 0) residual_sd <- 0
    residual_quantiles <- stats::qnorm(c(alpha / 2, 1 - alpha / 2), sd = residual_sd)
  }

  horizon_scale <- sqrt(seq_along(forecast_years))
  tibble(
    year = forecast_years,
    forecast = point_forecasts,
    lower_95 = pmax(0, point_forecasts + residual_quantiles[1] * horizon_scale),
    upper_95 = pmax(0, point_forecasts + residual_quantiles[2] * horizon_scale),
    interval_method = "LSTM validation-residual interval"
  )
}

compare_headline_forecast_models <- function(
    rates, initial_end_year = 2014, lag = 5, lstm_epochs = 10) {
  headline <- rates %>%
    filter(
      location_name == "Sub-Saharan Africa",
      cause_name == "Diabetes mellitus",
      sex_name == "Both"
    ) %>%
    arrange(factor(measure_name, levels = measure_levels), year)

  backend <- lstm_backend_status()

  errors <- headline %>%
    group_by(measure_name) %>%
    group_modify(~ {
      series <- arrange(.x, year)
      origins <- initial_end_year:(max(series$year) - 1)

      bind_rows(lapply(origins, function(origin) {
        training <- filter(series, year <= origin)
        actual <- series$val[series$year == origin + 1]
        y <- ts(training$val, start = min(training$year), frequency = 1)
        naive_scale <- mean(abs(diff(training$val)))

        predictions <- tibble(
          model = c("ARIMA", "ETS"),
          predicted = c(
            as.numeric(forecast(auto.arima(y), h = 1)$mean[1]),
            as.numeric(forecast(ets(y), h = 1)$mean[1])
          )
        )

        if (backend$lstm_available) {
          predictions <- bind_rows(
            predictions,
            tibble(
              model = "LSTM",
              predicted = fit_lstm_one_step(
                training$val, lag = lag, epochs = lstm_epochs,
                seed = 1000 + origin + match(.y$measure_name, measure_levels)
              )
            )
          )
        }

        predictions %>%
          mutate(
            validation_year = origin + 1,
            actual = actual,
            scale = naive_scale
          )
      }))
    }) %>%
    ungroup()

  accuracy <- errors %>%
    group_by(measure_name, model) %>%
    summarise(
      rmse = sqrt(mean((actual - predicted)^2)),
      mae = mean(abs(actual - predicted)),
      mape = mean(abs((actual - predicted) / actual)) * 100,
      mase = mean(abs(actual - predicted)) / mean(scale),
      validation_years = n(),
      .groups = "drop"
    ) %>%
    group_by(measure_name) %>%
    mutate(selected = model == model[which.min(mase)]) %>%
    ungroup()

  if (!backend$lstm_available) {
    accuracy <- accuracy %>%
      bind_rows(
        distinct(headline, measure_name) %>%
          mutate(
            model = "LSTM",
            rmse = NA_real_,
            mae = NA_real_,
            mape = NA_real_,
            mase = NA_real_,
            validation_years = 0L,
            selected = FALSE
          )
      )
  }

  list(
    backend = backend,
    accuracy = accuracy,
    errors = errors
  )
}

generate_headline_selected_forecasts <- function(
    rates, headline_accuracy, headline_errors, forecast_end_year = 2030,
    lag = 5, lstm_epochs = 10) {
  headline <- rates %>%
    filter(
      location_name == "Sub-Saharan Africa",
      cause_name == "Diabetes mellitus",
      sex_name == "Both"
    ) %>%
    arrange(factor(measure_name, levels = measure_levels), year)

  selected_models <- headline_accuracy %>%
    filter(selected) %>%
    select(measure_name, selected_model = model)

  headline %>%
    group_by(measure_name) %>%
    group_modify(~ {
      series <- arrange(.x, year)
      selected_model <- selected_models$selected_model[
        selected_models$measure_name == .y$measure_name
      ][1]
      forecast_years <- (max(series$year) + 1):forecast_end_year

      if (selected_model == "LSTM") {
        residuals <- headline_errors %>%
          filter(measure_name == .y$measure_name, model == "LSTM") %>%
          transmute(residual = actual - predicted) %>%
          pull(residual)

        forecast_lstm_with_residual_interval(
          series$val,
          forecast_years = forecast_years,
          residuals = residuals,
          lag = lag,
          epochs = lstm_epochs,
          seed = 9000 + match(.y$measure_name, measure_levels)
        ) %>%
          mutate(selected_model = selected_model)
      } else {
        y <- ts(series$val, start = min(series$year), frequency = 1)
        model <- if (selected_model == "ARIMA") auto.arima(y) else ets(y)
        prediction <- forecast(model, h = length(forecast_years), level = 95)

        tibble(
          year = forecast_years,
          forecast = as.numeric(prediction$mean),
          lower_95 = as.numeric(prediction$lower[, "95%"]),
          upper_95 = as.numeric(prediction$upper[, "95%"]),
          interval_method = paste(selected_model, "model prediction interval"),
          selected_model = selected_model
        )
      }
    }) %>%
    ungroup() %>%
    mutate(
      location_name = "Sub-Saharan Africa",
      cause_name = "Diabetes mellitus",
      sex_name = "Both"
    ) %>%
    relocate(location_name, measure_name, cause_name, sex_name, selected_model)
}

read_location_gbd <- function(path, location_name, expected_age, expected_metric) {
  if (!file.exists(path)) {
    return(NULL)
  }

  data <- read_csv(path, show_col_types = FALSE) %>%
    filter(.data$location_name == location_name, .data$year %in% 1990:2023)

  missing_columns <- setdiff(required_gbd_columns, names(data))
  if (length(missing_columns) > 0) {
    stop("Missing required columns in ", path, ": ", paste(missing_columns, collapse = ", "))
  }

  key <- c("measure_id", "location_id", "sex_id", "age_id", "cause_id", "metric_id", "year")
  checks <- c(
    location_present = nrow(data) > 0,
    expected_age = identical(unique(data$age_name), expected_age),
    expected_metric = identical(unique(data$metric_name), expected_metric),
    complete_years = setequal(data$year, 1990:2023),
    no_duplicate_keys = !anyDuplicated(data[key]),
    no_missing_values = !anyNA(data[required_gbd_columns]),
    valid_bounds = all(data$lower <= data$val & data$val <= data$upper)
  )
  if (!all(checks)) {
    stop(
      "Input validation failed for ", location_name, " in ", path, ": ",
      paste(names(checks)[!checks], collapse = ", ")
    )
  }
  data
}

endpoint_summary <- function(data) {
  data %>%
    filter(year %in% c(1990, 2023)) %>%
    select(measure_name, cause_name, sex_name, metric_name, year, value = val, lower, upper) %>%
    pivot_wider(
      names_from = year,
      values_from = c(value, lower, upper),
      names_glue = "{.value}_{year}"
    ) %>%
    mutate(
      absolute_change = value_2023 - value_1990,
      relative_change_pct = 100 * (value_2023 / value_1990 - 1)
    ) %>%
    arrange(factor(measure_name, levels = measure_levels), cause_name, sex_name)
}

log_linear_trends <- function(data) {
  data %>%
    group_by(measure_name, cause_name, sex_name, metric_name) %>%
    group_modify(~ {
      model <- lm(log(val) ~ year, data = .x)
      beta <- coef(model)[["year"]]
      beta_ci <- confint(model, "year", level = 0.95)
      tibble(
        annual_change_pct = 100 * (exp(beta) - 1),
        lower_ci = 100 * (exp(beta_ci[1]) - 1),
        upper_ci = 100 * (exp(beta_ci[2]) - 1),
        p_value = summary(model)$coefficients["year", "Pr(>|t|)"],
        adjusted_r_squared = summary(model)$adj.r.squared
      )
    }) %>%
    ungroup() %>%
    arrange(factor(measure_name, levels = measure_levels), cause_name, sex_name)
}

sex_rate_ratios <- function(rates) {
  rates %>%
    filter(year %in% c(1990, 2023), sex_name %in% c("Male", "Female")) %>%
    select(measure_name, cause_name, year, sex_name, val) %>%
    pivot_wider(names_from = sex_name, values_from = val) %>%
    mutate(male_to_female_rate_ratio = Male / Female) %>%
    arrange(factor(measure_name, levels = measure_levels), cause_name, year)
}

diabetes_type_shares <- function(counts) {
  counts %>%
    filter(year %in% c(1990, 2023), sex_name == "Both") %>%
    select(measure_name, cause_name, year, val) %>%
    pivot_wider(names_from = cause_name, values_from = val) %>%
    mutate(
      t1dm_share_pct = 100 * `Diabetes mellitus type 1` / `Diabetes mellitus`,
      t2dm_share_pct = 100 * `Diabetes mellitus type 2` / `Diabetes mellitus`,
      component_sum_difference_pct = 100 * (
        `Diabetes mellitus type 1` + `Diabetes mellitus type 2` - `Diabetes mellitus`
      ) / `Diabetes mellitus`
    )
}

yll_yld_ratio <- function(counts) {
  counts %>%
    filter(
      cause_name == "Diabetes mellitus", sex_name == "Both",
      measure_name %in% c("YLLs (Years of Life Lost)", "YLDs (Years Lived with Disability)")
    ) %>%
    select(year, measure_name, val) %>%
    pivot_wider(names_from = measure_name, values_from = val) %>%
    transmute(
      year,
      yll_count = .data[["YLLs (Years of Life Lost)"]],
      yld_count = .data[["YLDs (Years Lived with Disability)"]],
      yll_to_yld_ratio = yll_count / yld_count
    )
}

plot_rate_trends <- function(rates, location_name) {
  plot_data <- rates %>%
    filter(cause_name == "Diabetes mellitus", sex_name == "Both") %>%
    mutate(measure = factor(recode(measure_name, !!!measure_short), levels = unname(measure_short)))

  ggplot(plot_data, aes(year, val)) +
    geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#D9EAF3", color = NA) +
    geom_line(color = "#0072B2", linewidth = 0.55) +
    facet_wrap(~ measure, scales = "free_y", ncol = 3) +
    scale_x_continuous(breaks = c(1990, 2000, 2010, 2020)) +
    scale_y_continuous(labels = label_number(big.mark = ",", accuracy = 1)) +
    labs(
      title = "Age-standardized diabetes burden, 1990-2023",
      subtitle = paste(location_name, "both sexes, total diabetes mellitus"),
      x = NULL, y = "Rate per 100,000",
      caption = "Shading indicates 95% uncertainty intervals. Source: GBD 2023."
    ) +
    theme_minimal(base_size = 9) +
    theme(panel.grid.minor = element_blank(), strip.text = element_text(face = "bold"))
}

plot_yll_yld <- function(ratio, location_name) {
  ggplot(ratio, aes(year, yll_to_yld_ratio)) +
    geom_line(color = "#D55E00", linewidth = 0.7) +
    geom_point(data = filter(ratio, year %in% c(1990, 2000, 2010, 2020, 2023)),
               color = "#D55E00", size = 1.5) +
    labs(
      title = "Mortality-to-disability transition, 1990-2023",
      subtitle = paste(location_name, "both sexes, total diabetes mellitus"),
      x = NULL, y = "YLL-to-YLD ratio", caption = "Ratio calculated from all-age counts."
    ) +
    theme_minimal(base_size = 9) +
    theme(panel.grid.minor = element_blank())
}

generate_rate_forecasts <- function(rates, initial_end_year = 2004, forecast_end_year = 2030) {
  strata <- rates %>%
    distinct(measure_name, cause_name, sex_name) %>%
    arrange(measure_name, cause_name, sex_name)
  accuracy_results <- vector("list", nrow(strata))
  forecast_results <- vector("list", nrow(strata))

  for (i in seq_len(nrow(strata))) {
    stratum <- strata[i, ]
    series <- rates %>%
      semi_join(stratum, by = c("measure_name", "cause_name", "sex_name")) %>%
      arrange(year)
    origins <- initial_end_year:(max(series$year) - 1)
    errors <- lapply(origins, function(origin) {
      training <- filter(series, year <= origin)
      actual <- series$val[series$year == origin + 1]
      y <- ts(training$val, start = min(training$year), frequency = 1)
      scale <- mean(abs(diff(training$val)))
      tibble(
        model = c("ARIMA", "ETS"),
        actual = actual,
        predicted = c(
          as.numeric(forecast(auto.arima(y), h = 1)$mean[1]),
          as.numeric(forecast(ets(y), h = 1)$mean[1])
        ),
        scale = scale
      )
    }) %>% bind_rows()

    accuracy <- errors %>%
      group_by(model) %>%
      summarise(
        rmse = sqrt(mean((actual - predicted)^2)),
        mae = mean(abs(actual - predicted)),
        mape = mean(abs((actual - predicted) / actual)) * 100,
        mase = mean(abs(actual - predicted)) / mean(scale),
        .groups = "drop"
      )
    selected_model <- accuracy$model[which.min(accuracy$mase)]
    y <- ts(series$val, start = min(series$year), frequency = 1)
    model <- if (selected_model == "ARIMA") auto.arima(y) else ets(y)
    prediction <- forecast(model, h = forecast_end_year - max(series$year), level = 95)

    accuracy_results[[i]] <- accuracy %>%
      mutate(
        measure_name = stratum$measure_name,
        cause_name = stratum$cause_name,
        sex_name = stratum$sex_name,
        selected = model == selected_model
      ) %>%
      relocate(measure_name, cause_name, sex_name)
    forecast_results[[i]] <- tibble(
      measure_name = stratum$measure_name,
      cause_name = stratum$cause_name,
      sex_name = stratum$sex_name,
      selected_model = selected_model,
      year = (max(series$year) + 1):forecast_end_year,
      forecast = as.numeric(prediction$mean),
      lower_95 = as.numeric(prediction$lower[, "95%"]),
      upper_95 = as.numeric(prediction$upper[, "95%"])
    )
  }

  list(accuracy = bind_rows(accuracy_results), forecasts = bind_rows(forecast_results))
}

plot_rate_forecasts <- function(rates, forecasts, location_name) {
  observed <- rates %>%
    filter(cause_name == "Diabetes mellitus", sex_name == "Both") %>%
    transmute(
      measure_name, year, value = val, lower = NA_real_, upper = NA_real_,
      series = "Observed"
    )
  projected <- forecasts %>%
    filter(cause_name == "Diabetes mellitus", sex_name == "Both") %>%
    transmute(
      measure_name, year, value = forecast, lower = lower_95, upper = upper_95,
      series = "Forecast"
    )
  plot_data <- bind_rows(observed, projected) %>%
    mutate(measure = factor(recode(measure_name, !!!measure_short), levels = unname(measure_short)))

  ggplot(plot_data, aes(year, value, color = series)) +
    geom_ribbon(
      data = filter(plot_data, series == "Forecast"),
      aes(ymin = lower, ymax = upper), fill = "#F6D7B0", color = NA, inherit.aes = TRUE
    ) +
    geom_line(linewidth = 0.55) +
    geom_vline(xintercept = 2023.5, linewidth = 0.3, linetype = "dashed") +
    facet_wrap(~ measure, scales = "free_y", ncol = 3) +
    scale_color_manual(values = c(Observed = "#0072B2", Forecast = "#D55E00")) +
    scale_x_continuous(breaks = c(1990, 2000, 2010, 2020, 2030)) +
    scale_y_continuous(labels = label_number(big.mark = ",", accuracy = 1)) +
    labs(
      title = "Observed and forecast age-standardized rates",
      subtitle = paste(location_name, "both sexes, total diabetes mellitus"),
      x = NULL, y = "Rate per 100,000", color = NULL,
      caption = "Forecast intervals represent model uncertainty only."
    ) +
    theme_minimal(base_size = 9) +
    theme(panel.grid.minor = element_blank(), legend.position = "bottom")
}

format_report_table <- function(
    data, caption, digits = 2, max_rows = 60, landscape = FALSE,
    font_size = if (landscape) "scriptsize" else "footnotesize") {
  shown <- head(data, max_rows)
  numeric_columns <- vapply(shown, is.numeric, logical(1))
  shown[numeric_columns] <- lapply(shown[numeric_columns], round, digits = digits)
  table <- kable(
    shown, format = "latex", booktabs = TRUE, longtable = TRUE,
    caption = caption, escape = TRUE
  )
  table <- paste0(
    "\\begingroup\n\\", font_size,
    "\n\\setlength{\\tabcolsep}{3pt}\n",
    table,
    "\n\\endgroup"
  )
  if (landscape) {
    table <- paste0("\\begin{landscape}\n", table, "\n\\end{landscape}")
  }
  table
}

availability_table <- function(rates, counts, age_counts_path, age_rates_path) {
  tibble(
    input = c(
      "Age-standardized rates", "All-age counts",
      "Age-specific counts", "Age-specific rates"
    ),
    status = c(
      if (is.null(rates)) "MISSING" else "AVAILABLE",
      if (is.null(counts)) "MISSING" else "AVAILABLE",
      if (file.exists(age_counts_path)) "AVAILABLE" else "MISSING",
      if (file.exists(age_rates_path)) "AVAILABLE" else "MISSING"
    ),
    enabled_analysis = c(
      "Endpoints, trends, sex ratios, rate forecasts",
      "Count endpoints, type shares, YLL-to-YLD ratio",
      "Decomposition, APC, population reconstruction",
      "Decomposition, APC, count projections"
    )
  )
}
