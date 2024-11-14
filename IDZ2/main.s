.include "io_macros.s"      # Include the macros library for I/O operations

.data
    prompt_result: .asciz "\nResult of computing pi: "  # Message to display the result of pi computation

.text
.global main

# Main program entry point
main:
    
    # Input and validate data
    input_and_validate t1          # Input and validation result (e.g., user input)
    
    # If t1 equals 0 (input error), go to testing
    beqz t1, testing               # If t1 == 0, jump to testing label
    
    # If t1 is non-zero, proceed with computation
    bnez t1, computing             # If t1 != 0, jump to computing label for pi calculation

# Computing pi using Nilakantha series
computing:
    jal pi_via_nilakantha         # Jump to the subroutine for computing pi via Nilakantha series
    fmv.s ft0, fa0                # Move the result from fa0 register to ft0 (floating-point register)
    
    # Output the result
    print_string prompt_result     # Print the string with the result prompt
    print_float ft0                # Print the computed value of pi (from ft0 register)
    
    # Exit the program
    j exit_program                 # Jump to the exit program label

# Testing section
testing:
    jal test                       # Jump to the test subroutine (e.g., tests for correctness)
    j exit_program                 # After testing, exit the program

# Program exit
exit_program:
    li a7, 10                      # System call code for exiting the program (code 10)
    ecall                          # Make the system call to exit the program

