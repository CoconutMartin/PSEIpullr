
#' A function to generate a data frame of a stock position
#' @param position_tracker function to generate a data frame of a stock position
#' @param ticker stock ticker
#' @param deposit cash deposit
#' @param shares number of shares bought / sold
#' @param start_date purchase date
#' @param buying_price buying price
#' @param selling_price selling price
#' @param selling_date selling date
#' @param industry industry type
#' @param listing listing type
#'
#' @export

# Declare global variables


######## Setup function for tracking stock positions
position_tracker <- function(deposit = 0,
                             ticker = "ticker",
                             shares = as.numeric(0),
                             buying_price = as.numeric(0),
                             start_date = "yyyy-mm-dd",
                             selling_price = as.numeric(0),
                             selling_date = "3000-01-01", # placeholder for selling date to avoid code error for open positions
                             industry = "",
                             listing = c("Index", "Non-Index")) {

  requireNamespace(c("dplyr", "lubridate", "tidyr", "stats"))

  end_date <- lubridate::today()

  # create portfolio data frame
  stx_position <- data.frame(Date = lubridate::ymd(start_date), ticker = ticker, shares = shares, buying_price = buying_price)

  # Pull historical stock price
  stx <- get_historical_price(ticker, type = "close",
                              start_date = start_date,
                              end_date = end_date)
  stx <- tidyr::gather(stx, stx$ticker, stx$closing_price, -stx$Date)

  # Summarize stock position
  stx_position <- dplyr::bind_rows(stx_position, stx)
  stx_postion <- tidyr::fill(stx_position, c(shares, buying_price), .direction = "down")
  stx_postion <- stats::na.omit(stx_position)

  stx_position$selling_date <- lubridate::ymd(selling_date)
  stx_position$deposit <- deposit
  stx_position$position_size <- buying_price * shares
  stx_position$cash <- stx_position$deposit - stx_position$position_size
  stx_position$ending_position <- ifelse(stx_position$Date > selling_date, NA, stx_position$closing_price * shares)     # ending value of open position
  stx_position$closing_position <- ifelse(stx_position$Date >= selling_date & selling_date != lubridate::ymd("3000-01-01"), selling_price * shares, NA) # closing value of sold position
  stx_position$final_position <- ifelse(stx_position$Date >= selling_date, stx_position$closing_position, stx_position$ending_position) # final value of position
  stx_position$total_equity <- stx_position$final_position + stx_position$cash
  stx_position$industry <- industry
  stx_position$listing <- listing

  return(stx_position)

}
