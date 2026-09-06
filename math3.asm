        icl 'equates.asm'
        icl 'routines.asm'
 
        org $2000
 
        .proc main
 
        mva #1 csrhinh                  ; turn cursor off
        mva #1 rowcrs                   ; start printing at row 1
        mva #2 colcrs                   ; start printing at col 1


; 1. Find the index of the maximum
; Like your find-max exercise, but instead of storing the value of the largest element, 
; store the index (position) where you found it. You'll need two zero-page variables simultaneously — 
; one tracking the best value seen so far, one tracking which X position it was at. Small conceptual 
; step up: tracking two things in parallel.


 ;       ldx #0                           ; x=0
 ;       mva #0 temp_lo                  ; temp_lo=0 (max value)
 ;       mva #0 temp_hi                  ; temp_hi=0 (index of max value)

;findMax:
;        lda evens,x                     ; a=evens[x] 
;        cmp temp_lo                     ; a==temp_lo ?
;        bcc nextFindMax                 ; a<temp_lo

;        sta temp_lo                     ; temp_lo=a (update the max value)
;        txa                             ; a=x
;        sta temp_hi                     ; temp_hi=a (update the index into the evens array)

;nextFindMax:
;        inx                             ; x++
;        cpx #.len evens                 ; x==len(evens) ?
;        bne findMax                     ; x!=len(evens)

 ;       lda temp_lo                     ; a=temp_lo
 ;       jsr printDecimal                ; print max

 ;       lda #new_line                   ; a=$9B (ATASCII newline character)
 ;       jsr putchar                     ; print a

 ;       lda temp_hi                     ; a=temp_hi
 ;       jsr printDecimal                ; print index

; 2. Copy only even values to a new buffer
; Loop over mixed, test each value for evenness using AND #1 (if bit 0 is 0, the number is even), 
; and copy only the even values into merged.

; mixed is defined as:
;        .byte 15, 3, 2, 1, 3, 11, 13, 2
; merged is an empty byte array

;        ldx #0                  ; x=0
;        ldy #0                  ; y=0
;fromTheTop:
;        lda mixed,x             ; a=mixed[x]
;        and #1                  ; a=a & 1
;        beq copyValue           ; if the zero flag is set, branch to copyValue
;        jmp nextValue           ; skip the copy and get ready for the next value to check
;copyValue:
;        lda mixed,x             ; a=mixed[x]
;        sta merged,y            ; merged[y]=a
;        iny                     ; y++
;nextValue:
;        inx                     ; x++
;        cpx #.len mixed         ; x==len(mixed) ?
;        bne fromTheTop          ; if x != len(mixed) then branch back to fromTheTop
;        jsr printArray          ; print the mixed array


; 3. Multiply two numbers using repeated addition
; Given two small values (say 6 and 7), compute their product by adding one value to itself 
; repeatedly — a loop that counts down from the multiplier to zero, accumulating the result. 
; Keep both values under 15 so the product stays under 99 and printDecimal works. Introduces 
; a loop where the loop count itself is a variable, not a constant.

;        mva #6 temp_lo          ; first number - we will add temp_lo to a x times.
;        ldx #7                  ; x will count down to zero
;        lda #0                  ; a=0 (a will hold our running sum)
;loopIt:
;        clc                     ; clear carry
;        adc temp_lo             ; a+=temp_lo
;        dex                     ; x--
;        beq doneAdding          ; dex sets the zero flag if we are at zero, so check if we're done
;        jmp loopIt              ; jump to loopIt
;doneAdding:
;        jsr printDecimal        ; print a

; 4. Running sum with early exit
; Sum the evens array but break out of the loop immediately if the running total exceeds a 
; threshold (say 20). Two different exit paths: normal end-of-array, or threshold hit. After 
; the loop, print how many elements were actually summed. Good practice for loops with 
; multiple exit conditions.

;        ldx #0                  ; x=0
;        mva #0 temp_lo          ; temp_lo=0 (our running total)
;addNext:
;        lda evens, x            ; a=evens[x]
;        clc                     ; clear carry
;        adc temp_lo             ; a+=temp_lo
;        cmp #20                 ; a==20 ?
;        sta temp_lo             ; temp_lo=a
;        bcs doneWithAdding      ; branch on carry set, so a >= 20
;        inx                     ; x++
;        cpx #.len evens         ; x==len(evens) ?
;        beq doneWithAdding      ; branch if x==len(evens)
;        jmp addNext             ; loop back up to addNext
;doneWithAdding:
;        inx                     ; x++ (we have to account for zero indexing)
;        txa                     ; a=x
;        pha                     ; push(a)
;        lda temp_lo             ; a=temp_lo
;        jsr printDecimal        ; print the total
;        lda #new_line           ; a=$9B (ATASCII newline character)
;        jsr putchar             ; print the newline character
;        pla                     ; a=pop()
;        jsr printDecimal        ; print how many items we added

