#' A function to perform basic portfolio analysis and plotting
#'
#' @param x summarized output of portfolio tracker
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export

plot_performance <- function(x) {

  plt <- x %>%
    dplyr::select(.data$Date, .data$total_deposits, .data$total_gains, .data$daily_gains, .data$total_portfolio_return, .data$drawdown) %>%
    stats::setNames(c("Date", "Total Equity", "Total Gains", "Daily Gains", "Portfolio Returns", "Drawdown")) %>%
    tidyr::gather("key", "value", -.data$Date) %>%
    dplyr::mutate(key = factor(.data$key, levels = c("Portfolio Returns", "Drawdown", "Daily Gains", "Total Gains", "Total Equity"))) %>%
    dplyr::group_by(.data$key) %>%
    dplyr::do(
      p =
        plotly::plot_ly(.data, x = ~Date, y = ~value) %>%
        plotly::add_trace(name = ~key, color = ~key, type = "scatter", mode = "lines", fill = "tozeroy") %>%
        plotly::layout(
          title = list(text = "<b>Portfolio Tracker</b>"),
          yaxis = list(title = ""),
          xaxis = list(title = ""),
          legend = list(orientation = "h", y = -0.1, x = 0.5, xanchor = "center")
        )
    ) %>%
    plotly::subplot(nrows = 5, shareX = TRUE, shareY = FALSE, titleY = TRUE)

  return(plt)
}

