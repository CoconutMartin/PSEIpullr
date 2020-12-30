#' A function to generate a data frame of multiple stock prices
#'
#' A function to pull multiple stock prices listed in the Philippine Stock Exchange via pselookup API
#' @param pull_multiple_prices function to pull multiple stock prices
#' @param tickers stock tickers to pull
#' @param type type of price to pull
#' @param start_date starting date of data pull
#' @param end_date ending date of data pull
#'
#' @export

pull_multiple_prices <- function(tickers,
                                 type = c("open", "high", "low", "close"),
                                 start_date = "yyyy-mm-dd",
                                 end_date = "yyyy-mm-dd") {

  future::plan(future::multisession)

  price_list <- future.apply::future_lapply(as.list(tickers), # as.list ensures input is of list type
                                            pull_historical_price,
                                            type = type,
                                            start_date = start_date,
                                            end_date = end_date)

  price_list <- purrr::discard(price_list, function(x) all(is.na(x)))

  price_list_all <- Reduce(function(x, y) merge(x, y, all = TRUE), price_list)

  future::plan(future::sequential)

  return(price_list_all)
}
