debug:
	rgbasm -o wordle.o wordle.asm
	rgblink -o wordle.gb wordle.o

release: debug
	rgbfix -f lhg -t WORDLE wordle.gb

run: debug
	sameboy wordle.gb
