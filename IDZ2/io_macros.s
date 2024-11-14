.data
    prompt_start:             .asciz "To calculate the value of pi using the Nilakantha series, enter [1]\nTo run the tests, enter [0]\n"  # Prompt for the user to choose between calculating pi or running tests
    prompt_invalid_input:     .asciz "Invalid input! Please try again\n"  # Message displayed if the user enters invalid input
    prompt_input:             .asciz "Your decision: "  # Prompt for user input
    prompt_input_accuracy:    .asciz "\nInput Enter the percentage accuracy (0.000001 <= a <= 0.05): "  # Prompt for user input on accuracy
    space:                    .asciz " "  # Space character (not used in the provided code)
    new_line:                 .asciz "\n"  # Newline character for formatting output
    max:                      .float 0.051  # Maximum allowed accuracy value
    min:                      .float 0.000001  # Minimum allowed accuracy value

# Macro for printing a string to the screen
.macro print_string %str
    li a7, 4                # System call for printing a string
    la a0, %str             # Load the address of the string into a0
    ecall                   # Make the system call to print the string
.end_macro

# Macro for inputting a floating-point number
.macro input_float %result
    li      a7, 6           # System call for reading a floating-point number
    ecall                   # Make the system call to read the input
    fmv.s   %result, fa0    # Move the floating-point result into the provided variable
.end_macro

# Macro for printing a floating-point value
.macro print_float %value
    fmv.s   fa0, %value     # Move the floating-point value into fa0 register for printing
    li      a7, 2           # System call for printing a floating-point number
    ecall                   # Make the system call to print the floating-point value
    print_string new_line   # Print a newline after the number
.end_macro

# Macro for input and validation of user decision (0 or 1)
.macro input_and_validate %value
    print_string prompt_start  # Print the prompt to the user (choose calculation or testing)
loop:
    print_string prompt_input  # Ask for user input (their decision)
    li a7, 5                   # System call for reading an integer (user's choice)
    ecall                      # Make the system call to read the input
    
    mv t1, a0                  # Move the input value into register t1
    li t2, 2                   # Load the value 2 into register t2 (to check the valid range)
    
    bltz t1, invalid_input     # If t1 < 0, jump to invalid_input (input is negative)
    bge t1, t2, invalid_input  # If t1 >= 2, jump to invalid_input (input is not 0 or 1)
    j done_input               # If input is valid (0 or 1), jump to done_input
    
invalid_input:
    print_string prompt_invalid_input  # Print the invalid input message
    j loop                             # Jump back to the input loop for retry
 
done_input:
    mv %value, a0              # Move the valid input value (0 or 1) to the provided variable
.end_macro


# Macro for input and validation of user decision on floating-point accuracy (0.000001 <= a <= 0.05)
.macro input_and_validate_float %value
    print_string prompt_start  # Print the prompt to the user (choose accuracy value)
    la t1, min                 # Load the address of the minimum accuracy value
    la t2, max                 # Load the address of the maximum accuracy value
    flw ft0, 0(t1)             # Load minimum accuracy value into ft0
    flw ft1, 0(t2)             # Load maximum accuracy value into ft1
loop:
    print_string prompt_input_accuracy  # Ask for user input on accuracy
    
    input_float ft2            # Get the floating-point input value (accuracy)
    
    flt.s t1, ft2, ft0         # Compare if input is less than minimum allowed value
    bnez t1, invalid_input2    # If less, jump to invalid_input2
    
    fge.s t1, ft2, ft1         # Compare if input is greater than or equal to maximum allowed value
    bnez t1, invalid_input2    # If greater, jump to invalid_input2
    
    j done_input2              # If input is valid, jump to done_input2
    
invalid_input2:
    print_string prompt_invalid_input  # Print the invalid input message
    j loop                             # Jump back to the input loop for retry

done_input2:
    fmv.s %value, ft2          # Move the valid input value (accuracy) to the provided variable
.end_macro
