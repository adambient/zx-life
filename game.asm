CELL_ALIVE: equ $00
CELL_BORN: equ $01
CELL_DIES: equ $02
CELL_ACTIVE: equ $03

;----------
; draw_grid
; inputs: e = ink, d = paper
; alters: all registers
;----------
draw_grid:
            ld hl, active_cell_count
            ld (hl), $00 ; active_cell_count = 0

            ld hl, updated_cell_count

            ld a, (hl) ;updated_cell_count == 0 check
            cp $00 ; is it 0?
            ret z ; yes, return
            
            ld b, (hl) ; counter = updated_cell_count
            ld hl, updated_cells ; pointer to array
draw_grid_loop:
            push bc ; store counter
            ld c, (hl)
            inc hl
            ld b, (hl) ; bc = cell_location
            inc hl
            push hl ; store pointer
            push de ; store ink

            push de ; store ink

            ld d, b ; d = y
            ld e, c ; e = x

            ; get grid value
            push de ; store x,y
            call get_grid_value ; hl = grid_value
            pop de ; restore x,y
            ld b, h
            ld c, l ; bc = grid_value
            pop hl ; restore hl = ink
            
            ; bc = grid_value, d = y, e = x
            bit CELL_ALIVE, c ; is cell alive?
            jr z, draw_grid_cell_dead ; no, goto cell_dead
            bit CELL_BORN, c ; is cell born?
            jr z, draw_grid_cell_block ; no, goto cell_block

            ; born cells are generated, show as regular cells
            push bc ; store grid_value
            push de ; store x,y
            push hl ; store ink
            call print_cell_at
            pop hl ; restore ink
            pop de ; restore x,y
            pop bc ; restore grid_value
            
            res CELL_BORN, c ; clear_bit

            jr draw_grid_loop_end ; loop       
draw_grid_cell_block:
            ; added cells are alive without being born, show as block
            push bc ; store grid_value
            push de ; store x,y
            push hl ; store ink
            call print_block_at
            pop hl ; restore ink
            pop de ; restore x,y
            pop bc ; restore grid_value

            jr draw_grid_loop_end ; loop       
draw_grid_cell_dead:
            ; clear_cell
            push bc ; store grid_value
            push de ; store x,y
            push hl ; store ink
            call clear_cell_at
            pop hl ; restore ink
            pop de ; restore x,y
            pop bc ; restore grid_value
            
            res CELL_DIES, c ; clear_bit
draw_grid_loop_end:

            push de ; store x,y
            call set_grid_value
            pop de ; restore x,y
            
            call update_active_cells
            xor a ; TODO - it's still a bit of mystery to me why I need to do this

            pop de ; restore ink
            pop hl ; restore pointer
            pop bc ; restore counter
            djnz draw_grid_loop
            ret

;----------
; update_active_cells surrounding given x,y
; inputs: d = y, e = x
; alters: all registers
;----------
update_active_cells:
            dec d ; d = y - 1
            dec e ; e = x - 1
            call update_active_cell ; x - 1, y - 1
            inc d ; d = y
            call update_active_cell ; x - 1, y
            inc d ; d = y + 1            
            call update_active_cell ; x - 1, y + 1
            inc e ; e = x            
            call update_active_cell ; x, y + 1
            dec d
            dec d ; d = y - 1
            call update_active_cell ; x, y - 1
            inc e ; e = x + 1
            call update_active_cell ; x + 1, y - 1
            inc d ; d = y            
            call update_active_cell ; x + 1, y
            inc d ; d = y + 1            
            call update_active_cell ; x + 1, y + 1
            ret

;----------
; update_active_cell
; inputs: d = y, e = x
; alters: all registers
;----------
update_active_cell:
            ; active cell limit check
            ld hl, active_cell_count
            ld a, (hl) ; a = active_cell_count
            cp MAX_ACTIVE_CELLS
            ret nc ; too many active cells

            ; bounds check
            ld a, d ; a = y
            cp GRID_HEIGHT
            ret nc ; out of bounds (also < 0 as uint)
            ld a, e ; a = x
            cp GRID_WIDTH
            ret nc ; out of bounds (also < 0 as uint)            

            ; get grid value
            push de ; store x,y
            call get_grid_value ; hl = grid_value
            pop de ; restore x,y
            ld b, h
            ld c, l ; bc = grid_value

            ; check not already active
            bit CELL_ACTIVE, c ; is cell active?
            ret nz ; yes, return            

            ; update
            push de ; store x, y
            push bc ; store grid value

            push de ; store x,y
            ld bc, active_cells
            ld hl, active_cell_count
            ld e, (hl)
            inc (hl) ; active_cell_count++
            ld l, e
            ld h, $00
            add hl, hl
            add hl, bc ; hl = pointer to arrary
            pop de ; retrieve x,y

            ld (hl), e
            inc hl
            ld (hl), d ; active_cells[active_cell_count] = y+x                

            pop bc ; restore grid value
            pop de ; restore grid x, y            
            set CELL_ACTIVE, c ; set grid_value to active

            push de ; store x,y
            call set_grid_value ; grid value updated
            pop de ; restore x,y
            ret

;----------
; iterate_grid
; outputs: hl = updated_cell_count
; alters: all registers
;----------
iterate_grid:
            ld hl, updated_cell_count
            ld (hl), a ; reset updated_cell_count
            ld hl, active_cell_count
            ld a, (hl) ; a = active_cell_count
            cp $01
            jr c, iterate_grid_end ; no active cells, end
            ld b, a ; counter = active_cell_count
            ld hl, active_cells ; hl = pointer to active_cells
iterate_grid_loop:
            ld e, (hl)
            inc hl
            ld d, (hl)
            inc hl ; de = cell_location
            push hl ; store pointer
            push bc ; store counter            
            call update_cell_state
            pop bc ; restore counter
            pop hl ; restore pointer            
            djnz iterate_grid_loop
iterate_grid_end:
            ld hl, updated_cell_count
            ld e, (hl)
            ld d, $00
            ex de, hl ; hl = updated_cell_count
            ret

;----------
; update_cell_state
; inputs: de = cell_location
; alters: all registers
;----------
update_cell_state:

            ld c, e
            ld b, d ; bc = cell_location
            push bc ; store cell_location

            ld d, b ; d = y
            ld e, c ; e = x

            push de ; store x,y
            call get_neighbour_count ; hl = neighbour count
            ld b, l ; b = neighbour count
            pop de ; retrieve x,y

            push bc ; store neighbour count
            push de ; store x,y
            call was_cell_alive ; hl = was_alive            
            pop de ; retrieve x,y
            pop bc ; retrieve neighbour count
            ld c, l ; c = was alive

            call resolve_grid_value ; hl = resolved grid value

            push hl ; store grid value
            ld b, h
            ld c, l ; bc = grid value
            call set_grid_value ; set grid value
            pop hl ; restore grid value

            pop de ; de = cell_location

            ld a, (updated_cell_count)
            cp MAX_ACTIVE_CELLS
            ret z ; reached max, do not add
            bit CELL_BORN, l ; is cell born?
            jr nz, update_cell_state_add_location ; yes, add location
            bit CELL_DIES, l ; has cell died?
            ret z ; no, continue loop
update_cell_state_add_location:
            ld bc, updated_cells
            ld hl, updated_cell_count
            push de
            ld e, (hl)
            inc (hl) ; updated_cell_count++
            ld l, e
            ld h, $00
            add hl, hl
            add hl, bc ; hl = pointer to updated_cells[updated_cell_count]
            pop de
            ld (hl), e ; lower byte
            inc hl
            ld (hl), d ; higher byte
            ret

;----------
; get_neighbour_count
; inputs: d = y, e = x
; outputs: hl = neighbour count
; alters: af, bc, hl
;----------
get_neighbour_count:
            ld b, $00 ; b = counter
            dec d ; d = y - 1
            dec e ; e = x - 1
            call get_neighbour_count_counter ; x - 1, y - 1
            inc d ; d = y
            call get_neighbour_count_counter ; x - 1, y
            inc d ; d = y + 1            
            call get_neighbour_count_counter ; x - 1, y + 1
            inc e ; e = x            
            call get_neighbour_count_counter ; x, y + 1
            dec d
            dec d ; d = y - 1
            call get_neighbour_count_counter ; x, y - 1
            inc e ; e = x + 1
            call get_neighbour_count_counter ; x + 1, y - 1
            inc d ; d = y            
            call get_neighbour_count_counter ; x + 1, y
            inc d ; d = y + 1            
            call get_neighbour_count_counter ; x + 1, y + 1
            ld h, $00
            ld l, b ; hl = neighbour count
            ret

;----------
; get_neighbour_count_counter
; inputs: d = y, e = x, b = current count
; outputs: b = increased if cell was alive
;----------
get_neighbour_count_counter:
            ; out of bounds check
            ld a, d ; a = y
            cp GRID_HEIGHT
            ret nc ; out of bounds
            ld a, e ; a = x
            cp GRID_WIDTH
            ret nc ; out of bounds            
            push bc ; store bc
            push de ; store de
            call was_cell_alive
            bit $00, l ; was alive?
            pop de ; retrieve de
            pop bc ; retrieve bc            
            ret z ; dead, return
            inc b ; alive, increase b
            ret

