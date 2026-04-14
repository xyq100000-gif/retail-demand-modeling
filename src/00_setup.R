required_pkgs <- c(
  "dplyr", "readr", "stringr", "tibble", "purrr", "tidyr",
  "MASS", "broom", "ggplot2"
)

missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_pkgs) > 0) {
  stop(
    "Please install these packages before running the project: ",
    paste(missing_pkgs, collapse = ", ")
  )
}

invisible(lapply(required_pkgs, library, character.only = TRUE))
theme_set(theme_bw(base_size = 11))
