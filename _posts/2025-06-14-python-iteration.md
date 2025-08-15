---
layout: post
author: bela
image: python-iteration.jpg
---

Like many others, my love for programming began with the desire to automate; *Iteration* forms one of the core pillars that allows us to do so. This article takes a peek under the hood of Python to see how this programming language implements iteration. We will start with the humble for-loop, and work our way down to iterators, generators, and co-routines.


## Sequence

Prior to Python 2.2 the `for` loop worked by having an internal hidden index and calling `loopable_class.__getitem__(hidden_index)` or `loopable_class[hidden_index]`. After returning the first value it would increment `hidden_index` by 1 and keep going until a `IndexError` was returned. If you call `for item in loopable_class` it would simply return
* `item = loopable_class[0]`
* `item = loopable_class[1]`
* ...

until an `IndexError` was encountered.

Although the way the `for` loop works has been changed, the old way of performing a loop can still be found in the definition of a `sequence` object. A sequence is a class that implements the `__getitem__` method and the `__len__` method. By implementing these methods the class can be used by the old `for` loop logic.

```python
class MySequence:

    def __init__(self, n, step_size=1):
        self.n = n
        self.step_size = step_size
        if n % step_size != 0:
            raise ValueError("n must be divisible by step_size")

    def __getitem__(self, index):
        val = index*self.step_size
        if val >= self.n:
            raise IndexError("End of sequence")
        return val

    def __len__(self):
        return int(self.n/self.step_size)

s = MySequence(9, step_size=3)

s[0], s[1], s[2]
```


**Output:** (0, 3, 6)


```python
tuple(i for i in s)
```


**Output:** (0, 3, 6)


## Iterators
After Python 2.2 the `for` loop logic has been adjusted. Instead of having an incrementing hidden index and returning `item = iterative_class[hidden_index]`, the `for` loop now calls `iterative_class.__next__()` or `next(iterative_class)`

Any object/class in python that implements the dundermethods `__iter__()` and `__next__()` is an Iterator.

The `__iter__()` method must always return an istance of the iterator object itself (i.e. `return self`). That way when `iter(my_iterator_object)` is called, an iterable is returned.

```python
class MyIterator:

    def __init__(self, n):
        self.n = n
        self.i = 0

    def __iter__(self):
        return self

    def __next__(self):
        while self.i < self.n:
            i = self.i
            self.i += 1
            return i
        raise StopIteration()


m = MyIterator(3)
m_iter = iter(m)
next(m_iter), next(m_iter), next(m_iter)
```
**Output:** (0, 1, 2)

```python
m = MyIterator(3)
tuple(i for i in m)
```
**Output:** (0, 1, 2)


## Iterables
An Iterable is any class that can be iterated over, which means they are either a
* *sequence* - implement `__getitem__` & `__len__`
or
* *iterator* - implement `__iter__` & `__next__`

The new `for` loop logic accepts any iterable, including sequences. By default a sequence does not have the `__next__` or `__iter__` methods implemented. In order to make sequences work with `for` loops, Python automatically wraps sequences with a class that implements the `__iter__` and `__next__` methods.

```python
# example wrapper to make MySequence iterable (python already does this for us)
class IteratorWrapper:

    def __init__(self, sequence):
        self.sequence = sequence
        self._n = len(sequence)
        self._i = 0

    def __getattr__(self, attr):
        return getattr(self.sequence, attr)

    def __iter__(self):
        return self

    def __next__(self):
        while self._i < self._n:
            val = self.sequence[self._i]
            self._i += 1
            return val
        raise StopIteration()

s = MySequence(6, step_size=2)
m = IteratorWrapper(s)

tuple(i for i in m)
```
**Output:** (0, 2, 4)


## Generators

Creating an interable can be quite cumbersome as you have to write a class and implement the `__iter__` and `__next__` methods by hand. Generators can be used to quickly create an iterable using a simple function.

When using the `yield` keyword in a function, the function returns an iterator object. The returned iterator object is a class with a `__iter__` method returning `self`, and a `__next__` method, which contains the same logic as the generator function.

