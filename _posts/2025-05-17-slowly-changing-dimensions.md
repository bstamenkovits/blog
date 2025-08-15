---
layout: post
author: bela
image: 2025-05-17-slowly-changing-dimensions/snail.jpg
---

Keeping track of historical data is always challenging, especially if these changes not occur frequently or consistantly. Fortunately there is are robust methods to deal with these challenges: *Slowly Changing Dimensions*. Here the name "dimension" comes from Dimensional Modeling popularized by Kimball where you have facts (events) and dimensions (descriptions to provide context of an event)

> **Definition**
> *Slowly Changing Dimension* - a dimension (descriptive data) that changes over time, but not regularly or predictably

*SCD Examples*
* Grocery store products price changes due to inflation
* Parent company changing due to an acquisition
* Address of a client changing because they moved

# Types of SCD Strategies
The Kimball Toolkit has popularized a categorization of techniques for handling SCD's as Types 1 through 6. I will briefly explain each strategy type, and give a small example.

| user_id | name | born |
|--|--|--|
| 001 | 

## Type 0 - No History
This is the simplest case where you're not not even updating the data. If your data doesn't change, can you even call it a "Slowly Changing Dimension"?

## Type 1 - Overwrite

## Type 2 - New Row

## Type 3 - New Column

## Type 6 - Combine Types 1 + 2 + 3 = 6

# Conclusion
In practice you only really use Type 2, maybe Type 6 if for some reason you *really* need to keep track of the previous value. Remember once historical data is gone, it's gone forever, often it's cheaper to just pay for that little bit of extra storage and complexity to maintain access to that data.
