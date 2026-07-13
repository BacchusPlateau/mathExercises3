        icl 'equates.asm'
        icl 'routines.asm'
 
        org $2000
 
        .proc main
 
        mva #1 csrhinh                  ; turn cursor off
        mva #1 rowcrs                   ; start printing at row 1
        mva #2 colcrs                   ; start printing at col 1

        ;jsr printBigDecimal

        ;jsr printArray
        ;jmp stop

        ldx #0                          ; x=0
        mva #0 temp_lo                  ; temp_lo=0
        mva #0 temp_hi                  ; temp_hi=0

probOne:
        lda evens,x                     ; a=evens[x]
        clc                             ; clear carry
        adc temp_lo                     ; a+=temp_lo
        sta temp_lo                     ; temp_lo=a
        inx                             ; x++
        cpx #.len evens
        bne probOne
        ; we've now got how many elements are in the array in x
        ; the sum of the array is in temp_lo
        txa                             ; a=x
        ldx #0                          ; x=0 (we're using it now for # of times we can subtract)
        sta p16_val_lo                  ; p16_val_lo=x (the length of the array evens)

        ;jsr printDecimal
        ;jmp stop

        ; iteratively subtract the array count from the sum until we go negative
probOneDivide:
        lda temp_lo                     ; a=temp_lo (the sum of the array)
        sec                             ; set carry
        sbc p16_val_lo                  ; a-=p16_val_lo (subtract the length of the array)
        sta temp_lo                     ; a=p16_val_lo (store reduced sum in a)
        bmi probOneNegative             ; branch if we've gone negative
        inx                             ; x++
        jmp probOneDivide
probOneNegative:
        txa                             ; a=x
        jsr printDecimal

        
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