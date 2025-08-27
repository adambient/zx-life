tracker_note_wait: equ 10 ; wait 0.2 seconds between notes (PAL)

tracker_reset_notes:
            
tracker_play:
            ; load tracker
            ld hl, tracker_note
            ld e, (hl)
            inc hl
            ld d, (hl)            
            ex de, hl ; hl = address pointed to by tracker_note
            ld a, (hl) ; a = tracker
            or a ; populate flags
            jr nz, tracker_play_continue ; if empty then reset,else jump to continue

            ; set all current notes to beginning of scores
            ld hl, tracker_channel1_note
            ld de, tracker_channel1_score - 2 ; first new note moves into position
            ld (hl), e
            inc hl
            ld (hl), d
            inc hl ; hl = tracker_channel2_note
            ld de, tracker_channel2_score - 2 ; first new note moves into position
            ld (hl), e
            inc hl
            ld (hl), d
            inc hl ; hl = tracker_channel3_note
            ld de, tracker_channel3_score - 2 ; first new note moves into position
            ld (hl), e
            inc hl
            ld (hl), d
            inc hl ; hl = tracker_note
            ld de, tracker_score
            ld (hl), e
            inc hl
            ld (hl), d
            ex de, hl ; hl = address pointed to by tracker_note
            ld a, (hl) ; a = tracker

tracker_play_continue:
            ; play notes based on tracker in a
            push af ; save a - tracker for channel 2                        
            ld de, $0800 ; d = channel 1 volume regiser (8), e = channel 1 fine tune register (0)
            ld hl, tracker_channel1_note ; hl = channel 1 current note
            call tracker_play_note
            ; channel 2
            pop af ; a = tracker
            rra
            rra ; ...into position 0
            push af ; save for channel 3            
            ld de, $0902 ; d = channel 2 volume regiser (9), e = channel 2 fine tune register (2)
            ld hl, tracker_channel2_note ; hl = channel 2 current note
            call tracker_play_note
            ; channel 3
            pop af ; a = tracker
            rra
            rra ; ...into position 0
            ld de, $0a04 ; d = channel 3 volume regiser (10), e = channel 3 fine tune register (4)
            ld hl, tracker_channel3_note ; hl = channel 3 current note
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

; inputs - a: tracker, d: channel volume register, e: channel fine tune register, hl: channel current note
tracker_play_note:
            push hl ; store current note
            and %00000011 ; only keep bits 0 and 1 of tracker so can check against 0-3
            jr nz, tracker_play_note_continue_1 ; if result of and is non zero then jump to continue
            ld a, d
            ld h, 0
            call tracker_psg ; no - silence note
            pop hl ; restore current note
            ret
tracker_play_note_continue_1:
            ; a is 1-3, quick calc to get relative volume
            ld h, a ; 1,2,3
            add a, a ; 2,4,6
            add a, a ; 4,8,12
            add a, h ; 5,10,15
            inc a ; 6,11,16 (16=use envelope)
            ld h, a
            ld a, d ; set channel vol
            call tracker_psg
            ld a, h
            cp 16 ; use envelope?
            pop hl ; restore current note
            jr nz, tracker_play_note_continue_2 ; use envelope? no, continue using default volume
            ; yes, also progress note to next
            ld a, (hl)
            add a, 2
            ld (hl), a
            jr nc, tracker_play_note_continue_2
            inc hl
            inc (hl)
            dec hl ; reset pointer to current note
