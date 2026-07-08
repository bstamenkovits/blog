---
layout: post
author: bela
image:
---

Encoding and Encryption are two terms often used in the world of cyber-security. Although they sound similar, they have different purposes, and using one instead of the other could break your application/system's entire cyber-security flow.

# Numbering Systems
A numbering system is a way to describe a value or quantity by a chosen set of symbols. The same value/quantity can be described by different symbols depending on the chosen numbering system

* **decimal (base 10)** - In daily life, we've chosen the decimal system, this is a useful system as it is base 10 (the same as the number of fingers on our hands).
* **binary (base2)** - Computers have on/off switches or states, this makes it very easy to express information as bits (a binary number: 0 or 1)
* **hexidecimal (base 16)** - The larger the base, the more compact a quantity can be reperesented by a set of symbols. The hexidecimal numbering system expands the standard 0-9 symbol set to include symbols A-F in order to represent values more compactly

| **Base10 Value** | **Binary Value** | **Hexadecimal Value** |
| --- | --- | --- |
| 0 | 0000 | 0 |
| 1 | 0001 | 1 |
| 2 | 0010 | 2 |
| 3 | 0011 | 3 |
| 4 | 0100 | 4 |
| 5 | 0101 | 5 |
| 6 | 0110 | 6 |
| 7 | 0111 | 7 |
| 8 | 1000 | 8 |
| 9 | 1001 | 9 |
| 10 | 1010 | A |
| 11 | 1011 | B |
| 12 | 1100 | C |
| 13 | 1101 | D |
| 14 | 1110 | E |
| 15 | 1111 | F |
| 16 | 10000 | 10 |
| 17 | 10001 | 11 |
| 45 | 101101 | 2D |
| 145 | 10010001 | 91 |

# Character Encoding
## Encoding Standards
The numbering systems are a way of describing what information is stored on a computer using a chosen set of symbols. It is how data is transferred between parts of a program or computer. If I have a sentence `"Hasta la vista, baby."`, this is stored as a set of values on the comnputer, where each character corresponds to a value. For example the letter `H` could be stored as a value of `72` (decimal), i.e. if the computer sees a value of `72`, it knows to print the letter `H`.

Back in the day different computer manufacturers would choose different mappings between values and letters/symbols, which meant that two computers could not directly talk to one another. One computer could sees a value of `72` and prints out `H` while the other prints out `B`. To solve this an encoding standard is used: a way to standardize the mappings of values to symbols.

* **ASCII** - this was the first encoding standard, mapping 128 values to different letters and symbols
* **Unicode** - this is the modern standard, which expands the original mapping to include other symbols like emojis or characters from other languages (Chinese, Japanese, Arabic, etc.)

These standards are not necessarily the mapping themselves, but the specificiation that defines **how** to map the characters/symbols to values.


## Encoding Formats
Encoding formats are the implementation of the standards in a specific format, they are the mappings themselves. The different character encoding formats will belong to different standards.

* **ASCII** [*ASCII standard*] - The ASCII standard has only one encoding format (often referred to by the same name).
* **UTF-8** [*Unicode standard*] - Uses Hexadecimal numbering system to map symbols to values (variable length). It expands on the ASCII encoding, and is backwards compatible with ASCII.
* **UTF-32** [*Unicode standard*] - The downside of UTF-8 is that not every byte is of the same length, UTF-32 addresses this by describing every value of the encoding by a 32-bit number (fixed length).

| **Character** | **ASCII (Decimal)** | **UTF-8 (Hexadecimal)** | **UTF-32 (Hexadecimal)** |
| --- | --- | --- | --- |
| H | 72 | 48 | 00 00 00 48 |
| € | 8364 | 20 AC | 00 00 20 AC |
| ♥ | 9829 | 26 65 | 00 00 26 65 |


# Data Encoding
Character encoding maps characters to numeric values according to a predetermined map. Data encoding transformas any binary data (not limited to characters) into a specified format using a predetermined set of transformations, allowing for safe transmission/storage.

## Base64 Encoding Format
The most common use data encoding format is Base64, it's defined in RFC 4648, which is part of the IETF internet standard.

Base64 encoding allows one to represent binary data as a compact string of ASCII characters. Each character corresponds to an integer between 0 and 63, which can be represented by a 6 bit character ($2^6=64$).

![alt text]({{ site.baseurl }}/assets/images/2026-07-07-encoding-vs-encryption/base64_index_table.png)

#### Advantages
* **Safe transmission** - Convert any data into ASCII-safe text that won't be corrupted over text-only channels (email, JSON, APIs)
* **Universal compatibility** - Uses only 64 characters, works everywhere (ASCII standard)
* **Reversible** - Can be decoded back to original binary data
* **Standardized** - RFC 4648 ensures consistency across systems

#### Disadvantages
* **Size overhead** - Expands data by ~33% (4 base64 chars = 3 original bytes)
* **No security** - Easily reversable by anyone
* **Padding bugs** - (see below)
* **Performance cost** - Each piece of data needs to be encoded and decoded when being sent
* **Not human-readable** - Encoded string looks like a bunch of random characters

### Base64 Encoding a String

A string can be encoded in the following steps

- Convert each character to its ASCII decimal number
- Convert each decimal value into an 8-bit byte
- List all binary digits in sequential order
- Separate list into 6-bit bytes
- Convert 6-bit byte to decimal
- Convert each value using the base64 table

![alt text]({{ site.baseurl }}/assets/images/2026-07-07-encoding-vs-encryption/base64_string_encoding.png)

This can be used to convert any data into a set of 64 ASCII characters. Even a picture is a set of bytes (1's and 0's), which can be encoded as a base64 string, which can then be transmitted safely through JSON, email, etc. The receiver then simply runs the encoding steps in reverse to obtain the original data.

### Base64 Padding

- When converting from 8-bit bytes to 6-bit bytes there is a chance that the list of binary digits is not a multiple of 6. In this case the number is padded with 0’s
- The output of base64 encoding is by convention a multiple of 4. If this is not the case the remaining characters are padded with `=` characters.

![alt text]({{ site.baseurl }}/assets/images/2026-07-07-encoding-vs-encryption/base64_padding.png)

When decoding tokens, this can be a source of bugs if not taken into account.

---
