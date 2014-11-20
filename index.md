How to solve 90 % of your data munging problems? Part II
========================================================
author: Adomas
date: 2014-11-21
autosize: true

Plan of workshop
========================================================

- Homework solutions
- Why and why not `data.table`?
- Notations of `data.table` in SQL terms
- Randomize a million rows data set
- Additional operations
- `fread` and fast joining
- HW

Homework solutions
========================================================

Solutions to **optional** ``dplyr`` homework could be found [here on Github.](https://github.com/adomasb/pres-dplyr/blob/gh-pages/solutions.R)

![alt text](HW.gif)


Why data.table?
========================================================

- `data.table` allows to play with enormous data sets, we are turning into *gigabytes level* from now on
- `data.table` works [**insanely** fast](https://github.com/Rdatatable/data.table/wiki/Benchmarks-%3A-Grouping)
- It could be combined with `dplyr` for convenient analysis
- It has excellent, fast and friendly file reader `fread`

Why not data.table?
=========================================================

- Extremely steep learning curve
- Code is harder to read when applying more sophisticated functions


One can choose what to use for particular tasks. 

Although, in overall analysis **I** am more likely to combine `data.table` and `dplyr`. 

It is up to **You**, what to use, but always try to make your code: **friendly**, **fast**, **reproducible** and **readable**.

data.table in SQL terms
=======================================================

Say ``DT`` is any ``data.table``. Each `data.table` has the following syntax of most important arguments:


```r
DT[i, j, by]
```

Which can be translated in SQL terms


```r
DT[WHERE, SELECT|UPDATE, GROUP BY]
```

Though ```i, j``` in `data.frame` are indeces, but in  `data.table` -- condition and column name.

Data set
=====================================================

We will use randomized data set with million of rows. It will be fictional sales data of fictional groceries store by fictional characters in fictional world.

But first load `data.table` library:



```r
library(data.table)
```

In case you do not have it yet, let remind you:


```r
install.packages("data.table")
```

Fictionalicous data set
================================================


```r
set.seed(1234)
data <- data.table(name=paste0(sample(letters, 10e5, replace = TRUE), sample(letters, 10e5, replace = TRUE)),
                   hour = round(runif(n = 10e5, min = 0,max = 23)),
                   minute = round(runif(n = 10e5, min = 1,max = 60)),
                   items = rpois(n = 10e5, lambda = 5),
                   sales = rpois(n = 10e5, lambda = 5)*rpois(n = 10e5, lambda = 10),
                   discount = round(runif(n = 10e5, min = 0, max = 0.7), 2))
```

Data set overview
===============================================

`data.table` is clever enough to print only few lines if asked, therefore we can see first and last 5 rows of data set by


```r
data
```

Sometimes we want to see short summary about our tables, which we have in enviroment rigth now, thus it can be done by


```r
tables()
```

We can see name, number of rows, size of table in MB, column names and keys.

Selecting 
===============================================

Selecting in `data.table` is second argument. Moreover, as in `dplyr` selection by column names is by default.

Though to select one column as vector, *eg*, names column


```r
data[, name]
```

However, if we want it select as `data.table`


```r
data[, list(name)]
```

Selecting 2
==============================================
title: FALSE

In case we want to select few columns, *eg*, hour and minute of purchase, then


```r
data[, list(hour, minute)]
```

**TASK:** Firstly, select discount as numeric vector and then as `data.table` object

Conditioning
==============================================

Condition should be added as first argument. If we want sales after after 20 hour


```r
data[hour > 20, ]
```

And, moreover, excatly on 50th minute


```r
data[hour > 20 & minute == 50, ]
```

OR can be used with `|`.

Conditioning 2
==============================================
title:FALSE

To select any columns with condition, just add coondition and state column name or names as second argument


```r
data[hour > 20 & minute == 50, list(sales)]
```

Note, that without `list()` we would get a numeric vector

**TASK:** Which persons and how many items bought on first two minutes of 5th hour without any discount?

Group by
============================================

Group by is done by specifying additional argument `by` with one or more columns. 

Group by without applying any function doesn't make any sense, thus let's calculate each hour average sales


```r
data[, mean(sales), by=hour]
```

If we want additionally give a name to column


```r
data[, list(avgSales=mean(sales)), by=hour]
```

Group by
============================================
title: FALSE

This could be extended to conditioning and different functions on different columns, moreover, grouping by different columns, for example, average sales and total items bought by cherry pickers during first two minutes of each hour


```r
data[minute <= 2 & discount > 0.5, list(avgSales=mean(sales), sumItems=sum(items)), by=list(hour, minute)]
```

**TASK:** How many items at maximum do cherry pickers (with discount bigger than 50%) buy and how much total sales generate during each minute of ten last minutes of an hour.

Additional options: adding new columns
==============================================

In case we would like to add additional column, *eg*, calculated discount value


```r
data[, discountValue:=sales*discount]
```

Or apply function over a column


```r
data[, discountValue:=round(discountValue, 1)]
```

**TASK:** Add column in which time of purchase would be written in seconds and call it `inSeconds`

Additional options: slicing by indeces
==============================================

If we want to select columns by indeces, then we additionally add argument `with=FALSE`. First two columns


```r
data[, 1:2, with=FALSE]
```

If we want select some rows by row index, indeces could be specified in `WHERE` or `i` argument, *eg*, 5 random rows of second and fourth column


```r
data[sample(10e5, 5), c(2, 4), with=FALSE]
```

**TASK:** Select rows with indices of your year, month and day of birth of last two columns

Additional options: setting names
==============================================

In some situations we would like to change or set names to some or all columns of `data.table`. This can be done with `setnames()`, let's change `discountValue` to `discountAmount`


```r
setnames(data, old = 'discountValue', new = 'discountAmount')
```


Additional options: keys
=============================================

In ``data.table`` new notation called `key` appears.

One or more ``data.table`` columns could be keys.

Keys could be interpreted as additional column names, but we will not consider this anymore. More info could be found [here on the first chapter.](http://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.pdf)

However, we will show how to use keys for fast table joins.

Additional options: fread
=============================================

`fread` is fast and friendly file reader which detects controls automatically.

Read accounts data


```r
accounts <- fread("your/location/to/file/accounts_info.csv")
```

Take a look at data and tables in your enviroment right now


```r
accounts
tables()
```

Additional options: joining
=============================================

Say, `X` and `Y` are two `data.tables`, both of them have column named `z`, which is a key in both tables.

Then joining `X` and `Y` on `z` could be done by


```r
X[Y]
```

Tables are always joined on keys, thus before joining keys must be set.

Moreover, one can join on multiple keys.

Additional options: joining
=============================================
title: FALSE

Assume, that each customer has unique name. Let's set `name` as keys in `data` and `accounts` `data.tables`.


```r
setkey(data, name)
setkey(accounts, name)
```

Then join both tables


```r
data[accounts]
```

One can see that table is sorted by key - `name` column.

Homework data set
=============================================

Fictional telco data


```r
set.seed(1234)
homework <- data.table(accountID = sample(round(runif(700)*10e6), 25e5, replace=TRUE),
                       smsOut = round(abs(rnorm(25e5, 50, 100))),
                       smsIn = round(abs(rnorm(25e5, 50, 100))),
                       callsOut = round(abs(rnorm(25e5, 15, 20))),
                       callsIn = round(abs(rnorm(25e5, 15, 20))))
homework[, lifetime:=floor(accountID/10e3)]
homework[, age:=ceiling(accountID/15e4)]
```

Don't forget to take a look at few lines and `tables()`!

Homework tasks 1
=============================================

**TASK 1:** Select account IDs and calls outgoing of customers who are not adults yet

**TASK 2:** How much customers who are aged between 20 and 25 send sms and calls on average. Name these values as you want

Homework tasks 2
=============================================


**TASK 3:** Assuming that SMS costs is 0.01 and minute of call costs 0.07, calculate spending and name it as `spending`

**TASK 4:** Select unique accountID which spent less than 0.5 and lifetime is higher than 900 and print it in vector