tracker_play_note_continue_2:           
            ; load values
            ld a, e ; a = fine tune register
            ; retrieve current note...
            ld e, (hl)
            inc hl
            ld d, (hl)
            ex de, hl ; hl = address pointed to by channel1_note
            ; ...into d and e...
            ld d, (hl) ; d = rhs - fine tune (rhs as little endian)
            inc hl
            ld e, (hl) ; e = lhs - course tune (lhs as little endian)
            ; ...and set registers 0 and 1            
            ld h, d ; fine tune
            call tracker_psg
            inc a ; a = course tune register
            ld h, e ; course tune
            call tracker_psg
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
dw a3
dw e3
dw c4
dw e3
dw b3
dw e3
dw a3
dw e3
dw gs3
dw e3
dw b3
dw e3
dw a3
dw e3
dw gs3
dw e3
dw g3
dw d3
dw b3
dw d3
dw a3
dw d3
dw g3
dw d3
dw fs3
dw d3
dw g3
dw d3
dw a3
dw d3
dw g3
dw d3
dw a3
dw e3
dw c4
dw e3
dw b3
dw e3
dw a3
dw e3
dw d4
dw e3
dw b3
dw e3
dw gs3
dw e3
dw b3
dw e3
dw g3
dw d3
dw b3
dw d3
dw a3
dw d3
dw c4
dw d3
dw b3
dw d3
dw g3
dw d3
dw fs3
dw d3
dw g3
dw d3
dw c3
dw c3
dw d3
dw b2
dw g2
dw d2
dw g2
dw a2
dw b2
dw a2
dw g2
dw a2
dw fs2
dw g2
dw a2
dw fs2
dw d2
dw e2
dw fs2
dw d2
dw e3
dw c3
dw d3
dw e3
dw d3
dw e3
dw d3
dw b2
dw gs2
dw b2
dw c3
dw d3
dw b2
dw c3
dw d3
dw e3
dw c3
dw a2
dw b2
dw c3
dw a2
dw d3
dw c3
dw b2
dw c3
dw d3
dw b2
dw c3
dw d3
dw gs2
dw a2
dw b2
dw c3
dw fs2
dw b2
dw g2
dw e2
dw a2
dw g2
dw fs2
dw e2
dw a2
dw fs2
dw d2
dw e2
dw a2
dw fs2
dw d2
dw d3
dw b2
dw c3
dw b2
dw a2
dw b2
dw c3
dw d3
dw gs2
dw a2
dw b2
dw c3
dw fs2
dw g2
dw b2
dw a2
dw g2
dw fs2
dw a2
dw g2
dw fs2
dw e2
dw a2
dw fs2
dw d2
dw e2
dw a2
dw fs2
dw d2
dw e2
dw a2
dw fs2
dw d2
dw e2
dw a2
dw b2
dw c3
dw f2
dw g2
dw f2
dw e2
dw a2
dw b2
dw c3
dw f2
dw d3
dw c3
dw b2
dw e3
dw c3
dw d3
dw b2
dw c3
dw a2
dw gs2
dw a2
dw b2
dw gs2
dw a2
dw b2
dw gs2
dw a2
dw b2
dw gs2
dw a2
dw a2
dw b2
dw c3
dw a2
dw b2
dw c3
dw a2
dw b2
dw b2
dw c3
dw d3
dw b2
dw c3
dw d3
dw b2
dw c3
dw g3
dw a3
dw f3
dw g3
dw e3
dw f3
dw d3
dw e3
dw gs2
dw a2
dw b2
dw gs2
dw a2
dw b2
dw gs2
dw a2
dw a2
dw b2
dw c3
dw a2
dw b2
dw c3
dw a2
dw b2
dw e3
dw c3
dw d3
dw b2
dw gs2
dw a2
dw a2

