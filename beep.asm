; -------------------------------------------------------------------
; ROM beeper routine.
;
; Input: HL -> Note.
;        DE -> Duration.
;
; Alters the value of the AF, BC, DE, HL and IX registers.
; -------------------------------------------------------------------
BEEP: EQU $03b5

; -------------------------------------------------------------------
; Notes to be uploaded to HL
; -------------------------------------------------------------------
C_0:    EQU $6868
Cs_0:   EQU $628d
D_0:    EQU $5d03
Ds_0:   EQU $57bf
E_0:    EQU $52d7
F_0:    EQU $4e2b
Fs_0:   EQU $49cc
G_0:    EQU $45a3
Gs_0:   EQU $41b6
A_0:    EQU $3e06
As_0:   EQU $3a87
B_0:    EQU $373e
C_1:    EQU $3425
Cs_1:   EQU $3134
D_1:    EQU $2e6f
Ds_1:   EQU $2bd3
E_1:    EQU $295c
F_1:    EQU $2708
Fs_1:   EQU $24d5
G_1:    EQU $22c2
Gs_1:   EQU $20cd
A_1:    EQU $1ef4
As_1:   EQU $1d36
B_1:    EQU $1b90
C_2:    EQU $1a02
Cs_2:   EQU $188b
D_2:    EQU $1728
Ds_2:   EQU $15da
E_2:    EQU $149e
F_2:    EQU $1374
Fs_2:   EQU $125b
G_2:    EQU $1152
Gs_2:   EQU $1058
A_2:    EQU $0f6b
As_2:   EQU $0e9d
B_2:    EQU $0db8
C_3:    EQU $0cf2
Cs_3:   EQU $0c36
D_3:    EQU $0b86
Ds_3:   EQU $0add
E_3:    EQU $0a40
F_3:    EQU $09ab
Fs_3:   EQU $091e
G_3:    EQU $089a
Gs_3:   EQU $081c
A_3:    EQU $07a6
As_3:   EQU $0736
B_3:    EQU $06cd
C_4:    EQU $066a
Cs_4:   EQU $060c
D_4:    EQU $05b3
Ds_4:   EQU $0560
E_4:    EQU $0511
F_4:    EQU $04c6
Fs_4:   EQU $0480
G_4:    EQU $043d
Gs_4:   EQU $03ff
A_4:    EQU $03c4
As_4:   EQU $038c
B_4:    EQU $0357
C_5:    EQU $0325
Cs_5:   EQU $02f7
D_5:    EQU $02ca
Ds_5:   EQU $02a0
E_5:    EQU $0279
F_5:    EQU $0254
Fs_5:   EQU $0231
G_5:    EQU $020f
Gs_5:   EQU $01f0
A_5:    EQU $01d3
As_5:   EQU $01b7
B_5:    EQU $019c
C_6:    EQU $0183
Cs_6:   EQU $016c
D_6:    EQU $0156
Ds_6:   EQU $0141
E_6:    EQU $012d
F_6:    EQU $011b
Fs_6:   EQU $0109
G_6:    EQU $00f8
Gs_6:   EQU $00e9
A_6:    EQU $00da
As_6:   EQU $00cc
B_6:    EQU $00bf
C_7:    EQU $00b2
Cs_7:   EQU $00a7
D_7:    EQU $009c
Ds_7:   EQU $0091
E_7:    EQU $0087
F_7:    EQU $007e
Fs_7:   EQU $0075
G_7:    EQU $006d
Gs_7:   EQU $0065
A_7:    EQU $005e
As_7:   EQU $0057
B_7:    EQU $0050
C_8:    EQU $004a
Cs_8:   EQU $0044
D_8:    EQU $003e
Ds_8:   EQU $0039
E_8:    EQU $0034
F_8:    EQU $0030
Fs_8:   EQU $002b
G_8:    EQU $0027
Gs_8:   EQU $0023
A_8:    EQU $0020
As_8:   EQU $001c
B_8:    EQU $0019

