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
dw C_0, C_0_f  
dw Cs_0,Cs_0_f 
dw D_0, D_0_f  
dw Ds_0,Ds_0_f 
dw E_0, E_0_f  
dw F_0, F_0_f  
dw Fs_0,Fs_0_f 
dw G_0, G_0_f  
dw Gs_0,Gs_0_f 
dw A_0, A_0_f  
dw As_0,As_0_f 
dw B_0, B_0_f  
dw C_1, C_1_f  
dw Cs_1,Cs_1_f 
dw D_1, D_1_f  
dw Ds_1,Ds_1_f 
dw E_1, E_1_f  
dw F_1, F_1_f  
dw Fs_1,Fs_1_f 
dw G_1, G_1_f  
dw Gs_1,Gs_1_f 
dw A_1, A_1_f  
dw As_1,As_1_f 
dw B_1, B_1_f  
dw C_2, C_2_f  
dw Cs_2,Cs_2_f 
dw D_2, D_2_f  
dw Ds_2,Ds_2_f 
dw E_2, E_2_f  
dw F_2, F_2_f  
dw Fs_2,Fs_2_f 
dw G_2, G_2_f  
dw Gs_2,Gs_2_f 
dw A_2, A_2_f  
dw As_2,As_2_f 
dw B_2, B_2_f  
dw C_3, C_3_f  
dw Cs_3,Cs_3_f 
dw D_3, D_3_f  
dw Ds_3,Ds_3_f 
dw E_3, E_3_f  
dw F_3, F_3_f  
dw Fs_3,Fs_3_f 
dw G_3, G_3_f  
dw Gs_3,Gs_3_f 
dw A_3, A_3_f  
dw As_3,As_3_f 
dw B_3, B_3_f  
dw C_4, C_4_f  
dw Cs_4,Cs_4_f 
dw D_4, D_4_f  
dw Ds_4,Ds_4_f 
dw E_4, E_4_f  
dw F_4, F_4_f  
dw Fs_4,Fs_4_f 
dw G_4, G_4_f  
dw Gs_4,Gs_4_f 
dw A_4, A_4_f  
dw As_4,As_4_f 
dw B_4, B_4_f  
dw C_5, C_5_f  
dw Cs_5,Cs_5_f 
dw D_5, D_5_f  
dw Ds_5,Ds_5_f 
dw E_5, E_5_f  
dw F_5, F_5_f  
dw Fs_5,Fs_5_f 
dw G_5, G_5_f  
dw Gs_5,Gs_5_f 
dw A_5, A_5_f  
dw As_5,As_5_f 
dw B_5, B_5_f  
dw C_6, C_6_f  
dw Cs_6,Cs_6_f 
dw D_6, D_6_f  
dw Ds_6,Ds_6_f 
dw E_6, E_6_f  
dw F_6, F_6_f  
dw Fs_6,Fs_6_f 
dw G_6, G_6_f  
dw Gs_6,Gs_6_f 
dw A_6, A_6_f  
dw As_6,As_6_f 
dw B_6, B_6_f  
dw C_7, C_7_f  
dw Cs_7,Cs_7_f 
dw D_7, D_7_f  
dw Ds_7,Ds_7_f 
dw E_7, E_7_f  
dw F_7, F_7_f  
dw Fs_7,Fs_7_f 
dw G_7, G_7_f  
dw Gs_7,Gs_7_f 
dw A_7, A_7_f  
dw As_7,As_7_f 
dw B_7, B_7_f  
dw C_8, C_8_f  
dw Cs_8,Cs_8_f 
dw D_8, D_8_f  
dw Ds_8,Ds_8_f 
dw E_8, E_8_f  
dw F_8, F_8_f  
dw Fs_8,Fs_8_f 
dw G_8, G_8_f  
dw Gs_8,Gs_8_f 
dw A_8, A_8_f  
dw As_8,As_8_f 
dw B_8, B_8_f