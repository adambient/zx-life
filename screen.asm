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