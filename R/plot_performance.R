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
    dplyr::mutate(key = factor(.data$key, levels = c("Portfolio Returns", "Drawdown", "Total Gains", "Daily Gains", "Total Equity"))) %>%
    dplyr::group_by(.data$key) %>%
    dplyr::do(
      p =
        plotly::plot_ly(.data, x = ~Date, y = ~value) %>%
        plotly::add_trace(name = ~key, color = ~key, type = "scatter", mode = "lines", fill = "tozeroy") %>%
        plotly::layout(
          title = list(text = "<b>Portfolio Tracker</b>", x = 0.53, font = list(size = 15)),
          yaxis = list(title = ""),
          xaxis = list(title = ""),
          legend = list(orientation = "h", y = -0.1, x = 0.5, xanchor = "center")
        ) %>%
        plotly::add_annotations(
          text = ~unique(key),
          textangle = -90,
          x = -0.1,
          y = 0.475,
          yref = "paper",
          xref = "paper",
          yanchor = "middle",
          xanchor = "middle",
          showarrow = FALSE,
          font = list(size = 12, color = "rgba(255,255,255,255)")
        )
    ) %>%
    plotly::subplot(nrows = 5, shareX = TRUE, shareY = FALSE, titleY = TRUE)

  return(plt)
}