; -------------------------------------------------------------------
; Frequencies to be loaded in DE, 1 second ( / 2 = 0.5 ....)
; -------------------------------------------------------------------
C_0_f:  EQU $0010 / $20
Cs_0_f: EQU $0011 / $20
D_0_f:  EQU $0012 / $20
Ds_0_f: EQU $0013 / $20
E_0_f:  EQU $0014 / $20
F_0_f:  EQU $0015 / $20
Fs_0_f: EQU $0017 / $20
G_0_f:  EQU $0018 / $20
Gs_0_f: EQU $0019 / $20
A_0_f:  EQU $001b / $20
As_0_f: EQU $001d / $20
B_0_f:  EQU $001e / $20
C_1_f:  EQU $0020 / $20
Cs_1_f: EQU $0022 / $20
D_1_f:  EQU $0024 / $20
Ds_1_f: EQU $0026 / $20
E_1_f:  EQU $0029 / $20
F_1_f:  EQU $002b / $20
Fs_1_f: EQU $002e / $20
G_1_f:  EQU $0031 / $20
Gs_1_f: EQU $0033 / $20
A_1_f:  EQU $0037 / $20
As_1_f: EQU $003a / $20
B_1_f:  EQU $003d / $20
C_2_f:  EQU $0041 / $20
Cs_2_f: EQU $0045 / $20
D_2_f:  EQU $0049 / $20
Ds_2_f: EQU $004d / $20
E_2_f:  EQU $0052 / $20
F_2_f:  EQU $0057 / $20
Fs_2_f: EQU $005c / $20
G_2_f:  EQU $0062 / $20
Gs_2_f: EQU $0067 / $20
A_2_f:  EQU $006e / $20
As_2_f: EQU $0074 / $20
B_2_f:  EQU $007b / $20
C_3_f:  EQU $0082 / $20
Cs_3_f: EQU $008a / $20
D_3_f:  EQU $0092 / $20
Ds_3_f: EQU $009b / $20
E_3_f:  EQU $00a4 / $20
F_3_f:  EQU $00ae / $20
Fs_3_f: EQU $00b9 / $20
G_3_f:  EQU $00c4 / $20
Gs_3_f: EQU $00cf / $20
A_3_f:  EQU $00dc / $20
As_3_f: EQU $00e9 / $20
B_3_f:  EQU $00f6 / $20
C_4_f:  EQU $0105 / $20
Cs_4_f: EQU $0115 / $20
D_4_f:  EQU $0125 / $20
Ds_4_f: EQU $0137 / $20
E_4_f:  EQU $0149 / $20
F_4_f:  EQU $015d / $20
Fs_4_f: EQU $0172 / $20
G_4_f:  EQU $0188 / $20
Gs_4_f: EQU $019f / $20
A_4_f:  EQU $01b8 / $20
As_4_f: EQU $01d2 / $20
B_4_f:  EQU $01ed / $20
C_5_f:  EQU $020b / $20
Cs_5_f: EQU $022a / $20
D_5_f:  EQU $024b / $20
Ds_5_f: EQU $026e / $20
E_5_f:  EQU $0293 / $20
F_5_f:  EQU $02ba / $20
Fs_5_f: EQU $02e4 / $20
G_5_f:  EQU $0310 / $20
Gs_5_f: EQU $033e / $20
A_5_f:  EQU $0370 / $20
As_5_f: EQU $03a4 / $20
B_5_f:  EQU $03db / $20
C_6_f:  EQU $0417 / $20
Cs_6_f: EQU $0455 / $20
D_6_f:  EQU $0497 / $20
Ds_6_f: EQU $04dd / $20
E_6_f:  EQU $0527 / $20
F_6_f:  EQU $0575 / $20
Fs_6_f: EQU $05c8 / $20
G_6_f:  EQU $0620 / $20
Gs_6_f: EQU $067d / $20
A_6_f:  EQU $06e0 / $20
As_6_f: EQU $0749 / $20
B_6_f:  EQU $07b8 / $20
C_7_f:  EQU $082d / $20
Cs_7_f: EQU $08a9 / $20
D_7_f:  EQU $092d / $20
Ds_7_f: EQU $09b9 / $20
E_7_f:  EQU $0a4d / $20
F_7_f:  EQU $0aea / $20
Fs_7_f: EQU $0b90 / $20
G_7_f:  EQU $0c40 / $20
Gs_7_f: EQU $0cfa / $20
A_7_f:  EQU $0dc0 / $20
As_7_f: EQU $0e91 / $20
B_7_f:  EQU $0f6f / $20
C_8_f:  EQU $105a / $20
Cs_8_f: EQU $1153 / $20
D_8_f:  EQU $125b / $20
Ds_8_f: EQU $1372 / $20
E_8_f:  EQU $149a / $20
F_8_f:  EQU $15d4 / $20
Fs_8_f: EQU $1720 / $20
G_8_f:  EQU $1880 / $20
Gs_8_f: EQU $19f5 / $20
A_8_f:  EQU $1b80 / $20
As_8_f: EQU $1d23 / $20
B_8_f:  EQU $1ede / $20

;----------
; play_beep
; inputs: a = updated cell count
;----------
play_beep:
push af
push bc
push de
push hl
push ix

; move notes to correct position based on count
ld b, a
ld hl, beep_notes
play_beep_loop:
    inc hl
    inc hl
    inc hl
    inc hl
    djnz play_beep_loop

ld c, (hl)
inc hl
ld b, (hl) ; bc = note
inc hl
ld e, (hl)
inc hl
ld d, (hl) ; de = frequency
ld h, b
ld l, c ; hl = note

call BEEP

pop ix
pop  hl
pop  de
pop  bc
pop  af
ret

beep_notes:
dw C_2, C_2_f, D_2, D_2_f, E_2, E_2_f, G_2, G_2_f, A_2, A_2_f
dw C_3, C_3_f, D_3, D_3_f, E_3, E_3_f, G_3, G_3_f, A_3, A_3_f
dw C_4, C_4_f, D_4, D_4_f, E_4, E_4_f, G_4, G_4_f, A_4, A_4_f
dw C_5, C_5_f, D_5, D_5_f, E_5, E_5_f, G_5, G_5_f, A_5, A_5_f
dw C_6, C_6_f, D_6, D_6_f, E_6, E_6_f, G_6, G_6_f, A_6, A_6_f
;dw C_7, C_7_f, D_7, D_7_f, E_7, E_7_f, G_7, G_7_f, A_7, A_7_f
;dw C_8, C_8_f, D_8, D_8_f, E_8, E_8_f, G_8, G_8_f, A_8, A_8_f
