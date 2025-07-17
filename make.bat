.\utils\zmakebas -l -a @begin -o basic.tap main.bas
.\utils\pasmo.exe --tap main.asm code.tap
type basic.tap code.tap > zx-life.tap
del basic.tap
del code.tap