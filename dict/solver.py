#!/usr/bin/env python3
import random

print("Welcome to this debug tool!")
print("Just follow the instructions,")
print("however the input syntax is special.")
print()
print("A letter following by a !:")
print("  this letter doesn't exist at all")
print()
print("A letter following by a ?:")
print("  this letter exits but is misplaced")
print()
print("For example:")
print("li!n?u!s!")
print()
print("Which translates into:")
print("  the first letter is an l")
print("  the word doesn't contain an i")
print("  the letter n is misplaced")
print("  the word doesn't contain an u")
print("  the word doesn't contain an s")
print()
print()


def determine_guess(words: list, tries: int) -> str:
    """ Selects one word from the remaining dictionary """
    if tries > 0:
        return random.choice(words) # good enough
    else:
        return "intro"
    

def is_letter(char: str) -> bool:
    """ Checks if a character exists within the alphabet """
    return char >= "a" and char <= "z"


def get_next_letter(response: str, current_index: int) -> str:
    """ Returns the following letter """
    next_index = current_index + 1
    if next_index >= len(response):
        return None

    return response[next_index]


def update_hints(hints: dict, response: str) -> dict:
    """
    Reads the user supplied response and translates it into logical assumptions
    
    The hints dictionary contains single letters as keys,
    where the values are lists of possible locations for this letter.
    
    When the user enters o! we know that 'o' has no valid position within the searched word.
    dict['o'] -> []
    
    When a letter is marked as misplaced, this eliminates possible positions.
    dict['k'] -> [0, 1, 3, 4]
    
    Lastly, correct letters are greatly reducing the possibilities.
    dict['m'] -> [2]
    """
    response = response.lower()

    position = 0
    for i in range(len(response)):
        letter = response[i]
        if not is_letter(letter):
            continue
        
        if not letter in hints:
            hints[letter] = [0, 1, 2, 3, 4]

        next_letter = get_next_letter(response, i)
        if not next_letter or is_letter(next_letter):
            hints[letter] = [position]
        elif next_letter == "?":
            hints[letter] = [l for l in hints[letter] if l != position]
        elif next_letter == "!":
            hints[letter] = []
        else:
            print("invalid input syntax")
        position += 1
    return hints


def narrow_dictionary(words: list, hints: dict) -> list:
    """ Apply the hints to narrow down the possibilities """
    invalid_words = []

    for word in words:
        for key in hints:
            pos = word.find(key)
            
            # skip optional hints
            if pos == -1 and len(hints[key]) == 0:
                continue
            
            if not pos in hints[key]:
                invalid_words.append(word)
                break

    return list(filter(lambda w: w not in invalid_words, words))


with open("en.txt", "r") as handle:
    words = handle.readlines()
    words = list(map(lambda l: l.strip(), words))
    hints = {}
    
    tries = 0
    while tries < 6:
        guess = determine_guess(words, tries)

        print(f"{len(words)} words remaining")
        print(f"input: {guess}")
        response = input("response: ")
        print()
        
        hints = update_hints(hints, response)
        words = narrow_dictionary(words, hints)
        
        if len(words) == 1:
            print(f"It must be {words[0]}")
            exit()

        if len(words) == 0:
            print("There are no words left, please check your input.")
            exit()
        
        tries += 1

    print("I hope the last try was successful.")
    print()
