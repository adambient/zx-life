UDG: equ $5c7b ; RAM address of user defined graphics
OPEN_CHANNEL: equ $1601
VIDEORAM: equ $4000 ; address of video RAM
VIDEORAM_L: equ $1800 ; length of video RAM
VIDEOATT: equ $5800 ; address of attribute RAM
VIDEOATT_L: equ $0300 ; length of attribute RAM

;----------
; print_string
; inputs: hl = first position of a null ($00) terminated string
; alters: af, hl
;----------
print_string:
            ld   a, (hl) ; a = character to be printed
            or   a ; sets z register if 0
            ret  z ; return if z register set
            rst  $10 ; prints the character
            inc  hl ; hl = next character
            jr   print_string ; loop

;----------
; clear_screen
; clears all pixels, sets ink to black and paper white
; alters: bc, de, hl
;----------
clear_screen:
            ; clear pixels
            ld hl, VIDEORAM ; hl = video RAM address
            ld de, VIDEORAM+1 ; de = next address
            ld bc, VIDEORAM_L-1 ; bc = length of video RAM - 1 (to loop)
            ld (hl), $00 ; clear first position
            ldir ; loop and clear the rest
            ; clear attributes
            ld hl, VIDEOATT ; hl = attribute RAM address
            ld de, VIDEOATT+1 ; de = next address
            ld bc, VIDEOATT_L-1 ; bc = length of attribute RAM - 1 (to loop)
            ld (hl), %00111000 ; paper white, ink black
            ldir ; loop and set the rest      
            ret

;----------
; reset_cursor
; ensures next call to rst $10 is at 0, 0 of current channel
; alters: af
;----------
reset_cursor:
            ld a, $16
            rst $10
            ld a, $00
            rst $10
            rst $10 ; reset position
            ret

;----------
; init_game_screen
; initialises the screen for the game
; alters: bc, de, hl
;----------
init_game_screen: 
            ld hl, cell_sprite
            ld ($5c7b), hl ; load cell_sprite into position 1 of UDGs so can use ROM routine            
            ; clear attributes to avoid flicker of ROM print
            ld hl, VIDEOATT ; hl = attribute RAM address
            ld de, VIDEOATT+1 ; de = next address
            ld bc, VIDEOATT_L-1 ; bc = length of attribute RAM - 1 (to loop)
            ld (hl), %00111111 ; paper white, ink white
            ldir ; loop and set the rest      
            ; load first 22 rows (channel 2)
            call reset_cursor
            ld b, 22
init_game_screen_loop:
            ld hl, screen_data
            call  print_string
            djnz init_game_screen_loop
            ; load last 2 rows  (channel 1)
            ld a, 1
            call OPEN_CHANNEL ; ROM routine
            call reset_cursor                        
            ld hl, screen_data
            call  print_string
            ld hl, screen_data
            call  print_string
            ret

;----------
; clear_cell_at
; inputs: d = y, e = x
; alters: a, bc, de
;----------
clear_cell_at:
            call get_attr_address
            ld (hl), %00111111 ; paper white, ink white
            ex de, hl ; h = y, l = x
            ret

;----------
; print_cell_at
; inputs: d = y, e = x, h = ink, l = paper
; alters: a, bc, de, hl
;----------
print_cell_at:
            ld b, l ; b = paper
            ld c, h ; c = ink
            call get_attr_address
            ld a, b ; a = paper
            or a ; clear flags
            rla
            rla
            rla
            or c
            ld (hl), a ; set attribute value
            ret

;----------
; print_block_at
; inputs: d = y, e = x, h = ink, l = paper
; alters: a, bc, de
;----------
print_block_at:
            ld b, l ; b = paper
            call get_attr_address
            ld a, b ; a = paper
            or a ; clear flags
            rla
            rla
            rla
            or b ; use paper colour for ink
            or %01000000 ; bright
            ld (hl), a ; set attribute value
            ret

;----------
; get_attr_address - adapted from a routine by Jonathan Cauldwell
; inputs: d = y, e = x
; outputs: hl = location of attribute address
; alters: hl
;----------
get_attr_address:
            ld a,d
            rrca
            rrca
            rrca
            ld l,a
            and $03
            add a, $58
            ld h,a
            ld a,l
            and $e0
            ld l,a
            ld a,e
            add a,l
            ld l,a
            ret

cell_sprite:
            defb %10101010
            defb %01010101
            defb %10101010
            defb %01010101
            defb %10101010
            defb %01010101
            defb %10101010
            defb %01010101

screen_data:
db $10, $07, $11, $07 ; ink white, paper white
db $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $00