int:
            ; save all registers
            push af
            push hl
            push bc
            push de
            push ix
            push af
            ex af,af'
            push af

            ; BEGIN - interrupt routine
            ; wait for tracker_note_wait ticks
            ld hl, int_count ; load count
            ld a, (hl) ; into a
            dec (hl) ; decrease count
            jr nz, int_end ; end if not zero
            ld (hl), tracker_note_wait ; reset count            

            call tracker_play ; call tracker to play next notes
            ; END - interrupt routine

int_end:
            ; retrieve all saved registers
            pop af
            ex af,af'
            pop af
            pop ix
            pop de
            pop bc
            pop hl
            pop af

ei ; activates interruptions
reti ; exits

int_count:  db tracker_note_wait ; count between notes
