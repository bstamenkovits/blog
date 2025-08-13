---
layout: post
author: bela
image: python-parallel.jpg
---
The terms *paralel* and *multi-threading* and *concurrency* are often used interchangably, however in the context of Python there are very stark differences between these various terms. This article goes into the subtle and not-so-subtle differences between these concepts.

Traditionally a computer works by performing tasks synchronously:
* start task1
* when task1 is finished start task2
* when task2 is finished start task3
* etc.

However it can be advantageous to switch between tasks, or work on multiple tasks at a time; this is known as performing tasks asynchronously.


## Concurrency - Threading
By default Python handles all tasks in serial, i.e. it only starts a new tasks once the previous task has been completed. Unfortunately this is not always the ideal way of working. For example when cooking pasta one might start with boiling some water. After turning on the stove you could wait for the water to boil, or you could do something else in the mean time, like chop some onion.

Workin on two tasks at the same time, and switching from one to the other is called **concurrency**. It is ideal when you want to keep performing tasks after having instruct other processes/services to perform tasks that you need to wait for.

In python this implementation is called **threading**. A single **thread** is an execution context, which is all the information needed for a CPU to execute a stream of instructions. We can assign different functions/tasks to different threads, and allow python to choose which thread to work on


```python
import time
import threading
from concurrent.futures import ThreadPoolExecutor
import matplotlib.pyplot as plt
import random

thread_times = []

# Simulate two threads running concurrently
def func(arg):
    thread_times.append((threading.get_ident(), time.time()))
    for _ in range(arg * 10):
        time.sleep(random.uniform(0.01, 0.05))
        thread_times.append((threading.get_ident(), time.time()))
    thread_times.append((threading.get_ident(), time.time()))
    return arg


with ThreadPoolExecutor(max_workers=2) as ex:
    res = list(ex.map(func, (1,1)))


# Plot Results
plt.figure(figsize=(12, 4))

t0 = thread_times[0][1]
for i, start in enumerate(thread_times[:20]):
    end = thread_times[i+1]
    thread_id = 1 if start[0] == thread_times[0][0] else 2

    times = [start[1]-t0, end[1]-t0]
    thread_ids = [thread_id, thread_id]

    color = 'r' if start[0] == thread_times[0][0] else 'b'
    plt.plot(times, thread_ids, color=color, linewidth=2)

plt.ylim(0.5, 2.5)

plt.xlabel('Time (s)')
plt.title('Thread Activity Visualization with Context Switches')
plt.yticks(ticks=[1, 2], labels=['Thread 1', 'Thread 2'])
plt.show()
```
![context-switching](/assets/images/2024-06-16-python-concurrent-vs-parallel-context-switching.png)

### Example: Downloading Files
Threading is often used in I/O operations where the python program has to wait on other external services to complete their tasks. A good example of this is downloading an image from a website. Python will make a `GET` request to the web server of the website, and it will take some time before the actual image data is accessible to Python. The following steps may result in waiting times

* Server handling `GET` request
* Internet transfer; wifi, routers, switches, communication protocols, etc.
* The OS network handling connections between software layers
* Writing data to buffer
* Writing data to RAM

![python-download](/assets/images/2024-06-16-python-concurrent-vs-parallel-python-download.png)

```python
import time
import requests
from concurrent.futures import ThreadPoolExecutor


# Download an image from a URL as bytes
def download_image(img_url:str) -> bytes:
    return requests.get(img_url).content


# Decorator to measure the time a function takes to execute
def timeit(func: callable) -> callable:
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        res = func(*args, **kwargs)
        end = time.perf_counter()
        print(f'{func.__name__} took {end - start:.2f} seconds')
        return res
    return wrapper


# download same image 20 times
image_urls = ['https://images.unsplash.com/photo-1428366890462-dd4baecf492b'] * 20


@timeit
def serial_download():
    for url in image_urls:
        download_image(url)


@timeit
def multi_threaded_download():
    with ThreadPoolExecutor(4) as executor:
        executor.map(download_image, image_urls)


serial_download()
multi_threaded_download()
```
**Output**:
>serial_download took 2.86 seconds

>multi_threaded_download took 1.42 seconds

## Parallelism - Multi-Processing
When using threading Python switches between threads so that it does not have to sit idle while waiting for one task to finish, similar to how you can start chopping onion while you wait for the water to boil when making pasta. In this case Python still only works on one thing at a time, but is able to switch between tasks. It would be even more efficient if Python could work on multiple tasks at the same time, similar to how having another cook in the kitchen allows for the onions and carrots to be chopped at the same time.

Having the Python interpreter work on two tasks at the same time is called **parallelism**. Which is ideal when you want to perform multiple independent tasks at the same time.

In python this implementation is called **multiprocessing**. Modern CPUs contain multiple cores (processing unites), a single process is a single instance of a CPU core. We can assign different functions to different processes, which will work on those tasks independently.

![multithreading](/assets/images/2024-06-16-python-concurrent-vs-parallel-multithreading.avif)

### Global Interpreter Lock
Python is a high level programming language that takes care of memory management and garbage collection on its own. In python if you assign a variable to a value like `x = [1, 2, 3]`, then the value of 10 will be located at a certain memory address (e.g. `0x1c8a6dd9b80`). The variable `x` points directly at said address.

```python
x = [1, 2, 3]
hex(id(x))
```
**Output**: '0x113534ed440'

Python constantly looks at all the addresses in memory and checks how many references are made to said address. We can check this ourselves using the `sys.getrefcount` function. The reference count also includes temporary references

In the case of `sys.getrefcount(x)`, the count is 2 instead of 1 because:

* `x` is referenced once when it's assigned.
* `x` is referenced again when it's passed as an argument to `sys.getrefcount(x)`.

```python
import sys
print(sys.getrefcount(x))
```
**Output**: 2

Whenver a reference count reaches zero, the address in memory is cleared automatically.

If two threads were to access and change the same variable, it could lead to
* *race condition* - e.g. thread 1 adds 4 to list `x`, python switches its context to thread 2, which also adds 4 to its list `x`, and all of a sudden `x = [1,2,3,4,4]`
* *premature deallocation* - e.g. thread 1 changes the value of `x` to `x = 1`, then python deletes the list `[1,2,3,4]` from memory as its reference count reached 0, even though thread2 was sitll using it.
* *memory leak* - e.g. thread 1 continuously appends new data to a global list x without ever removing old data, causing x to grow indefinitely, and eventually consuming all available memory.

The **GIL** ensures that variables are synchronized between threads to avoid undesirable bahavior and ensure **thread safety**.

To get around the GIL **multiprocessing** can be used. It is a lot faster, but also requires more memory and resources; so if cloud compute resources or electricity bills are of concern maybe stick to **multithreading**.

### Example: Downloading Files
The same scenario of downloading files from a server is used, however in this case multiprocessing is used. This is even faster than multithreading as all images are downloaded at the same time.

```python
from concurrent.futures import ProcessPoolExecutor

@timeit
def multi_process_download():
    with ProcessPoolExecutor(4) as executor:
        executor.map(download_image, image_urls)


serial_download()
multi_threaded_download()
multi_process_download()
```

**Output**:
>serial_download took 3.85 seconds

>multi_threaded_download took 1.53 seconds

>multi_process_download took 0.11 seconds
