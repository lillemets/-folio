---
title: "Match as an alternative to merge in R"
bibliography: '/home/jrl/text/library.bib'
description: "While 'merge' function is the most straightforward solution to joining datasets by a common variable in R, sometimes 'match' is more intuitive."
---



One of the most common operations in data wrangling is joining two sets of data by a common variable. Probably the most popular method for this is the obscure `vlookup` function in Excel. The closest alternative in base R is `merge` and the dplyr package contains the join function family which is even more convenient. But there is a more simple and direct solution when only one variable needs to be added to a dataset. 

Suppose we have two data frames, `df.a` and `df.b`, and we wish to get the values of `other.var` from `df.a` into `df.b` so that each `id` gets their "own" value. There are [various methods for matching](https://www.google.ee/search?q=data+join), each yielding a different result. But in my experience *left join* on a single variable is the most frequent and this is what we will explore here.


{% highlight r %}
df.a <- data.frame(id = sample(LETTERS, 10), 
                   some.var = rnorm(10))
df.a
{% endhighlight %}



{% highlight text %}
##    id    some.var
## 1   A -0.30753013
## 2   G  0.52942481
## 3   C -1.58802498
## 4   O -1.21155294
## 5   W  0.75805474
## 6   K  0.06443588
## 7   N -1.28739832
## 8   B -1.00321026
## 9   D  0.53993478
## 10  Z -0.89160754
{% endhighlight %}



{% highlight r %}
df.b <- data.frame(id = sample(LETTERS, 20), 
                   other.var = runif(20, 1, 100))
df.b
{% endhighlight %}



{% highlight text %}
##    id other.var
## 1   T 45.116014
## 2   Q 41.357905
## 3   R 42.937294
## 4   W 95.854753
## 5   K 26.450341
## 6   S 46.582760
## 7   Y  1.883776
## 8   Z 33.331817
## 9   N  9.302005
## 10  I 97.389496
## 11  A 60.459523
## 12  F 77.252764
## 13  U 50.964749
## 14  V 58.699779
## 15  D 76.791869
## 16  B 44.080232
## 17  J 92.115602
## 18  C 72.003648
## 19  X 48.524804
## 20  P 32.561747
{% endhighlight %}

# Left join with 'merge'

When using `merge`, we specify the arguments of the function, run it and then through some *magic* a new dataset with requested columns is created. Note that we don't need to specify by which variable we wish to merge if variable names are the same.


{% highlight r %}
df.merge <- merge(df.a, df.b, all.x = T, all.y = F)
df.merge
{% endhighlight %}



{% highlight text %}
##    id    some.var other.var
## 1   A -0.30753013 60.459523
## 2   B -1.00321026 44.080232
## 3   C -1.58802498 72.003648
## 4   D  0.53993478 76.791869
## 5   G  0.52942481        NA
## 6   K  0.06443588 26.450341
## 7   N -1.28739832  9.302005
## 8   O -1.21155294        NA
## 9   W  0.75805474 95.854753
## 10  Z -0.89160754 33.331817
{% endhighlight %}

# Left join with 'match'

A more hands-on approach involves first figuring out which rows in `df.b` correspond to which rows in `df.a` according to `id`. The `match` function allows us to do just that.


{% highlight r %}
match(df.a$id, df.b$id)
{% endhighlight %}



{% highlight text %}
##  [1] 11 NA 18 NA  4  5  9 16 15  8
{% endhighlight %}

Now that we have the row numbers, we can simply return `other.var` in `df.b` where the matches occur. A useful side effect is that we can define the name for the new variable while matching.


{% highlight r %}
df.a$other.var <- df.b$other.var[match(df.a$id, df.b$id)]
{% endhighlight %}

Now let's compare the results.


{% highlight r %}
df.merge
{% endhighlight %}



{% highlight text %}
##    id    some.var other.var
## 1   A -0.30753013 60.459523
## 2   B -1.00321026 44.080232
## 3   C -1.58802498 72.003648
## 4   D  0.53993478 76.791869
## 5   G  0.52942481        NA
## 6   K  0.06443588 26.450341
## 7   N -1.28739832  9.302005
## 8   O -1.21155294        NA
## 9   W  0.75805474 95.854753
## 10  Z -0.89160754 33.331817
{% endhighlight %}



{% highlight r %}
df.a
{% endhighlight %}



{% highlight text %}
##    id    some.var other.var
## 1   A -0.30753013 60.459523
## 2   G  0.52942481        NA
## 3   C -1.58802498 72.003648
## 4   O -1.21155294        NA
## 5   W  0.75805474 95.854753
## 6   K  0.06443588 26.450341
## 7   N -1.28739832  9.302005
## 8   B -1.00321026 44.080232
## 9   D  0.53993478 76.791869
## 10  Z -0.89160754 33.331817
{% endhighlight %}

We can see that the result is essentially the same. What `merge` has done is rearranged the rows which is something we might not want to happen. So I encourage the use of `match` when possible since it allows the addition of a single column without running a function over entire data sets.
