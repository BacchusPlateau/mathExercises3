        icl 'equates.asm'
        icl 'routines.asm'
 
        org $2000
 
        .proc main
 
        mva #1 csrhinh                  ; turn cursor off
        mva #1 rowcrs                   ; start printing at row 1
        mva #2 colcrs                   ; start printing at col 1

; problem one
; Running average (rounded down)
; Given a byte table of values, compute their average — sum all the values, 
; then repeatedly subtract the count until you can't anymore, counting how many 
; times you subtracted. That gives you quotient = average. Print it. 
; (This is the same repeated-subtraction trick as `printDecimal`, 
; just with a variable divisor instead of 10.)

 ;       ldx #0                          ; x=0
 ;       mva #0 temp_lo                  ; temp_lo=0

;probOne:
;        lda evens,x                     ; a=evens[x]
;        clc                             ; clear carry
;        adc temp_lo                     ; a+=temp_lo
;        sta temp_lo                     ; temp_lo=a
;        inx                             ; x++
;        cpx #.len evens
;        bne probOne
        ; we've now got how many elements are in the array in x
        ; the sum of the array is in temp_lo
;        txa                             ; a=x
;        ldx #0                          ; x=0 (we're using it now for # of times we can subtract)
;        sta p16_val_lo                  ; p16_val_lo=x (the length of the array evens)

;        ; iteratively subtract the array count from the sum until we go negative
;probOneDivide:
;        lda temp_lo                     ; a=temp_lo (the sum of the array)
;        sec                             ; set carry
;        sbc p16_val_lo                  ; a-=p16_val_lo (subtract the length of the array)
;        sta temp_lo                     ; a=p16_val_lo (store reduced sum in a)
;        bmi probOneNegative             ; branch if we've gone negative
;        inx                             ; x++
;        jmp probOneDivide               ; keep subtracting
;probOneNegative:
 ;       txa                             ; a=x
 ;       jsr printDecimal                ; print the integer division


;========================================================================================
; **2. Negate all values in an array**
; Given a table of small positive numbers, replace every value in-place with its two's 
; complement negation — i.e. `256 - value`. The 6502 idiom for this is `eor #$FF` followed 
; by `clc` / `adc #1` (flip all bits, then add 1). Verify with `db` in Altirra before and after.

;        lda #new_line
;        jsr putchar

;       lda #new_line
;       jsr putchar

;        jsr printArray

;        ldx #0                          ; x=0

;probTwo:
;        lda evens,x                     ; a=evens[x] 
;        eor #%11111111                   ; a=a xor (1111 1111)
;        clc                             ; clear carry
;        adc #1                          ; a+=1
;        sta evens,X                     ; evens[x] = a
;        inx                             ; x++
;        cpx #.len evens                 ; x == len(evens)?
;        bne probTwo                     ; branch if they are not equal

;        lda #new_line
;        jsr putchar

;        jsr printArray

; **3. Array contains a value (yes/no)**
; Loop over a byte table searching for a specific target value. If found, print `Y`; 
; if you reach the end without finding it, print `N`. The twist: you need to print 
; the result *after* the loop regardless of which exit path you took — think about 
; how to carry a "found" flag out of the loop.
; 
; We will put the value to find in temp_hi
; We will put the output character (Y/N) in temp_lo

        ldx #0                          ; x=0
        mva #16 temp_hi                  ; temp_hi=8 (target value)
        mva #n_char temp_lo              ; temp_lo = n_char (default to N)

probThree:
        lda evens,x                     ; a=evens[x] 
        cmp temp_hi
        beq probThreeFound
        jmp probThreeNotFound
probThreeFound:
        mva #y_char temp_lo
probThreeNotFound:
        inx                             ; x++
        cpx #.len evens                 ; x == len(evens)?
        bne probThree                   ; branch if they are not equal

        lda temp_lo
        jsr putchar






stop:
        jsr fightAttract
        jmp stop

        .endp
 
 
 

; Data section
;===================================================================

        .local evens
        .byte 2, 4, 6, 8, 10, 12, 14, 16
        .endl

     
        run main