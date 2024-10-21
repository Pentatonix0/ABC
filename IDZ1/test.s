.include "io_macros.s"      # Include the macros library

.data
    test:       .asciz "_____TEST_____\n\n"
    test1:      .word 3, -1, 4, 5, -2, 9  # Test array A1
    expected1:  .asciz "Expected B: 9 -2 5 4 -1 \n"
    
    test2:      .word -3, -1, -2, 1, 5, 11, 4  # Test array A2
    expected2:  .asciz "Expected B: 4 11 5 -2 -1 -3 \n"
    
    test3:      .word 1, 2, 3, 4, 5     # Test array A3
    expected3:  .asciz "Expected B: 5 4 3 2 \n"
    
    .align 2
    testB1:     .space 40  
    .align 2
    testB2:     .space 40 
    .align 2
    testB3:     .space 40  

    # Parameters for tests
    testN1:     .word 6               # N for test1
    testN2:     .word 7               # N for test2
    testN3:     .word 5               # N for test3

.text
.globl main

main:
    print_string test
    # Test 1
    lw a0, testN1                # N
    li a3, 0
    la a1, test1                 # Address of array A1
    la a2, testB1                # Address of array B
    jal process_array            # Call array processing
    mv s2, a2
    mv s3, a3
    print_string expected1       # Expected result
    print_new_array
    print_array s3, s2           # Output array B
    
    
    # Test 2
    lw a0, testN2 
    li a3, 0                     # N
    la a1, test2                 # Address of array A2
    la a2, testB2                # Address of array B
    jal process_array            # Call array processing
    mv s2, a2
    mv s3, a3
    print_string expected2       # Expected result
    print_new_array
    print_array s3, s2           # Output array B

    # Test 3
    lw a0, testN3                # N
    li a3, 0   
    la a1, test3                 # Address of array A3
    la a2, testB3                # Address of array B
    jal process_array            # Call array processing
    mv s2, a2
    mv s3, a3
    print_string expected3       # Expected result
    print_new_array
    print_array s3, s2           # Output array B

    # End of program
    li a7, 10                    # System call to exit
    ecall
