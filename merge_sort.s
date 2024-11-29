AREA DataSection, DATA, READWRITE
    ALIGN 4

array   DCD 8, 29, 50, 81, 4, 23, 24, 30, 1, 7  ; Initial array
temp    SPACE 40                                ; Temporary array space
stack   SPACE 1024                              ; Allocate space for a software stack

AREA Merge, CODE, READONLY
    ENTRY

start
    LDR SP, =stack+1024        ; Initialize stack pointer
    LDR r0, =array             ; Base address of the array
    MOV r1, #10                ; Array size

    BL merge_sort              ; Call merge sort

done
    B done                     ; Infinite loop (end of program)

merge_sort
    PUSH {R4-R7, LR}           ; Save working registers and LR
    CMP r1, #1                 ; Check if size <= 1
    BLE merge_sort_end         ; If yes, return

    ; Calculate midpoint
    MOV r2, r1
    LSR r2, r2, #1             ; r2 = size / 2

    ; Recursive call for the left half
    PUSH {r0, r1}              ; Save array pointer and size
    MOV r1, r2                 ; Size = midpoint
    BL merge_sort
    POP {r0, r1}               ; Restore array pointer and size

    ; Recursive call for the right half
    PUSH {r0, r1}              ; Save array pointer and size
    ADD r0, r0, r2, LSL #2     ; Update pointer to second half
    SUB r1, r1, r2             ; Size = size - midpoint
    BL merge_sort
    POP {r0, r1}               ; Restore array pointer and size

    ; Merge sorted halves
    PUSH {r2}                  ; Save midpoint
    BL merge
    POP {r2}                   ; Restore midpoint

merge_sort_end
    POP {R4-R7, LR}            ; Restore working registers and LR
    BX LR                      ; Return to caller

merge
    PUSH {R4-R7}               ; Save working registers
    LDR r4, =temp              ; Temporary array pointer
    MOV r5, #0                 ; k = 0
    MOV r6, #0                 ; i = 0
    MOV r7, r2                 ; j = midpoint

merge_loop
    CMP r6, r2                 ; Check if i < midpoint
    BGE copy_right
    CMP r7, r1                 ; Check if j < size
    BGE copy_left

    ; Compare and copy
    LDR r8, [r0, r6, LSL #2]   ; Load left element
    LDR r9, [r0, r7, LSL #2]   ; Load right element
    CMP r8, r9
    BLE merge_copy_left

    STR r9, [r4, r5, LSL #2]   ; Copy from right
    ADD r7, r7, #1
    B merge_increment

merge_copy_left
    STR r8, [r4, r5, LSL #2]   ; Copy from left
    ADD r6, r6, #1

merge_increment
    ADD r5, r5, #1
    B merge_loop

copy_left
    CMP r6, r2
    BGE copy_done
    LDR r8, [r0, r6, LSL #2]
    STR r8, [r4, r5, LSL #2]
    ADD r6, r6, #1
    ADD r5, r5, #1
    B copy_left

copy_right
    CMP r7, r1
    BGE copy_done
    LDR r9, [r0, r7, LSL #2]
    STR r9, [r4, r5, LSL #2]
    ADD r7, r7, #1
    ADD r5, r5, #1
    B copy_right

copy_done
    ; Copy back to original array
    MOV r6, #0
copy_back
    CMP r6, r1
    BGE merge_end
    LDR r8, [r4, r6, LSL #2]
    STR r8, [r0, r6, LSL #2]
    ADD r6, r6, #1
    B copy_back

merge_end
    POP {R4-R7}                ; Restore working registers
    BX LR                      ; Return to caller
