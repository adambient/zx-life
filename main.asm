org  $5dad

; CONSTANTS
KEYDEL: equ $0c ; ASCII value for delete
KEYENT: equ $0d ; ASCII value for enter
KEYSPC: equ $20 ; ASCII value for space
FLAGS_KEY: equ $5c3b ; ROM address for keypad status when using im1
LAST_KEY: equ $5c08 ; ROM address for last key pressed when using im1
CURSOR: equ $5c88 ; ROM address for cursor position on screen channel 1 - if loaded at bc then b = y, c = x
LOCATE: equ $0dd9 ; ROM address for AT routine to position the cursor
MAX_MSG_LENGTH: equ $ff ; the maximum message length is 255

MAX_CHAR_COUNT: equ $14 ; max wait between chars is 20
MIN_CHAR_COUNT: equ $04 ; min wait between chars is 4
MIN_ACTIVITY: equ $0a ; min activity between chars is 10

main:
            call clear_screen
            ld hl, message_prompt
            call  print_string
            call get_message
            call clear_screen
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
            sub $07 ; is it 7?
            jr nz, main_draw_grid ; no, skip
            ld b, $01 ; yes, reset
main_draw_grid:
            push bc ; store ink, message_index
            ld e, b ; e = ink
            ld d, $07 ; d = paper
            call draw_grid
            call iterate_grid
            pop bc ; pop ink, message_index
            inc (ix) ; increase count
            jr main_loop ; loop
            ret ; never gets hit

;----------
; get_message_asm
; reads keyboard for message to display, populating _message
; alters: af, bc, de, hl
;----------
get_message:
            ld hl, message ; hl = address of message
            ld (hl), $00        
            ld d, $00 ; d = tracks the mssage length
            ei ; enable interrupts (mode 1) so we can use ROM input routines
            call get_message_loop
            di ; disable interrupts again
            ret
get_message_loop:
            push hl ; preserve hl
            call wait_key ; wait for valid key
            pop hl ; retrieve hl
            cp KEYDEL ; delete?
            jr z, get_message_delete ; yes, goto delete
            cp KEYENT ; enter?
            jr z, get_message_enter ; yes, goto enter
            push de ; preserves de
            ld e, a ; e = code ASCII
            ld a, MAX_MSG_LENGTH ; a = maximum message length
            cp d ; d = maximum length?
            ld a, e ; a = code ASCII
            pop de ; retrieve de
            jr z, get_message_loop ; d = maximum length so loop without appending
            ld (hl), a ; append character to name
            inc hl ; hl = next position
            rst $10 ; print character
            inc d ; increment message length counter
            jr get_message_loop ; wait for next character
get_message_delete:
            ld a, $00 ; a = 0
            cp d ; length 0?
            jr z, get_message_loop ; yes, wait for next character
            dec d ; decrement message length counter
            dec hl ; hl-=1, previous character
            ld a, ' ' ; a = space
            ld (hl), a ; clear previous character
            ld bc, (CURSOR) ; bc = cursor position
            inc c ; bc = previous column for AT
            call AT ; position cursor
            rst $10 ; delete the display character	
            call AT ; position cursor
            jr get_message_loop ; wait for next character
get_message_enter:
            ld a, 0 ; a = 0
            cp d ; length 0?
            jr z, get_message_loop ; yes, request another character
            ret ; exit with populated message

;----------
; wait_key
; outputs: a = ASCII code of the next pressed key
; alters: af, hl
;----------
wait_key:
            ld hl, FLAGS_KEY ; hl = address flag keyboard
            set $03, (hl) ; input mode L
wait_key_loop:
            bit $05, (hl) ; key pressed?
            jr z, wait_key_loop ; not pressed, loop
            res $05, (hl) ; bit set to 0 for future inspections
wait_key_load_key:
            ld hl, LAST_KEY ; hl = last key pressed address
            ld a, (hl) ; a = last key pressed
            cp $80 ; ASCII > 127?
            jr nc, wait_key ; yes, invalid key, loop
            cp KEYDEL ; delete?
            ret z ; yes, exit
            cp KEYENT ; enter?
            ret z ; yes, exit
            cp KEYSPC ; space?
            jr c, wait_key ; ASCII < space, invalid, loop
            ret ; exits

;----------
; AT
; position the cursor while maintaining registers - the upper corner is at 24, 33
; inputs: b = y, c = x
;----------
AT:
            push af
            push bc
            push de
            push hl ; preserve registers
            call LOCATE ; position cursor using ROM routine
            pop hl
            pop de
            pop bc
            pop af ; retrieves records
            ret

include "game.asm"

count: ds 1
message: ds MAX_MSG_LENGTH+1
message_prompt:
db "Welcome To ZX Life!", KEYENT, KEYENT, "Please enter message to display,maximum 255 characters:", KEYENT, KEYENT, $00

end $5dad