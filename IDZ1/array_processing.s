.text
.global process_array

process_array:
    # Input parameters: 
    # a0 - number of elements,
    # a1 - address of the start of array A,
    # a2 - address of the start of array B
    # Output data:
    # a2 - address of the start of array B
    # a3 - length of array B

    li t1, 0                # Index for array A
    li t3, 0                # Flag for first positive element found
    li t6, 4                # Required offset
    mul t6, t6, a0
    add a2, a2, t6
    
reverse_loop:
    bge t1, a0, reverse_done   # If index >= N, exit the loop

    lw t4, 0(a1)            # Load element from array A
    addi a1, a1, 4          # Address of the next element

    bgtz t4, skip_positive   # If element is positive, skip it
    j add_element

add_element:
    sw t4, 0(a2)            # Store element in array B
    addi a2, a2, -4         # Address of the next element
    addi t1, t1, 1
    addi a3, a3, 1
    j reverse_loop
    
skip_positive:
    bgtz t3, add_element
    addi t3, t3, 1
    addi t1, t1, 1
    j reverse_loop
    
reverse_done:
    addi a2, a2, 4
    ret
