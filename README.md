
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PSEIpullr

<!-- badges: start -->

<!-- badges: end -->

PSEIpullr is used to pull stock prices of companies listed in the
Philippine Stock Exchange via the pselookup API as well as to track
portfolio performance. This project was inspired by the lack of
available package(s) that can be used to efficiently pull local stock
prices.

Massive thanks to Vrymel for maintaining the API. Interested parties can
visit his/her website at <https://pselookup.vrymel.com/about>.

Disclaimer: As the package uses a third-party API, PSEIpullr cannot
guarantee data accuracy pulled by the package. PSEIpullr also makes no
warranties, representations, statements, or guarantees (whether express,
implied in law or residual) regarding the package. The output of the
package is simply for monitoring purposes and is not intended to provide
investment advice.

## Installation

You can install the released version of PSEIpullr from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("PSEIpullr")
```

## Example

This is a basic example which shows how to pull prices of stocks listed
in the Philippine Stock Market:

``` r
library(PSEIpullr)

system.time(
  ac <- pull_historical_price(ticker = "AC", type = "close", start_date = "2020-01-01", end_date = "2020-02-01")
)
#>    user  system elapsed 
#>    0.36    0.00    1.65

head(ac)
#>         Date    AC
#> 1 2020-01-02 770.0
#> 2 2020-01-03 776.0
#> 3 2020-01-06 785.0
#> 4 2020-01-07 800.0
#> 5 2020-01-08 790.0
#> 6 2020-01-09 794.5
```

The next function allows for simplified pulling stock prices for
multiple stocks

``` r
system.time(
  multi_stock <- pull_multiple_prices(tickers = c("AC", "SM"), type = "close", start_date = "2020-01-01", end_date = "2020-12-28")
)
#>    user  system elapsed 
#>    0.19    0.11    4.72

head(multi_stock)
#>         Date    AC   SM
#> 1 2020-01-02 770.0 1039
#> 2 2020-01-03 776.0 1051
#> 3 2020-01-06 785.0 1040
#> 4 2020-01-07 800.0 1067
#> 5 2020-01-08 790.0 1055
#> 6 2020-01-09 794.5 1072
```

The package also allows for basic portfolio construction, analysis, and
plotting. Start by setting up a position using the position\_tracker
function before combining both positions to create a basic portfolio
data frame.

``` r
tictoc::tic()
  ac <- position_tracker(deposit = 1000000, 
                         ticker = "AC",   
                         start_date = "2020-01-02", 
                         shares = 1200, 
                         buying_price = 770, 
                         industry = "Conglomerate", 
                         listing = "Index", 
                         selling_price = 823, 
                         selling_date = "2020-11-30")
  
  sm <- position_tracker(deposit = 1000000, 
                         ticker = "SM", 
                         start_date = "2020-04-30", 
                         shares = 1300, 
                         buying_price = 746,    
                         industry = "Conglomerate", 
                         listing = "Index", 
                         selling_price = 1050, 
                         selling_date = "2020-12-28")
tictoc::toc()
#> 2.65 sec elapsed

basic.port <- portfolio_tracker(ac, sm)
print(basic.port)
#> # A tibble: 241 x 11
#>    Date       total_deposits total_cash total_position total_ending_po~
#>    <date>              <dbl>      <dbl>          <dbl>            <dbl>
#>  1 2020-01-02        1000000      76000         924000           924000
#>  2 2020-01-03        1000000      76000         924000           931200
#>  3 2020-01-06        1000000      76000         924000           942000
#>  4 2020-01-07        1000000      76000         924000           960000
#>  5 2020-01-08        1000000      76000         924000           948000
#>  6 2020-01-09        1000000      76000         924000           953400
#>  7 2020-01-10        1000000      76000         924000           954000
#>  8 2020-01-14        1000000      76000         924000           953400
#>  9 2020-01-15        1000000      76000         924000           948000
#> 10 2020-01-16        1000000      76000         924000           953400
#> # ... with 231 more rows, and 6 more variables: total_equity <dbl>,
#> #   total_gains <dbl>, daily_gains <dbl>, total_portfolio_return <dbl>,
#> #   total_daily_return <dbl>, drawdown <dbl>
```

The plot\_performance function allows quick plotting of portfolio
overtime as the portfolio\_tracker function has already done the (basis)
analysis of the portfolio.

``` r
plot_performance(basic.port)
#> Warning: `arrange_()` is deprecated as of dplyr 0.7.0.
#> Please use `arrange()` instead.
#> See vignette('programming') for more help
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_warnings()` to see where this warning was generated.
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />
