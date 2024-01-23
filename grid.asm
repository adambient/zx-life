; CONSTANTS
COMPRESSED_GRID_WIDTH: equ $10 ; half of GRID_WIDTH rounded up to next even number (16)
GRID_HEIGHT: equ $18 ; 24
GRID_WIDTH: equ $20 ; 32
MAX_ACTIVE_CELLS: equ $ff ; 255

;----------
; get_grid_value
; inputs: d = y, e = x
; outputs: hl = grid value
; alters: af, bc, de, hl
;----------
get_grid_value:
            ld b, d
            ld c, e
            call load_cell_location            
            ld a, (hl) ; load 8 bit value into a
            bit $00, c ; is x even?
            jr z, get_grid_value_even
            or a ; clear carry so doesn't get rotated into number
            rra
            rra
            rra
            rra ; rotate the last 4 bits to the first 4
            jr get_grid_value_end
get_grid_value_even:
            and $0f ; blank out the last 4 bits
get_grid_value_end:
            ld h, $00
            ld l, a ; hl = grid value
            ret

;----------
; set_grid_value_asm
; inputs: b = y, c = x, e = grid value
; alters: a, bc, de, hl
;----------
set_grid_value:
            ld b, d ; b = y
            ld d, e ; d = x
            ld e, c ; e = grid value
            ld c, d ; c = x
            ld d, $00 ; de = grid value

            ld a, e ; a = grid value
            ex af, af' ; store a
            call load_cell_location ; load cell location bc into hl
            ex af, af' ; retrieve a            
            bit $00, c ; is x even?
            jr z, set_grid_value_even
            or a ; clear carry so doesn't get rotated into number
            rla ; x not even
            rla
            rla
            rla ; rotate the first 4 bits to the last 4
            ld e, a ; e = given value on rhs
            ld a, (hl)            
            and $0f ; a = current lhs value
            jr set_grid_value_end
set_grid_value_even: ; x is even
            and $0f ; blank out the last 4 bits so we don't overwrite
            ld e, a ; e = given value on lhs
            ld a, (hl)            
            and $f0 ; a = current rhs value
set_grid_value_end:
            or e ; a = combined given and current value
            ld (hl), a ; store back in location
            ret

;----------
; load_cell_location
; inputs: b = y, c = x
; outputs: hl = cell location within grid
; alters: a, b, de, hl
;----------
load_cell_location:            
            ld a, c ; load a with x
            or a ; clear carry flag so doesn't get rotated into number
            rra ; shift-right i.e. divide by 2
            ld hl, grid ; point hl at grid
            ld d, $00 
            ld e, a ; de = a
            add hl, de ; hl = _grid + x/2
            ;ld d, $00 - already 0
            ld e, b ; de = y           
            ex de, hl ; hl = y
            add hl, hl
            add hl, hl
            add hl, hl
            add hl, hl ; hl = y * COMPRESSED_GRID_WIDTH(=16)
            add hl, de ; hl _grid + (x / 2) + (y * COMPRESSED_GRID_WIDTH)
            ret

grid: ds COMPRESSED_GRID_WIDTH*GRID_HEIGHT
updated_cell_count: ds 1, $00
updated_cells: ds MAX_ACTIVE_CELLS*2, $00
active_cell_count: ds 1, $00
active_cells: ds MAX_ACTIVE_CELLS*2, $00