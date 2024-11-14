.include "io_macros.s"      # Include the macros library for input/output operations

.data
    prompt_exp:        .asciz "expected: "            # String to display the expected value label
    prompt_result:     .asciz "result:   "            # String to display the result label
    prompt_test:       .asciz "\n_____TEST_____\n\n"  # Separator string for the test output
    expected1:         .float 3.141592                # Expected value of pi for comparison (accurate to 6 decimal places)
    prompt_test1:      .asciz "Test ¹1\n"            # Label for the first test case

.text
.globl test

# Main test subroutine
test:
    print_string prompt_test   # Print the test separator header

    # Test 1: Compare computed pi to the expected value
    jal pi_via_nilakantha      # Call the function to compute pi using the Nilakantha series
    fmv.s ft0, fa0             # Move the computed value of pi (fa0) into the temporary register ft0
    
    la t0, expected1           # Load the address of the expected value (3.141592) into register t0
    flw ft1, 0(t0)             # Load the expected value from memory into floating-point register ft1
    print_string prompt_test1  # Print the label for test 1
    print_string prompt_exp    # Print the label for "expected:"
    print_float ft1            # Print the expected value of pi (3.141592) from register ft1
    print_string prompt_result # Print the label for "result:"
    print_float ft0            # Print the computed value of pi from register ft0 (the result of pi_via_nilakantha)
   
    # End of the test program
    li a7, 10                   # System call to exit the program (exit code 10)
    ecall                       # Call the operating system to terminate the program
