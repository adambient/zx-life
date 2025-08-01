.\utils\zmakebas -l -a @begin -o basic.tap main.bas
.\utils\pasmo.exe --tap main.asm code.tap
.\utils\pasmo.exe --tap int.asm int.tap
type basic.tap code.tap int.tap > zx-life.tap
del basic.tap
del code.tap
del int.tap