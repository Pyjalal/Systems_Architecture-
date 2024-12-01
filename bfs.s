AREA MyData, DATA, READWRITE

; Data Section
ARRAY_TO_SORT   DCD 10, 5, 30, 78, 2, 19, 11, 23, 48, 79, 1, 14, 9, 41, 31
TEMP_STORAGE    SPACE 60                      ; Temporary space for sorting
QUEUE           SPACE 60                      ; Queue for BFS traversal
QUEUE_START     DCD 0                         ; Queue start index
QUEUE_END       DCD 0                         ; Queue end index
STACK           SPACE 1024                    ; Stack for recursion

AREA BFSQuickSort, CODE, READONLY
ENTRY

start
    LDR SP, =STACK+1024        ; Initialize stack pointer

    ; Perform BFS
    LDR R0, =ARRAY_TO_SORT     ; Load base address of tree values
    BL bfs                     ; Perform BFS traversal

    ; Perform Quick Sort
    LDR R0, =ARRAY_TO_SORT     ; Load base address of array
    MOV R1, #0                 ; Start index
    MOV R2, #14                ; End index (15 elements - 1)
    BL quick_sort              ; Perform quick sort

done
    B done                     ; End of program

; ==========================================================
; Breadth-First Search Implementation
; ==========================================================
bfs
    LDR R1, =QUEUE             ; Queue base address
    LDR R2, =QUEUE_START       ; Queue start pointer
    LDR R3, =QUEUE_END         ; Queue end pointer
    MOV R4, #0                 ; Root node index

    ; Enqueue root node
    BL enqueue

bfs_loop
    LDR R5, [R2]               ; Load queue start index
    LDR R6, [R3]               ; Load queue end index
    CMP R5, R6                 ; Check if queue is empty
    BGE bfs_done               ; If empty, BFS is complete

    BL dequeue                 ; Dequeue the current node
    MOV R7, R0                 ; Current node index

    ; Process node (print or process value at ARRAY_TO_SORT[R7])
    LDR R8, [ARRAY_TO_SORT, R7, LSL #2]
    ; (Insert custom processing logic here, e.g., print R8)

    ; Enqueue left child
    ADD R9, R7, #1             ; Calculate left child index
    CMP R9, #15
    BGE bfs_right              ; If out of bounds, skip
    MOV R0, R9                 ; Enqueue left child
    BL enqueue

bfs_right
    ADD R9, R7, #2             ; Calculate right child index
    CMP R9, #15
    BGE bfs_loop               ; If out of bounds, skip
    MOV R0, R9                 ; Enqueue right child
    BL enqueue
    B bfs_loop

bfs_done
    BX LR                      ; Return from BFS

enqueue
    LDR R4, [R3]               ; Load queue end index
    STR R0, [QUEUE, R4, LSL #2]; Store node index in queue
    ADD R4, R4, #1             ; Increment queue end
    STR R4, [R3]               ; Update queue end pointer
    BX LR

dequeue
    LDR R4, [R2]               ; Load queue start index
    LDR R0, [QUEUE, R4, LSL #2]; Load node index from queue
    ADD R4, R4, #1             ; Increment queue start
    STR R4, [R2]               ; Update queue start pointer
    BX LR

; ==========================================================
; Quick Sort Implementation
; ==========================================================
quick_sort
    PUSH {LR}                  ; Save return address
    CMP R1, R2                 ; Check if start < end
    BGE quick_sort_end         ; If not, return

    ; Partition array
    PUSH {R0, R1, R2}          ; Save array and indices
    BL partition               ; Call partition
    POP {R0, R1, R2}           ; Restore array and indices
    MOV R3, R0                 ; Pivot index in R3

    ; Quick sort left partition
    PUSH {R1, R3}              ; Save indices
    SUB R3, R3, #1             ; End = pivot - 1
    BL quick_sort              ; Sort left partition
    POP {R1, R3}               ; Restore indices

    ; Quick sort right partition
    PUSH {R3, R2}              ; Save indices
    ADD R3, R3, #1             ; Start = pivot + 1
    BL quick_sort              ; Sort right partition
    POP {R3, R2}               ; Restore indices

quick_sort_end
    POP {LR}                   ; Restore return address
    BX LR                      ; Return

partition
    PUSH {R4-R6, LR}           ; Save working registers
    MOV R4, R1                 ; i = start index
    SUB R5, R1, #1             ; j = start - 1
    LDR R6, [R0, R2, LSL #2]   ; Pivot = array[end]

partition_loop
    CMP R4, R2                 ; i < end
    BGE partition_done
    LDR R7, [R0, R4, LSL #2]   ; Load array[i]
    CMP R7, R6                 ; Compare array[i] with pivot
    BLE partition_swap         ; If array[i] <= pivot, swap
    ADD R4, R4, #1             ; Increment i
    B partition_loop

partition_swap
    ADD R5, R5, #1             ; j++
    LDR R8, [R0, R5, LSL #2]   ; Load array[j]
    STR R7, [R0, R5, LSL #2]   ; Swap array[i] and array[j]
    STR R8, [R0, R4, LSL #2]
    ADD R4, R4, #1             ; Increment i
    B partition_loop

partition_done
    ADD R5, R5, #1             ; j++
    LDR R7, [R0, R5, LSL #2]
    LDR R8, [R0, R2, LSL #2]   ; Load pivot
    STR R8, [R0, R5, LSL #2]   ; Swap pivot with array[j+1]
    STR R7, [R0, R2, LSL #2]
    MOV R0, R5                 ; Return pivot index in R0
    POP {R4-R6, LR}            ; Restore working registers
    BX LR                      ; Return
END
