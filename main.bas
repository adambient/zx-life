@begin:
# zx-life by ambientcoder 2023
# load UDGs
LET i = USR "a" : LET t = i+7 : FOR x = i TO t : READ y : POKE x, y : NEXT x
# load machine code
CLEAR 28159
LOAD ""CODE
# game of life machine code routine
DEF FN G(string$) = USR 28160

@main:

BORDER 0 : PAPER 0 : INK 3 : CLS
PRINT AT 0, 0; "Welcome To ZX Life 2.0!"; AT 2, 0; "Please enter message to display,maximum 255 characters:"
INPUT LINE a$
IF LEN a$ > 255 THEN GO TO @main
# fill screen with invisible hashes
INK 0 : PAPER 0 : CLS
FOR x = 0 TO 21
PRINT AT x, 0; "\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a"
NEXT x
PRINT #1; AT 0, 0; INK 0; PAPER 0; "\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a"
PRINT #1; AT 1, 0; INK 0; PAPER 0; "\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a\a"
# begin game of life
RANDOMIZE FN G(a$)

# UDG
DATA 170, 85, 170, 85, 170, 85, 170, 85