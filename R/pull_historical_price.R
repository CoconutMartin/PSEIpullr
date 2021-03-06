#' Pull stock prices via pselookup API
#'
#' A function to pull single stock prices listed in the Philippine Stock Exchange via pselookup API
#' @aliases historical_price_puller
#' @param pull_historical_price function to pull stock prices
#' @param ticker stock ticker to pull
#' @param type type of price to pull
#' @param start_date start date of data pull
#' @param end_date end date of data pull
#' @return A data frame of stock prices
#'
#' @export

pull_historical_price <- function(ticker = "x",
                                  type = c("open", "high", "low", "close"),
                                  start_date = "yyyy-mm-dd",
                                  end_date = "yyyy-mm-dd") {

  price.json <- httr::GET(paste("https://pselookup.vrymel.com/api/stocks", ticker, "history", start_date = start_date, end_date = end_date, sep = "/"))
  price <- jsonlite::fromJSON(rawToChar(price.json$content))$history
  price <- price[, c("trading_date", type)]
  colnames(price) <- c("Date", ticker)
  price$Date <- lubridate::ymd(price$Date)

  return(price)
}
