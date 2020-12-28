
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PSEIpullr

<!-- badges: start -->

<!-- badges: end -->

PSEIpullr is an R package that can be used to quickly pull prices of stocks listed in the Philippine
Stock Exchange via the pselookup API.

## Installation

You can install the released version of PSEIpullr from
[CRAN](https://CRAN.R-project.org) with:

``` r
install_github("CoconutMartin/PSEIpullr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(PSEIpullr)

system.time(
  ac <- get_historical_price(ticker = "AC", type = "close", start_date = "2020-01-01", end_date = "2020-02-01")
)
#> Loading required namespace: dplyr
#>    user  system elapsed 
#>    0.57    0.07    2.11

head(ac)
#>         Date    AC
#> 1 2020-01-02 770.0
#> 2 2020-01-03 776.0
#> 3 2020-01-06 785.0
#> 4 2020-01-07 800.0
#> 5 2020-01-08 790.0
#> 6 2020-01-09 794.5
```
