library(data.table)

# data set
set.seed(1234)
homework <- data.table(accountID = sample(round(runif(700)*10e6), 25e5, replace=TRUE),
                       smsOut = round(abs(rnorm(25e5, 50, 100))),
                       smsIn = round(abs(rnorm(25e5, 50, 100))),
                       callsOut = round(abs(rnorm(25e5, 15, 20))),
                       callsIn = round(abs(rnorm(25e5, 15, 20))))
homework[, lifetime:=floor(accountID/10e3)]
homework[, age:=ceiling(accountID/15e4)]

# task 1
homework[age < 18, list(accountID, callsOut)]

# task 2
homework[age %in% c(20:25), list(avgSmsOut=mean(smsOut), avgCallsOut=mean(callsOut)), by=age]

# task 3
homework[, spending:=0.01*smsOut+0.07*callsOut]

# task 4
homework[spending < 0.5 & lifetime > 900, unique(accountID)]
