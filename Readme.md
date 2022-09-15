Wordle
======

In this game, a word with five letters has to be guessed. For this purpose, six words can be tried. After each attempt, every character is shown whether it is not present, present and in the right place, or present but not in the right place.


Controls
---------
```
START       Starts a new game
SELECT      Confirms the entered word
→ ↓ ← ↑     Moves the cursor
A           Selects a character
B           Deletes the last character
```


Requirements
------------
To play this game on a real handheld, you have to build the ROM for yourself, because the one included lacks copyrighted header data.

To build this game, you will need the [rgbds](https://rgbds.gbdev.io) suite.
An [SameBoy](https://sameboy.github.io/) installation is optional.



Build
-----
The following commands should be useful:

```
make debug    # build the ROM
make release  # build the ROM and fix headers
make run      # build and run the ROM
```
