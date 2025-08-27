int:
            ; save all registers
            exx
            ex af, af'

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
            ex af, af'
            exx            

ei ; activates interruptions
reti ; exits

int_count:  db tracker_note_wait ; count between notes
