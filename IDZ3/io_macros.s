.data
    prompt:                  .asciz "Enter file name: "
    space:                   .asciz " "
    new_line:                .asciz "\n"
    prompt_input_error:      .asciz "Error! Check input data"
    prompt_input_file_name:  .asciz "Input file path: "  # Prompt to enter the file path
    er_name_mes:             .asciz "Incorrect file name\n"
    er_read_mes:             .asciz "Incorrect read operation\n"
    er_write_mes:            .asciz "Incorrect write operation\n"
    invalid_message:         .asciz "Invalid input. Please enter a number between 2 and 127.\n"
    input_N:                 .asciz "Please input N (2 &amp;lt;= N &amp;lt;= 127): "
    prompt_invalid_input:    .asciz "Invalid input! Please try again\n"  # Message displayed if the user enters invalid input
    prompt_input:            .asciz "Your decision: "  # Prompt for user input
    prompt_start:            .asciz "Print result to console?\n[1] - YES\n[0] - NO\n"  # Prompt for the user to choose between calculating pi or running tests
    good_bye_mes:            .asciz "\nWriting to the file has been completed successfully!"
    result_mes:              .asciz "The last ascending sequence of N characters: "
    
    

.macro exit_macro
    li      a7, 10           # System call for exit
    ecall                    # Make the system call to exit
.end_macro


# Macro for input and validation of user decision (0 or 1)
.macro input_and_validate %value
    print_string prompt_start  # Print the prompt to the user 
loop_in:
    print_string prompt_input  # Ask for user input (their decision)
    li a7, 5                   # System call for reading an integer (user's choice)
    ecall                      # Make the system call to read the input
    
    mv t1, a0                  # Move the input value into register t1
    li t2, 2                   # Load the value 2 into register t2 (to check the valid range)
    
    bltz t1, invalid_input     # If t1 &amp;lt; 0, jump to invalid_input (input is negative)
    bge t1, t2, invalid_input  # If t1 &amp;gt;= 2, jump to invalid_input (input is not 0 or 1)
    j done_input               # If input is valid (0 or 1), jump to done_input
    
invalid_input:
    print_string prompt_invalid_input  # Print the invalid input message
    j loop_in                             # Jump back to the input loop for retry
 
done_input:
    mv %value, a0              # Move the valid input value (0 or 1) to the provided variable
.end_macro


.macro get_valid_N %N
    li t0, 0                  # t0 - input validity flag (0 - invalid, 1 - valid)
    
get_input:
    print_string input_N      # Print prompt asking for N
    li a7, 5                  # System call for reading an integer
    ecall
    
    # Check if the number is within the range 2 &amp;lt;= N &amp;lt;= 127
    # a0 contains the entered number
    li t1, 2                  # t1 - minimum value
    li t2, 127                # t2 - maximum value
    blt a0, t1, invalid_input # If a0 &amp;lt; 2, it's invalid
    bgt a0, t2, invalid_input # If a0 &amp;gt; 127, it's invalid

    # If the input is valid
    mv a1, a0                 # Store the entered value in a1 (N)
    li t0, 1                  # Set the flag to 1, indicating valid input
    j input_done

invalid_input:
    # If the input is invalid, print the error message
    li a7, 4                  # System call for printing a string
    la a0, invalid_message    # Address of the error message
    ecall

    # Prompt for input again
    j get_input

input_done:
    # Input is finished, valid N is in a1
    mv %N, a1
.end_macro 

.macro read_int %reg
    li a7, 5                # System call for reading an integer
    ecall
    mv %reg, a0             # Save the result in the register
.end_macro

.macro read_string %reg
    li a7, 8                # System call for reading a string
    ecall
    mv %reg, a0             # Save the result in the register
.end_macro

.macro print_string %str
    li a7, 4                # System call for printing a string
    la a0, %str             # Load the address of the string
    ecall
.end_macro

.macro  input_file_name %reg, %max_length
    print_string prompt_input_file_name   # Prompt for input file name
    li a7, 8                # System call for reading a string
    li a1, %max_length
    la a0, %reg
    ecall
    li t4, '\n'
    la t5, %reg
loop:
    lb t6, (t5)             # Load byte from string
    beq t4, t6, replace     # If newline character found, replace it
    addi t5, t5, 1          # Move to the next byte
    b loop                  # Continue loop
replace:
    sb zero, (t5)           # Replace newline with null terminator
.end_macro

.macro print_int %int
    li a7, 1                # System call for printing an integer
    mv a0, %int             # Load the integer to be printed
    ecall
.end_macro

.macro printN
    li a7, 4                # System call for printing a string
    la a0, new_line         # Load the address of newline string
    ecall
.end_macro

.macro print_buffer %start
    mv t0, %start
    li a7, 4                # System call for printing a string
    mv a0, t0               # Load the address of the string
    ecall
    printN                  # Print a newline after the buffer
.end_macro

.macro er_name_macro
    print_string er_name_mes  # Print error message for incorrect file name
    exit_macro               # Exit the program
.end_macro

.macro er_read_macro
    # Error with reading file
    print_string er_read_mes  # Print error message for incorrect read operation
    exit_macro               # Exit the program
.end_macro

.macro er_write_macro
    # Error with writing file
    print_string er_write_mes  # Print error message for incorrect write operation
    exit_macro               # Exit the program
.end_macro

.macro find_last_incresing_sequence %file, %string, %N, %text_size, %result
process_loop:
    la a0, %string            # Load the address of the string
    li a1, %text_size         # Set the text size
    jal free_buffer           # Free the buffer

    mv a0, %file              # Set the file pointer
    la a1, %string            # Set the address of the string buffer
    jal read_file             # Read the file content into the string

    mv t1, a0                 # Store the return value (file status)
    
    la a0, %string            # Set the string pointer
    mv a1, %N                 # Set the N value
    jal process_string        # Process the string to find the sequence
    
    mv %result, a0            # Store the result in %result
    mv t6, a1                 # Store the iteration counter
    bnez t6, process_loop     # If there is more to process, repeat
.end_macro

.macro OPEN_FILE %name %desc %flag
    la a0, %name              # Load the address of the file name
    li a1, %flag
    jal open_file             # Open the file
    mv %desc, a0              # Store the file descriptor
.end_macro

.macro CLOSE_FILE %desc
    mv a0, %desc              # Load the file descriptor
    jal close_file            # Close the file
.end_macro

.macro WRITE_FILE %desc, %buf, %len
    mv a0, %desc              # Load the file descriptor
    mv a1, %buf
    mv a2, %len
    jal write_file            # Close the file
.end_macro

.macro good_bye
   print_string good_bye_mes
.end_macro 

.macro input_error
    print_string prompt_input_error  # Print the input error message
.end_macro