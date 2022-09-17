#!/usr/bin/env python3
"""
To fit the whole game into one memory bank, the dictionary is compressed.
Since only 2^5 combinations are needed to store 26 letters,
5 bits would be enough; for simplicity's sake, however, we take 6.
This way we can reduce the memory consumption by 20%.
"""

import struct

def compress(in_path: str, out_path:str):
    with open(in_path, "r") as dictionary, open(out_path, "wb") as data:
        while True:
            word = dictionary.readline()
            if not word:
                break
            word = word.strip()
        
            # skip words with double letters
            if len(set(list(word))) != len(word):
                continue

            a = (((ord(word[0])-0x60) << 2) & 0x00fc) | \
                (((ord(word[1])-0x60) >> 4) & 0x0003)     
            b = (((ord(word[1])-0x60) << 4) & 0x00f0) | \
                (((ord(word[2])-0x60) >> 2) & 0x000f)     
            c = (((ord(word[2])-0x60) << 6) & 0x00c0) | \
                (((ord(word[3])-0x60) >> 0) & 0x003f);
            d = (((ord(word[4])-0x60) << 2) & 0x00fc)

            pack = struct.pack("BBBB", a, b, c, d)
            data.write(pack)

compress("en.txt", "en.dat")