tracker_channel2_score:
dw a1
dw e1
dw a1
dw c2
dw b1
dw gs1
dw e1
dw gs1
dw g1
dw b1
dw d2
dw g1
dw b1
dw d1
dw g1
dw b1
dw a1
dw e1
dw a1
dw b1
dw c2
dw b1
dw a1
dw e1
dw b1
dw a1
dw gs1
dw a1
dw gs1
dw e1
dw d1
dw e1
dw d2
dw fs2
dw d2
dw c2
dw b1
dw a1
dw b1
dw d2
dw a1
dw b1
dw c2
dw a1
dw fs1
dw g1
dw a1
dw fs1
dw a1
dw b1
dw e1
dw e1
dw gs1
dw g1
dw e1
dw c2
dw a1
dw fs1
dw d1
dw a1
dw fs1
dw b1
dw g1
dw d1
dw g1
dw b1
dw b1
dw c2
dw d1
dw gs1
dw a1
dw b1
dw c2
dw fs1
dw g1
dw b1
dw g1
dw e1
dw d1
dw d1
dw a1
dw d1
dw a1
dw d1
dw g1
dw a1
dw a1
dw e1
dw gs1
dw b1
dw e1
dw a1
dw fs1
dw d1
dw fs1
dw e1
dw b1
dw g1
dw e1
dw d1
dw a1
dw fs1
dw d1
dw a1
dw d1
dw a1
dw d1
dw a1
dw d1
dw a1
dw a1
dw f1
dw c2
dw as1
dw a1
dw a1
dw f1
dw f1
dw e1
dw d1
dw a2
dw g2
dw f2
dw e2
dw e2
dw e1
dw e2
dw c2
dw f2
dw f2
dw d2
dw g2
dw g2
dw e2
dw d2
dw b1
dw c2
dw a1
dw b1
dw g1
dw a1
dw f1
dw gs2
dw gs2
dw e2
dw a2
dw c3
dw b2
dw gs1
dw a1
dw a1

tracker_channel3_score:
dw g2
dw a2
dw b2
dw e2
dw a2
dw b2
dw c3
dw a2
dw fs2
dw g2
dw a2
dw d2
dw b2
dw g2
dw g2
dw a2
dw g2
dw a2
dw f2
dw e2
dw d2
dw cs2
dw a2
dw f2
dw a2
dw g2
dw g2
dw c3
dw a2
dw b2
dw g2
dw a2
dw f2
dw e2
dw fs2
dw gs2
dw e1
dw f1
dw g1
dw d1
dw e2
dw c1
dw d3
dw b2
dw c2
dw a2
dw b2
dw gs1
dw a1
dw a2
dw g2
dw e2

tracker_score:
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10000011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001110
db %10001110
db %10001110
db %10001110
db %10001110
db %10001111
db %10001111
db %10001111
db %10001110
db %10001110
db %10001110
db %10001110
db %10001110
db %10001110
db %10001110
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001010
db %10001011
db %10001011
db %10001111
db %10001010
db %10001011
db %10001010
db %10001111
db %10001010
db %10001111
db %10001010
db %10001111
db %10001010
db %10001011
db %10001010
db %10111111
db %10111011
db %10111111
db %10111011
db %10111111
db %10111011
db %10111111
db %10111011
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001010
db %10001111
db %10001010
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001010
db %10001010
db %10001010
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001011
db %10001111
db %10001010
db %10001010
db %10001010
db %10111111
db %10101011
db %10101011
db %10111111
db %10101010
db %10101010
db %10101010
db %10101010
db %10000000
db %10000000
db %10000000
db %10000000
db %10111111
db %10101010
db %10111111
db %10101010
db %10111111
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10111111
db %10101011
db %10101011
db %10111111
db %10101010
db %10101010
db %10101010
db %10101010
db %10000000
db %10000000
db %10000000
db %10000000
db %10111111
db %10101010
db %10111111
db %10101010
db %10111111
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10111111
db %10111011
db %10111111
db %10111011
db %10111111
db %10111011
db %10111111
db %10111011
db %10111111
db %10101010
db %10101010
db %10101010
db %10101010
db %10101010
db %10111111
db %10101011
db %10101011
db %10101011
db %10101011
db %10101011
db %10001111
db %10001111
db %10111111
db %10101011
db %10101011
db %10101011
db %10101011
db %10101011
db %10001111
db %10001111
db %10111111
db %10101011
db %10101011
db %10101011
db %10101011
db %10101011
db %10001111
db %10001111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10111111
db %10101011
db %10101011
db %10101011
db %10101011
db %10101011
db %10001111
db %10001111
db %10111111
db %10101011
db %10101011
db %10101011
db %10101011
db %10101011
db %10101011
db %10101011
db %10111111
db %10101011
db %10111111
db %10101011
db %10111111
db %10101010
db %10101010
db %10001111
db %10001111
db %10001010
db %10001010
db %10001010
db %10001010
db %10001010
db %10001010
db %10001010
db %00000000 ; end