;----------
; was_cell_alive
; inputs: d = y, e = x
; output: hl = 0 dead, 1 alive
; alters: af, bc, de, hl
;----------
was_cell_alive:                       
            call get_grid_value ; hl = grid value
            
            ld a, l ; a = grid value
            ld h, $00 ; 
            ld l, $00 ; hl = 0
            bit CELL_DIES, a ; did cell die
            jr nz, was_cell_alive_yes ; yes so was alive
            bit CELL_ALIVE, a ; no so check if was alive
            jr nz, was_cell_alive_just_born ; yes so check if just born
            ret ; no so was not alive
was_cell_alive_just_born:
            bit CELL_BORN, a ; was alive, has it just been born?
            jr z, was_cell_alive_yes ; no so was alive last iteration
            ret ; yes so was not alive last iteration
was_cell_alive_yes:
            ld l, $01 ; hl = 1                                                
            ret

;----------
; resolve_grid_value
; inputs: b = neighbour count, c = was alive
; outputs: hl = resolved grid value
; alters: af, hl
;----------
resolve_grid_value:
            ld l, $00
            ld h, $00 ; hl = 0
            ld a, c ; a = was_alive
            cp $01 ; was alive?
            jr nz, resolve_grid_value_was_dead ; no, jump to was dead
            ld a, b ; a = neighbour count
            cp $02 ; is it 2?
            jr z, resolve_grid_value_alive ;  yes, jump to alive
            cp $03 ; is it 3?
            jr z, resolve_grid_value_alive ;  yes, jump to alive
            set CELL_DIES, l ; no, cell dies
            ret
resolve_grid_value_alive:
            set CELL_ALIVE, l
            ret
resolve_grid_value_was_dead:
            ld a, b ; a = neighbour count
            cp $03 ; is it 3?
            ret nz ; no
            set CELL_ALIVE, l
            set CELL_BORN, l ; yes, cell is born
            ret

;----------
; draw_chr_at
; inputs: d = y, e = x, bc = character code
; alters: a, bc, de, hl
;----------
draw_chr_at:
            ; load hl with memory address of character glyph
            ld h, $00 ; make sure h is 00
            ld l, c ; hl = character code
            add hl, hl
            add hl, hl
            add hl, hl ; h *= 8
            push bc
            ld bc, $3C00
            add hl, bc ; add start of character fonts, hl = address of glyph
            pop bc

            ld b, $08 ; 8 outer iterations
draw_chr_at_outer_loop:
            ld c, b
            ld b, $08 ; 8 inner iteractions
            ld a, (hl) ; a = current row
            inc hl ; point hl at next row
draw_chr_at_inner_loop:

            bit $00, a ; is bit set?
            jr z, draw_chr_at_skip

            push af
            push bc
            push de
            push hl ; preserve registers

            ; resolve x and y location and add cell
            ld a, d ; a = x
            sub c ; a = x - x2
            add a, $08 ; a = x - x2 + 8
            ld d, a ; x = x - x2 + 8
            ld a, e ; a = y
            add a, b ; a = y + y2
            ld e, a ; y = y + y2
            call add_cell

            pop hl
            pop de
            pop bc
            pop af ; restore registers
draw_chr_at_skip:
            rra ; rotate to next bit
            djnz draw_chr_at_inner_loop
            ld b, c
            djnz draw_chr_at_outer_loop
            ret

;----------
; add_cell
; inputs: d = y, e = x
; alters: a, bc, de, hl
;----------
add_cell:
            ; max active cells check
            ld a, (updated_cell_count) ; if (updated_cell_count < MAX_ACTIVE_CELLS)
            cp MAX_ACTIVE_CELLS
            ret nc ; max reached

            ; out of bounds check
            ld a, d ; a = y
            cp GRID_HEIGHT
            ret nc ; out of bounds
            ld a, e ; a = x
            cp GRID_WIDTH
            ret nc ; out of bounds            

            ld a, $00000001 ; CELL_ALIVE (not born)
            
            push de ; store d = y, e = x as destroyed by call
            ld b, $00
            ld c, a ; bc = grid value
            call set_grid_value ;
            pop de ; restore d = y, e = x

            ; updated_cells[updated_cell_count] = y+x
            ld bc, updated_cells
            ld hl, updated_cell_count
            push de
            ld e, (hl)
            inc (hl) ; updated_cell_count++
            ld l, e
            ld h, $00
            add hl, hl
            add hl, bc ; hl = pointer to updated_cells[updated_cell_count]
            pop de
            ld (hl), e ; lower byte
            inc hl
            ld (hl), d ; higher byte
            ret

include "grid.asm"
include "screen.asm"