; 5. One pass of bubble sort
; Compare adjacent pairs in mixed — element[0] vs element[1], element[1] vs element[2], 
; etc. — and swap them if they're out of order. A swap requires a temporary variable 
; (load first, store second into first's spot, store temp into second's spot). After one 
; pass the largest value will have bubbled to the end. Print array with printArray.
; This is the most complex of the five — nested state, in-place modification, and a 3-step swap.

        ldx #0                  ; x=0
nextPair:
        lda mixed, x            ; a=mixed[x]
        sta temp_lo             ; temp_lo=a
        inx                     ; x++
        cpx #.len mixed         ; x==len(mixed) ?
        beq doneSwapping        ; we're at the end of the array, get out
        lda mixed, x            ; grab the next value
        cmp temp_lo             ; a == temp_lo ? (mixed[x+1] == mixed[x] ?)
        bcc swapPair            ; if carry flag is clear, then a < temp_lo, 
                                ; which means mixed[x+1] < mixed[x] ... we need to swap
        jmp nextPair            ; if we fell through, we don't need to swap and we've already moved the index 
swapPair:
        ; temp_lo needs to be where mixed[x] is 
        dex                     ; x--
        sta mixed, x            ; mixed[x]=a
        inx                     ; x++
        lda temp_lo             ; a=temp_lo
        sta mixed, x            ; mixed[x]=a  
        jmp nextPair            ; compare next pair
doneSwapping:
        jsr printArray          ; print the entire mixed array




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

;        ldx #0                          ; x=0
;        mva #16 temp_hi                  ; temp_hi=8 (target value)
;        mva #n_char temp_lo              ; temp_lo = n_char (default to N)

;probThree:
;        lda evens,x                     ; a=evens[x] 
;        cmp temp_hi
;        beq probThreeFound
;        jmp probThreeNotFound
;probThreeFound:
;        mva #y_char temp_lo
;probThreeNotFound:
;        inx                             ; x++
;        cpx #.len evens                 ; x == len(evens)?
;        bne probThree                   ; branch if they are not equal

;        lda temp_lo
;        jsr putchar

;================================================================================
; **4. Interleave two arrays into a third**
; Given two same-length source arrays A and B, fill a destination buffer by alternating: 
; `A[0], B[0], A[1], B[1], A[2], B[2]...` Verify with `db`. This extends the dual-index 
; pattern from the reverse-copy exercise — now you're writing to a *third* index at double the pace of the two readers.

; x will index evens and odds
; y will index merged


 ;       ldx #0                          ; x=0
 ;       ldy #0                          ; y=0

;probFour:
;        lda odds,x                     ; a=evens[x] 
;        sta merged,y
;        iny
;        lda evens,x
;        sta merged,y
;        iny
;        inx
;        cpx #.len evens
;        bne probFour

        ;jsr printArray



;================================================================================
; **5. Count how many values are in a range**
; Given a byte table, count how many values fall between a low bound and a high bound 
; (inclusive). Uses two `cmp`/`bcc`/`bcs` checks per element — a bit like a gate with 
; two conditions that both have to pass. Print the count.


 ;       mva #5 temp_lo                  ; our lower bound will be 5, store in a zero page variable
 ;       mva #12 temp_hi                 ; our upper bound will be 12, store in a zero page variable
 ;       ldx #0                          ; index into our byte array evens { 2, 4, 6, 8, 10, 12, 14, 16 }
 ;       ldy #0                          ; counter how many we found in range

;robFive:
;        lda evens,x                     ; a=evens[x] 
;        cmp temp_lo                     ; a == temp_lo ?
;        bcc probFiveNext                ; a < temp_lo is below range, skip        
;        ; if we got here, a >= temp_lo, we must check temp_hi now
;        cmp temp_hi                     ; a == temp_hi ?
;        bcc probFiveGotOne              ; if a < temp_hi, we are in range
        ; if we got here a >= templo and now have to check if a == temp_hi
;        bne probFiveNext                ; a != temp_hi

;probFiveGotOne:
;        iny                             ; y++

;probFiveNext:
;        inx                             ; x++
;        cpx #.len evens                 ; x==len(evens) ?
;        bne probFive                    ; x != len(evens)

;        tya                             ; a=y
;        ;jsr printDecimal                ; print the output (should be 4)

;****************
; find min value, where a byte array "mixed" is declared as:
;        .local mixed
;        .byte 15, 3, 2, 1, 3, 11, 13, 2
;        .endl

