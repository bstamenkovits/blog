---
layout: post
author: bela
image: 2025-07-19-boundaries-and-segments/segments.jpg
---

Most of the input data has `valid_from`/`valid_to` or `start_date`/`end_date` columns to provide a time period in which these data points are valid. These input data tables are combined into models which also need these same `start_date`/`end_date` columns.

This document outlines the general strategy on how to retain the temporal validty of data points after they are joined in tables/models.


## Example
The best way to describe the strategy is through the use of an example in which there are two tables (table A & table B), which are joined together. Both tables have a
* `key` column with the same keys, which can be used for the join.
* `val` column which contains some information about the key.
* `start` and `end` columns which represent the time spans when these values are valid

**Table A**

| key | val_a | start | end |
|--|--|--|--|
| S1 | A11 | 1 | 3 |
| S1 | A12 | 3 | 9 |
| S2 | A21 | 1 | 6 |
| S2 | A22 | 6 | 11 |

**Table B**

| key | val_b | start | end |
|--|--|--|--|
| S1 | B11 | 2 | 8 |
| S2 | B21 | 3 | 10 |
| S2 | B22 | 10 | 11 |

In this example data an entity S1 has a `val_a` value of A11 at the start, but changes to A12 at `t=3`, which remains valid until `t=9` after which `val_a` no longer has a value. Ultimately we want to know what the value of `val_a` and `val_b` for a given `key` are at a certain point in time.
<!-- ![alt text](image.png) -->

### Boundaries
In order to achieve this we first create a set of boundaries for each key. A boundary for a key is a point in time for which any of its values changes, this could be from any table. In the example if either `val_a` or `val_b` changes a new boundary is added.

```sql
boundaries AS (
	-- boundaries from table a
	SELECT key, start_date AS boundary FROM table_a
	UNION
	SELECT key, end_date FROM table_a

	UNION

	-- boundaries from table b
	SELECT key, start_date FROM table_b
	UNION
	SELECT key, end_date FROM table_b
)
```

### Segments
The boundaries are simply a list of timestamps representing a point in time when a value of a given key changed. New segments (start_date, end_date) can be created using a window function over the keys, using the list of boundaries as the start_date and the `n+1` boundary as the end_date (using the `LEAD()` SQL operator)

```sql
segments as (
	SELECT
		sk,
		boundary AS start_date,
		LEAD(boundary) OVER (partition by sk ORDER BY boundary) AS end_date
	FROM boundaries
)
```


![time_travel]({{ site.baseurl }}/assets/images/2025-07-19-boundaries-and-segments/time_travel.png)

### Final Join
The segments table is used as base for the final join as it contains the keys and relevant segments of the final table. Only the relevant values need to be joined onto it.

```sql
SELECT
    s.key AS key,
    a.val_a AS val_a,
    b.val_a AS val_b,
    s.start_date,
    s.end_date,
FROM segments AS s
LEFT JOIN table_a AS a
    ON s.start_date >= a.start_date AND s.end_date <= a.end_date and s.sk = a.sk
LEFT JOIN table_b AS b
    ON s.start_date >= b.start_date AND s.end_date <= b.end_date and s.sk = b.sk
WHERE s.end_date IS NOT NULL  -- filter out open-ended last row from LEAD
ORDER BY s.key, s.start_date
```

|key  |val_a  |val_b  |start_date  |end_date  |
|------|-----------|-----------|--------------|------------|
|S1    |A11        |NULL       |1             |2           |
|S1    |A11        |B11        |2             |3           |
|S1    |A12        |B11        |3             |8           |
|S1    |A12        |NULL       |8             |9           |
|S2    |A21        |NULL       |1             |3           |
|S2    |A21        |B21        |3             |6           |
|S2    |A22        |B21        |6             |10          |
|S2    |A22        |B22        |10            |11          |
