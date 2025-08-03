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
ld a, (BORDER)		;get border color from BASIC vars to keep it unchanged
out (254),a			;11

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
