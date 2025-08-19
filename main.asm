include "consts.asm"

org  28160

; initialize mixer to all notes but no noises
ld a, 7
ld h, %00111000
call tracker_psg

; initialize interrupts
di ; disables interrupts
ld a, $28 ; a = 40 (specifies address)
ld i, a ; i = a
im 2 ; mode 2 interrupts
ei ; enable interrupts

; CONSTANTS
MAX_MSG_LENGTH: equ $ff ; the maximum message length is 255
MAX_CHAR_COUNT: equ $14 ; max wait between chars is 20
MIN_CHAR_COUNT: equ $04 ; min wait between chars is 4
MIN_ACTIVITY: equ $0a ; min activity between chars is 10

            ; BEGIN - load parameters via BASIC DEF FN which populates parameters at DEFADD
            ld hl, (DEFADD)
            inc hl
            inc hl
            inc hl
            inc hl
            ld e, (hl)
            inc hl
            ld d, (hl) ; de = location of string
            inc hl
            ld c, (hl)
            inc hl
            ld b, (hl) ; bc = length of string
            ; END - load parameters

            ; populate message
            ld (count), bc            
            ld hl, message
            ex de, hl ; de = address of message, hl = location of string
            ldir

            ld c, $00 ; message_index
            ld l, $00 ; updated_cell_count = 0
            ld b, $00 ; ink = 0
            ld ix, count
            ld (ix), $00 ; count = 0
main_loop:
            ld a, (ix) ; a = count              
            cp MIN_CHAR_COUNT ; is count >= MIN_CHAR_COUNT?
            jr c, main_cycle_ink ; no, bypass add character
            cp MAX_CHAR_COUNT ; is count >= MAX_CHAR_COUNT?
            jr nc, main_add_character ; yes, add character
            ld a, l ; a = updated_cell_count                              
            cp MIN_ACTIVITY ; is update_cell_count < MIN_ACTIVITY
            jr nc, main_cycle_ink ; no, bypass add character
main_add_character:            
            ld (ix), $00 ; count = 0
            ld de, message+0
            ld l, c ; l = message_index
            ld h, $00
            add hl, de
            ld a, (hl) ; message[message_index]
            or a ; !message[message_index]?
            jr nz, main_reset_message ; no, skip
            ld bc, $0100 ; b = 1 (ink), c = 0 (message_index)
main_reset_message:
            ld l, c ; l = message_index
            inc c ; message_index++
            ld h, $00
            add hl, de
            ld a, (hl) ; a = message[message_index]
            cp $20 ; is character ' '?
            jr nz, main_add_character_do ; no, skip
            ld a, $5f ; yes, set to '_'
main_add_character_do:
            push bc ; store ink, message_index
            ld b, $00
            ld c, a ; bc = current char
            ld de,$080a ; x = 10, y = 8
            call draw_chr_at ; draw char
            pop bc ; pop ink, message_index
main_cycle_ink:
            inc b ; inc ink
            ld a, b
            sub $08 ; is it 7?
            jr nz, main_draw_grid ; no, skip
            ld b, $01 ; yes, reset
main_draw_grid:
            push bc ; store ink, message_index
            ld e, b ; e = ink
            ld d, $00 ; d = paper            
            call draw_grid            
            call iterate_grid
            ld a, l ; a = updated_cell_count                  
            pop bc ; pop ink, message_index
            inc (ix) ; increase count
            jr main_loop ; loop
            ret ; never gets hit

include "game.asm"

count: ds 1
message: ds MAX_MSG_LENGTH+1

include "tracker.asm" ; ay music tracker

org 32348 ; interrupt code at specified (above) address
include "int.asm"