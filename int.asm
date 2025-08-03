include "consts.asm"

org  $7e5c

int:
            ; save all registers (comment out unused)
            ;push af
            ;push hl
            ;push bc
            ;push de
            ;push ix
            ;push iy
            ;exx
            ;ex af, af'
            push af
            push hl
            ;push bc
            ;push de

            ; BEGIN - interrupt routine

            ; wait for 100 ticks
            ld hl, int_count ; load count
            ld a, (hl) ; into a
            dec (hl) ; decrease count
            jr nz, int_end ; end if not zero
            ld (hl), 100 ; reset count

            ; cycle border
            ld hl, BORDER ; load border colour
            ld a, (hl) ; into a
            out (254), a ; set border
            dec (hl) ; decrease border colour
            jr nz, int_end ; return if not zero
            ld (hl), 7 ; reset border colour

            ; END - interrupt routine

int_end:
            ; retrieve all saved registers
            ;pop de
            ;pop bc
            pop hl
            pop af
            ;ex af, af'
            ;exx
            ;pop iy
            ;pop ix
            ;pop de
            ;pop bc
            ;pop hl
            ;pop af

ei ; activates interruptions
reti ; exits

int_count:  db 100 ; count between change border colour