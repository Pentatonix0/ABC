.data
    prompt:     .asciz "Enter array element: "
    promptOLD:   .asciz "Old array: "
    promptO:    .asciz "New array: "
    space:      .asciz " "
    new_line:   .asciz "\n"

.macro read_int %reg
    li a7, 5                # System call for reading an integer
    ecall
    mv %reg, a0             # Save the result in the register
.end_macro

.macro print_string %str
    li a7, 4                # System call for printing a string
    la a0, %str             # Load the address of the string
    ecall
.end_macro

.macro read_array %n, %array
    mv t5, %array           # Index for the array
    li t1, 0
input_loop:
    bge t1, %n, input_done  # If index >= N, exit the loop
    print_string prompt
    read_int t2             # Read the element
    sw t2, 0(t5)            # Store in the array
    addi t5, t5, 4
    addi t1, t1, 1          # Move to the next element
    j input_loop
input_done:
    li t1, -4
    mul t1, t1, %n
    add t5, t5, t1
.end_macro

.macro print_array %n, %array
    mv t5, %array           # Address of the start
    li t1, 0                # Index of the element

output_loop:
    lw a0, 0(t5)            # Load element from the array
    li a7, 1                # System call for printing an integer
    ecall
    print_string space       # Print a space
    addi t5, t5, 4          # Move to the next element
    addi t1, t1, 1
    blt t1, %n, output_loop # Condition to continue the loop
    li t1, -4
    mul t1, t1, %n
    add t5, t5, t1
    print_string new_line
    print_string new_line
.end_macro

.macro print_new_array
    print_string promptO
.end_macro