;        ldx #0                           ; x=0
;        mva #254  temp_lo                ; temp_lo=254 (holds the least)
;probUno:
;        lda mixed,x                      ; a=mixed[x] 
;        cmp temp_lo                      ; a == temp_lo 
;        bcc probUnoFound                 ; a < temp_lo 
 ;       jmp probUnoNext                  ; skip, a is NOT greater than temp_lo
;probUnoFound:
 ;       sta temp_lo                      ; temp_lo = a
;robUnoNext:
;        inx                              ; x++
;        cpx #.len mixed                   ; x == len(mixed) ?
;        bne probUno                      ; x != len(mixed)

 ;       lda temp_lo                      ; a = temp_lo
 ;       jsr printDecimal                 ; print a


;=====================================================================
; Count the set bits in a byte
; Given a single byte value, count and display how many of its bits are 1.
; You must not loop more than 8 times

;        ldy #0                           ; y=0 (our count of bits set)
;        ldx #0                           ; x=0 (we still start on the right most bit)
;        lda #%01101111                  ; a=binary "#" denotes a literal value, not an address
                                        ; "%" denotes a binary value
;checkBit:
;        asl                             ; left shift
;        bcc skipThisBit                 ; if carry flag is clear, this bit was not 1
;        iny                             ; y++, if we're here, carry flat was set
;skipThisBit:
;        inx                             ; x++
;        cpx #8                          ; have we shifted 8 times?
;        bne checkBit                    ; check the next bit if x !=8

;        tya                             ; a=y
;        jsr printDecimal                ; print a





; Null terminated array
; Process a byte array that ends with a $00 terminator instead of using 
; .len. Loop until you read a $00, counting the non-zero values as you go. 
; Use this array: 
; .local evens
; .byte 2, 4, 6, 8, 10, 12, 14, 16, 0 

;        ldx #0                          ; x=0
;        mva #0 temp_lo                  ; we will put the sum in temp_lo

;keepAdding:
;        lda evens, x                    ; a=evens[x]
;        cmp #0                          ; a==0 ?
;        beq stopAdding                  ; if a==0, branch
;        clc                             ; clear the carry flag
;        adc temp_lo                     ; a+=temp_lo
;        sta temp_lo                     ; temp_lo=a
;        inx                             ; x++
;        jmp keepAdding                  ; branch 
;stopAdding:
;        lda temp_lo                     ; a=temp_lo
;        jsr printDecimal                ; call print routine to print out the A register




;===============================================================
; Max minus min
; Two passes over the same array: first find the maximum, then find the minimum, 
; then subtract min from max and print the result. Combines exercises #1 and 
; the earlier find-max, plus an explicit subtraction at the end with sec / sbc. 
; Use the array mixed:
; .local mixed
; .byte 15, 3, 2, 1, 3, 11, 13, 2

;        ldx #0                          ; x=0
;        mva #$FF temp_lo                ; we will put the min in temp_lo, default it to 255
;keepLooking4Min:
;        lda mixed, x                    ; a=mixed[x]
;        cmp temp_lo                     ; a==temp_lo ?
;        bcc isLower                     ; if a<temp_lo, branch
;        jmp nextMinCheck                ; check next value
;isLower:
;        sta temp_lo                     ; temp_lo=a
;nextMinCheck:
;        inx                             ; x++
;        cpx #.len mixed                 ; x==len(mixed) ?
;        bne keepLooking4Min             ; if x!=len(mixed), branch
;
;        ldx #0                          ; reset our counter
;        mva #0 temp_hi                  ; we will put the max in temp_hi, default it to zero
;keepLooking4Max:
;        lda mixed, X                    ; a=mixed[x]
;        cmp temp_hi                     ; a==temp_hi ?
;        bcs isHigher                    ; if a>temp_hi, branch
;        jmp nextMaxCheck                ; check next value
;isHigher:
;        sta temp_hi                     ; temp_hi=a
;nextMaxCheck:
;        inx                             ; x++
;        cpx #.len mixed                 ; x==len(mixed) ?
;        bne keepLooking4Max             ; if x!=len(mixed), branch

; now we have min in temp_lo and max in temp_hi
;        lda temp_hi                     ; a=temp_hi
;        sec                             ; set the carry flag
;        sbc temp_lo                     ; a-=temp_lo
;        jsr printDecimal                ; call print routine to print out the A register, should be 14


;        lda temp_lo
;        jsr printDecimal




stop:
        jsr fightAttract
        jmp stop

        .endp
 
 
 

; Data section
;===================================================================

        .local evens
        .byte 2, 4, 6, 8, 10, 12, 14, 16, 0
        .endl

        .local odds
        .byte 1, 3, 5, 7, 9, 11, 13, 15
        .endl

        .local mixed
        .byte 15, 3, 2, 1, 3, 11, 13, 2
        .endl

        .local merged
        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        .endl

        run main