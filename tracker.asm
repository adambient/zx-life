tracker_note_wait: equ 9 ; wait 0.18 seconds between notes (PAL)

tracker_reset_notes:
            ; set all current notes to beginning of scores
            ld hl, tracker_channel1_note
            ld de, tracker_channel1_score - 2 ; first new note moves into position
            ld (hl), e
            inc hl
            ld (hl), d
            ld hl, tracker_channel2_note
            ld de, tracker_channel2_score - 2 ; first new note moves into position
            ld (hl), e
            inc hl
            ld (hl), d
            ld hl, tracker_channel3_note
            ld de, tracker_channel3_score - 2 ; first new note moves into position
            ld (hl), e
            inc hl
            ld (hl), d
            ld hl, tracker_note
            ld de, tracker_score
            ld (hl), e
            inc hl
            ld (hl), d  
tracker_play:
            ; load tracker
            ld hl, tracker_note
            ld e, (hl)
            inc hl
            ld d, (hl)            
            ex de, hl ; hl = address pointed to by int_tracker_note
            ; if control bit not set then reset notes before continuing
            ld a, (hl)
            bit 7, a
            jr z, tracker_reset_notes

            ; play notes based on tracker in a
            push af ; a = tracker
            ex af,af'
            ld a, 0
            ex af,af' ; a' = fine tune register
            ld b, 8 ; channel 1 is register 8
            ld ix, tracker_channel1_note ; index current note 1
            call tracker_play_note
            ; channel 2
            pop af ; a = tracker
            rra
            rra ; ...into position 0
            push af
            ex af,af'
            ld a, 2
            ex af,af' ; a' = fine tune register
            ld b, 9 ; channel 2 is regiser 9
            ld ix, tracker_channel2_note ; index current note 2
            call tracker_play_note
            ; channel 3
            pop af ; a = tracker
            rra
            rra ; ...into position 0
            ex af,af'
            ld a, 4
            ex af,af' ; a' = fine tune register
            ld b, 10 ; channel 3 is regiser 10
            ld ix, tracker_channel3_note ; index current note 3
            call tracker_play_note

            ; overall envelope settings
            ld a,11
            ld h,32 ; 11 and 12 govern duration of envelope
            call tracker_psg 
            inc a            
            call tracker_psg ; send same value to 11
            ld a,13
            ld h,1 ; use envelope 1 (see page 155)
            call tracker_psg
                     
            ; move tracker to next memory location
            ld hl, tracker_note
            inc (hl)
            ret nz
            inc hl
            inc (hl)
            ret

tracker_psg:
            ld bc,$fffd
            out (c),a
            ld b,$bf
            out (c),h
            ret

; inputs - a: tracker, b: register, ix: current note, a':fine tune register (+1 for course tune)
tracker_play_note:
            bit 0, a ; is channel enabled?
            jr nz, tracker_play_note_1 ; yes, continue
            ld a, b
            ld h, 0
            call tracker_psg ; no - silence note
            ret
tracker_play_note_1:
            ld d, 11 ; use default volume (store in d)
            bit 1, a ; is channel a new note?
            jr z, tracker_play_note_2 ; no, continue using default volume
            ld d, 16 ; yes, use envelope (store in d)

            ; also progress note to next
            push ix
            pop hl ; hl = current note
            ld a, (hl)
            add a,2
            ld (hl), a
            jr nc, tracker_play_note_2
            inc hl ; handle carry
            inc (hl)
                        
tracker_play_note_2
            ex de, hl ; h = channel volume
            ld a, b ; set channel vol
            call tracker_psg
            ; play note
            push ix
            pop hl ; hl = current note
            ld e, (hl)
            inc hl
            ld d, (hl)
            ex de, hl ; hl = address pointed to by int_channel1_note
            ; ...into d and e...
            ld d, (hl) ; d = rhs - fine tune (rhs as little endian)
            inc hl
            ld e, (hl) ; e = lhs - course tune (lhs as little endian)
            ; ...and set registers 0 and 1
            ex af,af' ; a = fine tune register
            ld h, d ; fine tune
            call tracker_psg
            inc a ; a = course tune register
            ld h, e ; course tune
            call tracker_psg
            ex af,af'
            ret

tracker_channel1_note:
dw tracker_channel1_score - 2 ; first new note moves into position
tracker_channel2_note:
dw tracker_channel2_score - 2 ; first new note moves into position
tracker_channel3_note:
dw tracker_channel3_score - 2 ; first new note moves into position
tracker_note:
dw tracker_score

tracker_channel1_score:
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw f0
dw f1
dw f2
dw f1
dw f0
dw f1
dw f2
dw f1
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw f0
dw f1
dw f2
dw f1
dw f0
dw f1
dw f2
dw f1
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw d1
dw d2
dw d3
dw d2
dw d1
dw d2
dw d3
dw d2
dw d1
dw d2
dw d3
dw d2
dw d1
dw d2
dw d3
dw d2
dw c1
dw c2
dw c3
dw c2
dw c1
dw c2
dw c3
dw c2
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1
dw d1
dw d2
dw d3
dw d2
dw d1
dw d2
dw d3
dw d2
dw d1
dw d2
dw d3
dw d2
dw d1
dw d2
dw d3
dw d2
dw f1
dw f2
dw f3
dw f2
dw f1
dw f2
dw f3
dw f2
dw g0
dw g1
dw g2
dw g1
dw g0
dw g1
dw g2
dw g1

tracker_channel2_score:
dw b2
dw b2
dw a2
dw b2
dw c3
dw d3
dw c3
dw b2
dw a2
dw b2
dw c3
dw b2
dw d3
dw d3
dw c3
dw d3
dw e3
dw f3
dw e3
dw d3
dw c3
dw c3
dw b2
dw a2
dw a2
dw g2
dw f2
dw g2
dw b2
dw a2
dw g2
dw f2
dw d3
dw a2
dw f3
dw e3
dw c3
dw d3
dw c3
dw d3
dw b2
dw a2
dw g2
dw f2
dw d3
dw e3
dw f3
dw f3
dw c3
dw b2
dw a2
dw b2

tracker_channel3_score:
dw $000000

tracker_score:
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10001101
db %10001111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10001111
db %10001101
db %10000111
db %10001101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10001101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10001101
db %10001111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10001111
db %10001101
db %10000111
db %10001101
db %10000111
db %10000101
db %10001111
db %10001101
db %10000111
db %10001101
db %10000111
db %10000101
db %10001111
db %10001101
db %10001111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10001111
db %10001101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10001111
db %10001101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10001111
db %10001101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10001111
db %10001101
db %10001111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %10000111
db %10000101
db %00000000 ; end