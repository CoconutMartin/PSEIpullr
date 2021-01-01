#' A function for tracking stock positions
#'
#' @param position_tracker function to generate a data frame of stock position/s
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
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @export

######## Setup function for tracking stock positions
position_tracker <- function(deposit = 0,
                             ticker = "ticker",
                             shares = 0,
                             buying_price = 0,
                             start_date = "yyyy-mm-dd",
                             selling_price = 0,
                             selling_date = "3000-01-01", # placeholder for selling date to avoid code error for open positions
                             industry = "",
                             listing = c("Index", "Non-Index")) {

  end_date <- lubridate::today()

  # Create portfolio data frame
  stx_position <- data.frame(Date = lubridate::ymd(start_date), ticker = ticker, shares = shares, buying_price = buying_price)

  # Pull historical stock price
  stx <- pull_historical_price(ticker,
                              type = "close",
                              start_date = start_date,
                              end_date = end_date)

  # Transform data frame to long form
  stx <- tidyr::gather(stx, "ticker", "closing_price", -.data$Date)

  # Summarize stock position
  stx_position <- dplyr::bind_rows(stx_position, stx)
  stx_position <- tidyr::fill(stx_position, c(shares, buying_price), .direction = "down")
  stx_position <- stats::na.omit(stx_position)
  stx_position$selling_date <- lubridate::ymd(selling_date)
  stx_position$deposit <- deposit
  stx_position$position_size <- buying_price * shares

  # Incorporate transaction fees in stock purchase
  stx_position$comm_vat <- (stx_position$position_size * 0.0025) * 1.12
  stx_position$pse_fee = stx_position$position_size * 0.00005
  stx_position$sccp_fee = stx_position$position_size * 0.0001
  stx_position$net_amount = stx_position$position_size + stx_position$comm_vat + stx_position$pse_fee + stx_position$sccp_fee
  stx_position$buying_price = stx_position$net_amount / stx_position$shares # average unit cost

  # Calculate ending/closing position
  stx_position$cash <- stx_position$deposit - stx_position$position_size
  stx_position$ending_position <- ifelse(stx_position$Date > selling_date, NA, stx_position$closing_price * shares) # ending value of open position

  # Incorporate transaction fees in stock sale

  stx_position$closing_position <- ifelse(stx_position$Date >= selling_date & selling_date != lubridate::ymd("3000-01-01"), selling_price * shares, NA) # closing value of sold position
  stx_position$comm_vat <- ifelse(stx_position$Date >= selling_date & selling_date != lubridate::ymd("3000-01-01"), (stx_position$closing_position * 0.0025) * 1.12, NA)
  stx_position$pse_fee <- ifelse(stx_position$Date >= selling_date & selling_date != lubridate::ymd("3000-01-01"), stx_position$closing_position * 0.00005, NA)
  stx_position$sccp_fee <- ifelse(stx_position$Date >= selling_date & selling_date != lubridate::ymd("3000-01-01"), stx_position$closing_position * 0.00001, NA)
  stx_position$sales_tax <- ifelse(stx_position$Date >= selling_date & selling_date != lubridate::ymd("3000-01-01"), stx_position$closing_position * 0.0061, NA)
  stx_position$closing_position <- ifelse(stx_position$Date >= selling_date & selling_date != lubridate::ymd("3000-01-01"),
                                          stx_position$closing_position - stx_position$comm_vat - stx_position$pse_fee - stx_position$sccp_fee - stx_position$sales_tax,
                                          NA)

  stx_position$closing_position <- ifelse(stx_position$Date == selling_date, selling_price * shares, NA)
  stx_position$comm_vat_s <- ifelse(stx_position$Date == selling_date, (stx_position$closing_position * 0.0025) * 1.12, NA)
  stx_position$pse_fee_s <- ifelse(stx_position$Date == selling_date, stx_position$closing_position * 0.00005, NA)
  stx_position$sccp_fee_s <- ifelse(stx_position$Date == selling_date, stx_position$closing_position * 0.00001, NA)
  stx_position$sales_tax <- ifelse(stx_position$Date == selling_date, stx_position$closing_position * 0.0061, NA)
  stx_position$closing_position <- ifelse(stx_position$Date == selling_date, stx_position$closing_position - stx_position$comm_vat_s - stx_position$pse_fee_s - stx_position$sccp_fee_s - stx_position$sales_tax, NA)


  # Determine final position and total equity
  stx_position$final_position <- ifelse(stx_position$Date >= selling_date, stx_position$closing_position, stx_position$ending_position) # final value of position
  stx_position$total_equity <- stx_position$final_position + stx_position$cash
  stx_position$industry <- industry
  stx_position$listing <- listing

  return(stx_position)

}
