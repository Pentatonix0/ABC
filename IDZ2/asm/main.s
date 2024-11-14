.include "io_macros.s"          # Include the macros library for I/O operations

.data
    prompt_result: .asciz "\nResult of computing pi: "         # Message to display the result of pi computation
    prompt_result_accuracy: .asciz "Accuracy (%): "            # Message to display the accuracy of pi computation

.text
.global main

# Main program entry point
main:
    # Input and validate data
    input_and_validate t1         # Input and validate the result (e.g., user input)

    # If t1 equals 0 (input error), jump to the testing section
    beqz t1, testing              # If t1 == 0, jump to the testing section

    # If t1 is non-zero, proceed with the computation
    bnez t1, computing            # If t1 != 0, jump to the computing section for pi calculation

# Pi computation using Nilakantha series
computing:
    input_and_validate_float fa0  # Input and validate the floating-point number (e.g., accuracy or iteration limit)
    jal pi_via_nilakantha         # Jump to the subroutine for computing pi using the Nilakantha series
    fmv.s ft0, fa1                # Move the computed pi result from register fa1 to ft0 (floating-point register)
    fmv.s ft1, fa2                # Move the accuracy result from register fa2 to ft1

    # Output the result
    print_string prompt_result     # Print the string with the result prompt
    print_float ft0                # Print the computed value of pi (from ft0 register)
    print_string prompt_result_accuracy  # Print the string with the accuracy prompt
    print_float ft1                # Print the computed accuracy (from ft1 register)

    # Exit the program
    j exit_program                 # Jump to the exit program label

# Testing section
testing:
    jal test                       # Jump to the test subroutine (e.g., tests for correctness)
    j exit_program                 # After testing, jump to the exit program label

# Program exit
exit_program:
    li a7, 10                      # System call code for exiting the program (code 10)
    ecall                          # Make the system call to exit the program
