.include "io_macros.s"      # Include macros for input/output operations

.data
    prompt_exp_pi:        .asciz "Expected pi value: "
    prompt_exp_acur:      .asciz "Expected accuracy (%): "
    prompt_computed_pi:   .asciz "Computed pi value:   "
    prompt_computed_acur: .asciz "Computed accuracy (%): "
    prompt_test:          .asciz "\n_____TEST_____\n"

    accuracy1:            .float 0.05
    expected1:            .float 3.1427128
    prompt_test1:         .asciz "\nTest ¹1\n"
    
    accuracy2:            .float 0.005
    expected2:            .float 3.141736
    prompt_test2:         .asciz "\nTest ¹1\n"
    
    accuracy3:            .float 0.00001
    expected3:            .float 3.1427128
    prompt_test3:         .asciz "\nTest ¹1\n"

.text
.globl test

# Main test subroutine
test:
    print_string prompt_test   # Print test separator

    #Test 1
    # Load accuracy and call pi computation
    la t0, accuracy1
    flw fa0, 0(t0)
    jal pi_via_nilakantha
    
    fmv.s ft0, fa1             # Store computed pi
    fmv.s ft1, fa2             # Store computed accuracy

    # Load expected pi and accuracy
    la t0, expected1
    flw ft2, 0(t0)
    la t0, accuracy1
    flw ft3, 0(t0)

    # Print expected and computed results
    print_string prompt_test1
    print_string prompt_exp_pi
    print_float ft2            # Expected pi value
    print_string prompt_exp_acur
    print_float ft3            # Expected accuracy
    
    print_string prompt_computed_pi
    print_float ft0            # Computed pi value
    
    print_string prompt_computed_acur
    print_float ft1            # Computed accuracy
    
    #Test 2
    # Load accuracy and call pi computation
    la t0, accuracy2
    flw fa0, 0(t0)
    jal pi_via_nilakantha
    
    fmv.s ft0, fa1             # Store computed pi
    fmv.s ft1, fa2             # Store computed accuracy

    # Load expected pi and accuracy
    la t0, expected2
    flw ft2, 0(t0)
    la t0, accuracy2
    flw ft3, 0(t0)

    # Print expected and computed results
    print_string prompt_test2
    print_string prompt_exp_pi
    print_float ft2            # Expected pi value
    print_string prompt_exp_acur
    print_float ft3            # Expected accuracy
    
    print_string prompt_computed_pi
    print_float ft0            # Computed pi value
    
    print_string prompt_computed_acur
    print_float ft1            # Computed accuracy
    
    #Test 3
    # Load accuracy and call pi computation
    la t0, accuracy3
    flw fa0, 0(t0)
    jal pi_via_nilakantha
    
    fmv.s ft0, fa1             # Store computed pi
    fmv.s ft1, fa2             # Store computed accuracy

    # Load expected pi and accuracy
    la t0, expected3
    flw ft2, 0(t0)
    la t0, accuracy3
    flw ft3, 0(t0)

    # Print expected and computed results
    print_string prompt_test3
    print_string prompt_exp_pi
    print_float ft2            # Expected pi value
    print_string prompt_exp_acur
    print_float ft3            # Expected accuracy
    
    print_string prompt_computed_pi
    print_float ft0            # Computed pi value
    
    print_string prompt_computed_acur
    print_float ft1            # Computed accuracy

    # End the program
    li a7, 10                   # Exit system call
    ecall
