@begin:
CLEAR 28671
LOAD ""CODE
REM main()
DEF FN M(string$) = USR 28672

@main:
CLS
PRINT AT 0, 0; "Welcome To ZX Life!"; AT 2, 0; "Please enter message to display,maximum 255 characters:"
INPUT LINE a$
# reset cursor position
PRINT AT 0, 0; ""
IF LEN a$ > 255 THEN GO TO @main
RANDOMIZE FN M(a$)