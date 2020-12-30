#' A function creating a portfolio tracker by combining a list of stocks
#'
#' @param ... stock data frame to be combined; stock position output from position_tracker
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export

portfolio_tracker <- function(...) {
  stock_list <- list(...)
  portfolio <- purrr::reduce(stock_list, dplyr::bind_rows)

  portfolio_tracker <- portfolio %>%
    dplyr::group_by(.data$Date) %>%
    # Summarize portfolio values
    dplyr::summarise(
      total_deposits = sum(.data$deposit, na.rm = TRUE),
      total_cash = sum(.data$cash), # negative cash balance indicates margin usage
      total_position = sum(.data$position_size, na.rm = TRUE), # total position at cost
      total_ending_position = sum(.data$final_position, na.rm = TRUE), # total position at closing price
      total_equity = sum(.data$total_equity, na.rm = TRUE), # total ending position and total cash
    ) %>%
    dplyr::ungroup() %>%
    # Calculate portfolio performance
    dplyr::mutate(
      total_gains = .data$total_ending_position - .data$total_position, # cumulative daily portfolio gains
      daily_gains = c(NA, diff(.data$total_gains)), # daily portfolio nominal gains
      daily_gains = ifelse(is.na(.data$daily_gains), .data$total_gains, .data$daily_gains),
      total_portfolio_return = .data$total_gains / .data$total_deposits, # cumulative portfolio pct return based on total equity infusion
      total_daily_return = c(NA, diff(.data$total_portfolio_return)), # daily portfolio pct return
      total_daily_return = ifelse(is.na(.data$total_daily_return), .data$total_portfolio_return, .data$total_daily_return),
      drawdown = .data$total_portfolio_return - cummax(.data$total_portfolio_return),

      # For plotting only
      total_portfolio_return = .data$total_portfolio_return * 100,
      drawdown = .data$drawdown * 100
    )

  return(portfolio_tracker)
}

