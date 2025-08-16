---
layout: post
author: bela
image: 2025-08-16-sql-data-structures-&-the-anatomy-of-an-index/data_structures.jpg
---


In it's simpelest form a database is simply a collection of information (i.e. data) that is stored somewhere. A text file or csv file is technically speaking a database as we are storing some information as bytes to the disk.

# Storing & Reading Data
The problem with storing data in such a way is that it is hard to retrieve individual specific datapoints: when we read a csv file we simply get a long list of characters. The only way to distinguish different rows is by having an escape character `\n`.

To resolve this problem we could make each row the same length. For example if each row has a length `m`, then we know that we can go to the 6th index by going to the `6*m`th character.

In this solution one would need to track the length of each cell. If we allow the maximum entry length to be 255 ASCII characters long, then the length of each string will be somewhere between 0 and 255, which can be represented by a single byte.

```
0000 0000 = 0
0000 0001 = 1
0000 0010 = 2
...
1111 1111 = 255
```

>**Fun Fact**.
>This is the reason why `VARCHAR(255)` is often chosen in SQL databases. If one were to use `VARCHAR(256)`, the length of each entry would need to be represented by two bytes.
>
> ```
> 0000 0000 0000 0000 = 0
> 0000 0000 0000 0001 = 1
> 0000 0000 0000 0010 = 2
> ...
> 0000 0000 1111 1111 = 255
> 0000 0001 1111 1111 = 256
> ```

## Files On Disk
Each database (e.g. Postgres, SQLite, SQL Server) will store their data slightly differently, but in general the data is stored in blocks of fixed sizes called pages. SQLite stores all of its data (all of its pages) into a single database file, while Postgress creates seperate files for each table. SQL Server on the other hand uses a combined approach where multiple tables are stored in data files, but there can be multiple data files per database.

In case of Postgress a table file will contain multiple pages. A seperate metadata catalog can be used to retrieve data from a specific page. For example (assuming each page is 8kb) if we know our row is located in page 2 inside of  `table_1.dat`, the database engine will read from the file starting at `2 * 8192 =  16384` bytes up to `3 * 8192 = 24576` bytes.

![datafile]({{ site.baseurl }}/assets/images/2025-08-16-sql-data-structures-&-the-anatomy-of-an-index/database-data-file.png)

The way a page is built up also depends on the database engine in use. In the case of SQL Server a page contains a page header containing metadata about the rows inside of the page, several data rows, and a "Slot Array". The page is of fixed size, which means there are empty bytes between the last data row and the Slot Array.

The Slot Array is a dictionary-like object that contains the offset for each data row. This way the database engine can read the last 2kb of the page to know at which bytes to start reading from. This is similar to how the starting byte for reading is determined when opening a table file, except that the data rows do not always have fixed values: there are column data types that allow variable length data to be stored. For example if we wanted to read the row at index 2, the database engine would lookup what bytes to start reading from based on the Slot Array dictionary.

![page]({{ site.baseurl }}/assets/images/2025-08-16-sql-data-structures-&-the-anatomy-of-an-index/database-page.png)

# Indexing
When performing a SQL query

```sql
select * from customers where customer_id = 'C100'
```

## Binary Tree
The problem with the aforementioned approach is that when searching for a specific index, one would need to traverse through the rows one by one, making the search operation is $O(n)$ in time.
<!--
# Data Structures
Lets imagine we want to store some user data, for which we will want to note down the user id (primary key) and their full name.

|id | name |
|--|--|
| 12 | Paul Atreides |
| 27 | Gurney Halleck |
| 35 | Duncan Idaho |
| ... | ... |

## Option1: Delimeters (e.g. CSV)

If we were to save data as a csv we would save it as

```
12, Paul Atreides\n
27, Gurney Halleck\n
35, Duncan Idaho\n
```

The problem is that when we read a csv file we simply get a long list of characters. The only way to distinguish different rows is by having an escape character `\n`.

If we want to look at a specific row we would need to start at the beginning of the csv file and look for ideces by looking for the escape character `\n` character by character.

## Option2: Fixed Row Length
One solution is to make each row the same length. For example if each row has a length `m`, then we know that we can go to the 6th index by going to the `6*m`th character.

In this solution one would need to track the length of each cell. If we allow the maximum entry length to be 255 ASCII characters long, then the length of each string will be somewhere between 0 and 255, which can be represented by a single byte.

```
0000 0000 = 0
0000 0001 = 1
0000 0010 = 2
...
1111 1111 = 255
```

This is the reason why `VARCHAR(255)` is often chosen in SQL databases. If one were to use `VARCHAR(256)`, the length of each entry would need to be represented by two bytes.

```
0000 0000 0000 0000 = 0
0000 0000 0000 0001 = 1
0000 0000 0000 0010 = 2
...
0000 0000 1111 1111 = 255
0000 0001 1111 1111 = 256
```

The index must also be tracked, this is often chosen as 4 bytes (`0` to `4,294,967,295`)to make sure we can keep track of lots of rows of data.

This would mean each row contains 260 bytes of data: 4 bytes (idx) + 1 byte (entry length) + 255 bytes (capacity). In order to go from row index 1 to row index 2 we would traverse the storage file by 260 bytes. -->

<!-- ## Option3 Binary Tree
The problem with the aforementioned approach is that when searching for a specific index, one would need to traverse through the rows one by one, making the search operation is $O(n)$ in time.

To improve this a binary tree can be used. Consider the data below:

| database_index | primary_key | name           |
| -------------- |-------------|----------------|
| RowID_0              | 12 | Paul Atreides |
| RowID_1              | 27 | Gurney Halleck |
| RowID_2              | 35 | Duncan Idaho |
| RowID_3              | 41          | Feyd-Rautha  |
| RowID_4              | 56           | Stilgar    |
| RowID_5              | 82           | Chani |
| RowID_6              | 74           | Princess Irulan           |
| RowID_7              | 66           | Liet-Kynes      |

A balanced binary tree can be created based on the primary_key (as this would be what the search criteria provided by the user would be based on; i.e. the input). Each node would contain the primary key, which is mapped to the database row index.

![balanced binary tree](media/balanced_binary_tree.png)

For example if we wanted to find the name of the row with primary key 8 (notice how primary key does not have to be consecutively ordered), one would start at the top and compare 8 to the node value of 5. As 8 is bigger than 5 we would traverse down and to the right. The next node has a value of 7, once again 8 is bigger, and finally we would reach the leaf node containing a node of value 8. From this node we can see that primary key 8 refers to the 5th row in the database, which has a name value of "*Obi-Wan Kenobi*".


## Option4 B Trees
The problem with a binary tree is twofold. First, the binary tree approach would only work if the tree was balanced; i.e. all the child nodes to the left of a node are smaller in value, and all the child nodes to the right of a node are larger in value. By default when dynamically building up a binary tree, it will not be balanced.

Second, one would want to search through the data in memory (RAM) instead of from disk (HDD/SDD), as this is faster. However if we need to keep an entire binary tree with as many nodes as there are rows in the database in memory, we would need a *lot* of RAM, or we would need to load chunks of the tree into memory.

A B-Tree datastructure can be used to solve this problem. They are similar to balanced binary trees, the main difference is that each node can contain multiple values, and can have more than 2 children. -->
