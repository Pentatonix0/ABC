.include "io_macros.s"      # Include the macros library

.data
    promptE:   .asciz "\nN is out of range\n"
    promptN:   .asciz "Enter the number of elements N (1-10): "
    promptA:   .asciz "Enter the element of array A: "
    msgB:      .asciz "Elements of array B: "
    newline:    .asciz "\n"
    .align 2
    arrayA:    .space 40        # Array A (10 elements of 4 bytes)
    .align 2
    arrayB:    .space 40        # Array B (10 elements of 4 bytes)

.text
.global main

main:
    # s0 - N
    # s1 - arrayA
    # s2 - arrayB
    # s3 - length of array B
    la s1, arrayA
    la s2, arrayB

    # Input the number of elements N
    print_string promptN
    read_int s0

    # Check for valid N
    li t1, 1
    li t2, 10
    blt s0, t1, invalidN
    bgt s0, t2, invalidN

    # Input array A
    read_array(s0, s1)  # Input array A

    # Parameters for process_array function
    mv a0, s0
    mv a1, s1
    mv a2, s2
    li a3, 0

    # Create array B
    jal process_array
    mv s3, a3
    mv s2, a2
    print_new_array
    print_array(s3, s2)

exit_program:
    li a7, 10           # System call to exit the program
    ecall               # Call the operating system

invalidN:
    print_string promptE      # Output error message
    j main                   # Repeat input for N
