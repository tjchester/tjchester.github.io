---
layout: post
title: "Palindromic Prime Calculation"
description: "Describes some ruby code that can be used to generate palindromic primes."
category: HowTo
tags: [Ruby, Math]
image: 
  feature: layout-posts.jpg
comments: false
---

This post will dicuss palindromic prime numbers using ruby code. It will also discuss several refinements made to the original attempt to speed up the performance.

<!-- more -->

So what is a palindromic prime? Well, it is a number with two defining characteristics. One, it is a palindromic number which means that when the digits are written in reverse they match the original number. For example, the number *101* is palindromic. If we reverse the numbers *101* we still have the original number. Second, the number is a prime number. A prime number is only divisible by itself or the number one. For example, the number 2, 3, 5 and 7 are all prime numbers.

The first 10 palindromic primes are: 2, 3, 5, 7, 11, 101, 131, 151, 181, 191.

See also:

- [Palindromic prime](https://en.wikipedia.org/wiki/Palindromic_prime)
- [Palindromic number](https://en.wikipedia.org/wiki/Palindromic_number)
- [Prime number](https://en.wikipedia.org/wiki/Prime_number)

## Problem ##

For the purposes of this post, we will state our problem as the following:

> Create a function in Ruby that will return the first *n* palindromic primes out of the set of positive natural numbers between 2 and infinity.

## Palindromic Number Test ##

First we will need a function that can determine if a number is a palindrome or not. This is relatively straightforward in that we will compare the string representation of the number with is reverse string representation. If they match then we have a palindrome.

```ruby
def is_palindrome?(n)
  n.to_s == n.to_s.reverse
end
```

## Prime Number Test ##

Next we will need a funcation that can test for a prime number. Note that our function is going to implement a test for primality rather than generating a list of prime numbers. A prime number is defined as a positive number greater than one that is no positive divisors other than one and itself. This means that our function will successive divide our number by each number from 2 to one less than itself. If the number is divisible by one of those numbers then the remainder of the division will be zero. If we can reach our number without finding a lesser number that can divide our number and leave a remainder of zero then we have found a prime number.

```ruby
def is_prime?(n)
  2.upto(n-1).each do |x|
    return false if n % x == 0
  end
  true
end
```

## Getting Palindromic Primes ##

Finally, we will need a function that takes as input the number of palindromic primes that we would like as our result. The function will start at two and successively test for palindromic primes until we have found the requested number. This set will be returned as an array and the function will stop.

> Note this function should not be confused with a generator. Each time it is called it will start over with the number two and count upwards until the desired amount of primes is found.

```ruby
def palindromic_primes(n)
  2.upto(Float::INFINITY).lazy.map 
    { |x| x if (is_prime?(x) && is_palindrome?(x)) }.
       select { |x| x.is_a? Integer}.first(n)
end
```
> We are taking advantage of Ruby's *lazy* evaluation for the map function. Without this modification, Ruby would try to run through our sequence from two to infinity resulting in an infinite loop. [Enumberator::Lazy](http://ruby-doc.org/core-2.0.0/Enumerator/Lazy.html)

## Testing ##

To see how our code performs we are going to use the [**ruby-prof**](https://rubygems.org/gems/ruby-prof) gem to get a performance report.

    gem install ruby-prof

Assuming our script is going to look for the first 50 palindromic primes we would execute it as:

    $ ruby-prof ./palindromic_primes_v1.rb
    [2, 3, 5, 7, 11, 101, 131, 151, 181, 191, 313, 353, 373, 383, 727, 757,
     787, 797, 919, 929, 10301, 10501, 10601, 11311, 11411, 12421, 12721, 
     12821, 13331, 13831, 13931, 14341, 14741, 15451, 15551, 16061, 16361, 
     16561, 16661, 17471, 17971, 18181, 18481, 19391, 19891, 19991, 30103, 
     30203, 30403, 30703]
    Measure Mode: wall_time
    Thread ID: 70150930162180
    Fiber ID: 70150946941620
    Total: 31.812229           <<--- Execution time
    Sort by: self_time
     %self      total      self      wait     child     calls  name
     23.14      7.363     7.363     0.000     0.000 47877655   Fixnum#%
     21.63      6.881     6.881     0.000     0.000 47877655   Fixnum#==
      0.09     31.812     0.027     0.000    31.785    61406  *Integer#upto
      ...
      0.06     31.737     0.019     0.000    31.718    30702   Object#is_prime?
      ...
      0.01      0.009     0.003     0.000     0.006     3312   Object#is_palindrome?
      ...
      0.00     31.812     0.000     0.000    31.812        1   Enumerable#first
    * indicates recursively called methods

So it looks like it took almost 32 seconds to find 50 palindromic primes. From the profiler output it looks like most of the time was spent in the *is_prime?* function. Can we do better?

## First Refinement ##

If we think about what we are asking for, those primes that are palindromic, then just by common sense we would expect that set to be significantly smaller than the set of primes. Therefore if we check for palindromes first before checking for primes we should be able to significantly lower the run time.

```ruby
def palindromic_primes(n)
    2.upto(Float::INFINITY).lazy.map 
      { |x| x if (is_palindrome?(x) && is_prime?(x)) }.
        select { |x| x.is_a? Integer}.first(n)
end
```

The only difference between this version and the first version is that on the *if* test we reverse the *is_palindrome?* and *is_prime?* tests. Since the *&&* operator operates in short-circuit once the palindrome test fails it will not try to perform the prime test.

    $ ruby-prof ./palindromic_primes_v1.rb
    [2, 3, 5, 7, 11, 101, 131, 151, 181, 191, 313, 353, 373, 383, 727, 757, 
    787, 797, 919, 929, 10301, 10501, 10601, 11311, 11411, 12421, 12721,
    12821, 13331, 13831, 13931, 14341, 14741, 15451, 15551, 16061, 16361, 
    16561, 16661, 17471, 17971, 18181, 18481, 19391, 19891, 19991, 30103, 
    30203, 30403, 30703]
    Measure Mode: wall_time
    Thread ID: 70330106634760
    Fiber ID: 70330112648620
    Total: 0.462978           <<--- Execution time
    Sort by: self_time
     %self      total      self      wait     child     calls  name
     18.82      0.087     0.087     0.000     0.000   520950   Fixnum#%
     15.33      0.071     0.071     0.000     0.000   520950   Fixnum#==
      4.99      0.463     0.023     0.000     0.440      812  *Integer#upto
      4.51      0.053     0.021     0.000     0.032    30702   Object#is_palindrome?
      ...
      0.05      0.352     0.000     0.000     0.352      405   Object#is_prime?
      ...
      0.00      0.000     0.000     0.000     0.000        3   Module#method_added
      0.00      0.000     0.000     0.000     0.000        1   IO#puts
    * indicates recursively called methods

So with that one change our execution time dropped down to less than a second. Can we make it better? We actually can make it a little better by refining how we check for primality.

## Second Refinement ##

In the current version, if we were checking if 11 was prime we would attempt to divide it by 2, 3, 4, 5, 6, 7, 8, 9 and 10; thus performing 9 division operations. In reality we only need to check those numbers that are smaller than the square root of 11 or just 2 and 3 in this case. 

```ruby
def is_prime?(n)
  2.upto(Math.sqrt(n).round()).each do |x|
    return false if n % x == 0
  end
  true
end
```

    $ ruby-prof ./palindromic_primes_v1.rb
    [2, 3, 5, 7, 11, 101, 131, 151, 181, 191, 313, 353, 373, 383, 727, 757, 
    787, 797, 919, 929, 10301, 10501, 10601, 11311, 11411, 12421, 12721, 
    12821, 13331, 13831, 13931, 14341, 14741, 15451, 15551, 16061, 16361, 
    16561, 16661, 17471, 17971, 18181, 18481, 19391, 19891, 19991, 30103, 
    30203, 30403, 30703]
    Measure Mode: wall_time
    Thread ID: 70197772149240
    Fiber ID: 70197785619920
    Total: 0.121776           <<--- Execution time
    Sort by: self_time
     %self      total      self      wait     child     calls  name
     19.89      0.122     0.024     0.000     0.097      812  *Integer#upto
     18.57      0.027     0.023     0.000     0.005    30752  *Enumerator::Yielder#yield
     18.03      0.054     0.022     0.000     0.032    30702   Object#is_palindrome?
     ...
      0.25      0.006     0.000     0.000     0.005      405   Object#is_prime?
     ...
      0.00      0.000     0.000     0.000     0.000        3   Module#method_added
    * indicates recursively called methods

So with the last refinement we changed the run time from roughly a half a second to just one tenth of a second.

## Final Version ##

For easy reference, the final version of the code is repeated here.

```ruby
def is_prime?(n)
  2.upto(Math.sqrt(n).round()).each do |x|
    return false if n % x == 0
  end
  true
end

def is_palindrome?(n)
  n.to_s == n.to_s.reverse
end

def palindromic_primes(n)
   2.upto(Float::INFINITY).lazy.map 
     { |x| x if (is_palindrome?(x) && is_prime?(x))}.
       select { |x| x.is_a? Integer}.first(n)
end

puts palindromic_primes(50).inspect
```

## Conclusion ##

So in this post, we saw a method of generating palindromic primes. Remember that palindromic primes are prime numbers that have the digits in the same order whether you write it forwards or backwards. Our first code worked but was quite slow. By just re-ordering our checks we were able to significantly speed up the code. One last refinement further reduced the execution time. So in the development of our code we learned about some interesting mathematical principles as well as how some simple changes significantly improved its performance.
