---
layout: post
author: bela
image: 2025-08-16-sql-data-structures-&-the-anatomy-of-an-index/data_structures.jpg
---

In traditional transactional databases (OLTP) data is stored as rows, which makes filtering a costly operation: the database engine needs to scan the entirety of the row during each operation. To make this process more efficient most database engines allow you to index columns (often your primary key). This article explores how databases store their data, what data structures are used, and how indexing can significantly improve performance.


# What is a Database?
In it's simpelest form a database is simply a collection of information (i.e. data) that is stored somewhere. A text file or csv file is technically speaking a database as we are storing some information as bytes on the disk.

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

## How is Data Stored in a Data Base
Each database (e.g. Postgres, SQLite, SQL Server) will store their data slightly differently, but in general the data is stored in blocks of fixed sizes called pages. The reason for this is that if everything was stored into a single object, then there is a chance that the table cannot be loaded into memory, by making it small blocks of predetermined sizes it is easy to iterate over them and index them (more on that later).

SQLite stores all of its data (all of its pages) into a single database file, while Postgress creates seperate files for each table. SQL Server on the other hand uses a combined approach where multiple tables are stored in data files, but there can be multiple data files per database.

In case of Postgress a table file will contain multiple pages. A seperate metadata catalog can be used to retrieve data from a specific page. For example (assuming each page is 8kb) if we know our row is located in page 2 inside of  `table_1.dat`, the database engine will read from the file starting at `2 * 8192 =  16384` bytes up to `3 * 8192 = 24576` bytes.

![datafile]({{ site.baseurl }}/assets/images/2025-08-16-sql-data-structures-&-the-anatomy-of-an-index/database-data-file.png)

The way a page is built up also depends on the database engine in use. In the case of SQL Server a page contains a page header containing metadata about the rows inside of the page, several data rows, and a "Slot Array". The page is of fixed size, which means there are empty bytes between the last data row and the Slot Array.

The Slot Array is a dictionary-like object that contains the offset for each data row. This way the database engine can read the last 2kb of the page to know at which bytes to start reading from. This is similar to how the starting byte for reading is determined when opening a table file, except that the data rows do not always have fixed values: there are column data types that allow variable length data to be stored. For example if we wanted to read the row at index 2, the database engine would lookup what bytes to start reading from based on the Slot Array dictionary.

![page]({{ site.baseurl }}/assets/images/2025-08-16-sql-data-structures-&-the-anatomy-of-an-index/database-page.png)

# Indexing
Consider the following SQL query where we want to retrieve the information of a specific customer.

```sql
select * from customers where customer_id = 'C100'
```

The database engine will have to go scan each row in each page associated with the `customers` table sequentially, it will have to read each page into memomory one-by-one, and then read each data row one-by-one untill it finds the customer in question. This can be a very expensive operation... there has to be a better solution.

## Binary Tree
The problem with the aforementioned approach is that when searching for a specific index, one would need to traverse through the rows one by one, making the search operation is $O(n)$ in time.

To improve this a binary tree can be used. Consider the table below:

| database_index | person_id | full_name           |
| -------------- |-------------|----------------|
| RowID_0              | 12 | Paul Atreides |
| RowID_1              | 27 | Gurney Halleck |
| RowID_2              | 35 | Duncan Idaho |
| RowID_3              | 41          | Feyd-Rautha  |
| RowID_4              | 56           | Stilgar    |
| RowID_5              | 82           | Chani |
| RowID_6              | 74           | Princess Irulan           |
| RowID_7              | 66           | Liet-Kynes      |

Only the `person_id` and `full_name` columns are part of the actual table. The `database_index` column contains the row ID for each row in the table. This can be seen as the "address" of the row in the database, and is stored in the metadata catalog (which is often loaded into memory for performance). If the database knows which row ID you are interested in, it can almost immediately give you the data of said row.

Imagine we are looking for the person whose `person_id` is number 41. The database does not know which row ID this is associated with, instead it will have to perform a full sequential scan of the entire table, loading multiple pages in and out of memory in order to do so.

```sql
select full_name from persons where person_id = 41
```

A balanced binary tree can be created based on the person_id (as this would be what the search criteria provided by the user would be based on; i.e. the input). Each node in the binary tree contains the primary key, which is mapped to the database row index.

![datafile]({{ site.baseurl }}/assets/images/2025-08-16-sql-data-structures-&-the-anatomy-of-an-index/database-binary-tree.png)

In this case one would start at the root node and compare the value of the node (56) to that of the query (41), as it is smaller we traverse the binary tree to the left. This brings us to a node with value 35, in this case the query (41) is bigger than the node, so we traverse the binary tree to the right. This brings us to the node whose value matches the query, and we know to retrieve data from the row RowID_3. The database knows exactly what data this refers to as it keeps the relationship between the RowID values and the actual row locations in memory, making it very quick to retrieve said data.

## B-Trees
The problem with a binary tree is twofold. First, the binary tree approach would only work if the tree was balanced; i.e. all the child nodes to the left of a node are smaller in value, and all the child nodes to the right of a node are larger in value. By default when dynamically building up a binary tree, it will not be balanced.

Second, one would want to search through the data in memory (RAM) instead of from disk (HDD/SDD), as this is faster. However if we need to keep an entire binary tree with as many nodes as there are rows in the database in memory, we would need a *lot* of RAM, or we would need to load chunks of the tree into memory.

A B-Tree datastructure can be used to solve this problem. They are similar to balanced binary trees, the main difference is that each node can contain multiple values, and can have more than 2 children.

## B+ Trees