```python
def generate_numbers(n):
    i = 0
    while i < n:
        yield i
        i += 1

g = generate_numbers(3)
next(g), next(g), next(g)
```
**Output:** (0, 1, 2)

```python
class GenerateNumbers:

    def __init__(self, n):
        self.n = n
        self.i = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.i < self.n:
            val = self.i
            self.i += 1
            return val
        raise StopIteration()

g = GenerateNumbers(3)
next(g), next(g), next(g)
```
**Output:** (0, 1, 2)


## Generator-Based Coroutine

In computer science a coroutine is a control structure where different routines (e.g. functions, classes) are executed colaboratively. The program chooses when to execute which routine: it can pause one routine and switch over to another. Generators are almost coroutines, except they can only output values. They lack the ability to receive data after being paused. In order to introduce coroutines to Python additional functionality was added after Python 2.5

As part of [PEP342](https://peps.python.org/pep-0342/) additional functionality was added to generators in order for them to behave more like coroutines. The biggest change was in the way the syntax of a yield expression works.
* Previously `yield val_out` would simply suspend the function and output the `val_out` value.
* The new syntax `val_in = yield val_out` updates the value of `val_in` and outputs `val_out`

Additional methods and exceptions were also introduced:
* `send` method - values can be sent to the generator at the point where the generator is currently suspended
* `throw` method - exceptions can be thrown at the point where the generator is currently suspended
* `GeneratorExit` exception - a new standard exception that can be used to identify when a generator is exited
* `close` method - throws the `GeneratorExit` exception
* `__del__` method - calls the `close` method on self, and optionally handles additional logic

It should be noted that the `send` function cannot be called until the iterator object has been started (`next` should be called at least once). Using `iterator.send(None)` is the equivalent to `next(iterator)`

```python
def running_total():
    total = 0
    while True:
        value = yield total # update value and return total
        total += value


r = running_total()

next(r) # start the generator
t1 = r.send(1) # val = 1, total = 0+1 = 1
t2 = r.send(2) # val = 2, total = 1+2 = 3
t3 = r.send(3) # val = 3, total = 3+3 = 6

t1, t2, t3
```
**Output:** (1, 3, 6)


### New Syntax: yield from
Although generators can now be seen as a type of coroutine, they still posses a limitation: a generator can only yield values to its immediate caller. If you have a generator inside another generator then you would need to loop over the subgenerator and have the main generator yield the values yielded by subgenerator. In addition in order to use the newly introduce `send`, `close`, and `throw` methods correctly one would need to write a lot of boiler plate code to encapsulate all edge cases (catching the right errors and dealing with the right conditionals).

In [PEP380](https://peps.python.org/pep-0380/) the `yield from` syntax was introduced. This new syntax avoids having to write an additional loop for nested generators, and contains all the boiler plate code to deal with edge cases. The equivalent python code to `yield from` can be found [here](https://peps.python.org/pep-0380/#formal-semantics).

```python
def double():
    value = 0
    while value is not None:
        value = yield value * 2

def generator_wrapper(generator):
    current_value = next(generator)

    while True:
        sent_value = yield current_value
        current_value = generator.send(sent_value)

wrapped_double = generator_wrapper(double())
next(wrapped_double) # initiate the generator
wrapped_double.send(1), wrapped_double.send(2), wrapped_double.send(3)
```
**Output:** (2, 4, 6)

```python
def double():
    value = 0
    while value is not None:
        value = yield value * 2

def generator_wrapper(generator):
    yield from generator

wrapped_double = generator_wrapper(double())
next(wrapped_double) # initiate the generator
wrapped_double.send(1), wrapped_double.send(2), wrapped_double.send(3)
```
**Output:** (2, 4, 6)




<!-- The most basic form of iteration in any language is the `for` loop. In Python the `for` loop is used as follows: It expects a class that can be looped over (`loopable_class`), which returns an `item` iteratively.

```python
for item in loopable_class:
    # do something with item
``` -->
