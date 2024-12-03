.include "io_macros.s"

# Define constants for buffer sizes
.eqv    NAME_SIZE 512       # Size of the buffer for the file name
.eqv    TEXT_SIZE 512       # Size of the buffer for the text data
.eqv    OUTPUT_DATA_SIZE 128 # Size of the buffer for the output data

.data
file_name:               .space 512       # Buffer for the file name
output_file_name:        .space 512 
strbuf:                  .space 512        # Buffer for string input

.text
.global RunProject

# Register usage:
# s7 - file descriptor (for file operations)
# s11 - result (last ascending sequence)
# s9  - N (length of the sequence to find)

RunProject:
    # Step 1: Get input file name from the user
    input_file_name file_name, NAME_SIZE   # Prompt user to input the file name

    # Step 2: Get valid N (sequence length) from the user
    get_valid_N s9                        # Prompt user to input N (2 &amp;lt;= N &amp;lt;= 127)

    # Step 3: Open the file for reading (0 flag indicates read mode)
    OPEN_FILE file_name, s7, 0            # Open the file in read mode (flag = 0)

    # Step 4: Find the last ascending sequence in the file
    find_last_incresing_sequence s7, strbuf, s9, TEXT_SIZE, s11

    # Step 5: Close the file after processing
    CLOSE_FILE s7

    # Step 6: Ask the user if they want to print the result to the console (0 or 1)
    input_and_validate t6                   # Validate user input for console print decision

    # If user wants to print to console (t6 = 1), print the result
    bnez t6, print_to_console               # If t6 is not zero (user chose to print), jump to print_to_console

    # Otherwise, save the result to a file
    j save                                  # Jump to save the result to a file

# Print the result to the console
print_to_console:
    printN                                  # Print a newline for better formatting
    print_string result_mes                 # Print the result message
    print_buffer s11                        # Print the last ascending sequence found

# Save the result to a new file
save:
    # First, free the buffer used for the file name
    la a0, file_name                       # Load the address of the file name
    li a1, NAME_SIZE                       # Set the buffer size
    jal free_buffer                        # Free the buffer used for the file name

    # Get a new file name for saving the output
    input_file_name file_name, NAME_SIZE   # Prompt user to input the output file name

    # Open the new file for writing (1 flag indicates write mode)
    OPEN_FILE file_name, s7, 1             # Open the file in write mode (flag = 1)
    # Write the result (last ascending sequence) to the file
    WRITE_FILE s7, s11, s9                 # Write the result to the file, s9 = length, s11 = data

    # Close the file after writing
    CLOSE_FILE s7

    # Display a goodbye message
    good_bye                               # Print a goodbye message

    # Exit the program
    exit_macro                              # Exit the program