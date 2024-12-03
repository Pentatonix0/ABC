.include "io_macros.s"

.eqv    OUTPUT_DATA_SIZE 128
.eqv    TEXT_SIZE 512

.data 
strbuf_output:           .space OUTPUT_DATA_SIZE       # Buffer for output string
strbuf_temp:             .space OUTPUT_DATA_SIZE       # Temporary buffer
.text
.globl process_string
.globl free_buffer

# -------------------------------------------------------------------------------
# Subroutine to process the string
# -------------------------------------------------------------------------------

init:
    # Initialize pointers and variables
    mv s0, a0                  # s0 - start of the buffer (input string)
    la s1, strbuf_output       # s1 - start of the output buffer
    la s2, strbuf_output       # s2 - end of the output buffer
    la s3, strbuf_temp         # s3 - start of the temporary buffer
    la s4, strbuf_temp         # s4 - end of the temporary buffer
    mv s5, a1                  # s5 - value of N
    li s8, 0                   # s8 - last symbol (initialized to zero)
    li s10, 0
    j process_string_loop

process_string:
    # Parameters:
    # a0 - strbuf (input buffer)
    # a1 - N (length of the sequence)
    # Result:
    # a0 - pointer to the result string
    # a1 - 0 - EOF; -1 - continue iteration

    mv s6, ra                  # Save the return address
    beqz s0, init              # If the string is empty, go to init
    mv s0, a0                  # s0 - start of the string
    li s10, 0                  # s10 - iteration counter

process_string_loop:
    mv t0, s8                  # t0 - last symbol
    lb t1, (s0)                # t1 - current symbol in the string
    addi s10, s10, 1            # Increment the iteration counter
    
    beqz t1, final             # If the current symbol is the end of the string, exit
    bgt t1, t0, branch_one     # If the symbol is greater than the previous one, go to branch_one
    ble t1, t0, branch_two     # If the symbol is less than or equal to the previous one, branch_two

branch_one:
    sb t1, (s4)                # Store the current symbol in the temporary buffer
    addi s4, s4, 1             # Increment the end pointer of the temporary buffer
    j prepare_to_next_iteration

branch_two:
    sub t0, s4, s3             # t0 = s4 - s3 (length of the temporary buffer)
    bge t0, s5, branch_three   # If length &amp;gt;= N, go to branch_three
    j branch_four

branch_three:
    # Free the output buffer
    mv a0, s1
    li a1, OUTPUT_DATA_SIZE
    jal free_buffer

    # Copy data from the temporary buffer to the output buffer
    mv a0, s3
    li a1, OUTPUT_DATA_SIZE
    mv a2, s1
    jal copy_buffer

branch_four:
    # Free the temporary buffer
    mv a0, s3
    li a1, OUTPUT_DATA_SIZE
    jal free_buffer

    # Update pointers for the next iteration
    mv s4, s3
    lb t6, (s0)                # Copy the current symbol into the new temporary buffer
    sb t6, (s4)
    addi s4, s4, 1

    j prepare_to_next_iteration

prepare_to_next_iteration:
    lb s8, (s0)                # Remember the current symbol for the next iteration
    li t6, TEXT_SIZE
    beq s10, t6, update_buffer # If the end of the string is reached, update the buffer
    addi s0, s0, 1             # Move to the next character in the string
    j process_string_loop

update_buffer:
    # Finalize the string processing
    mv a0, s1
    li a1, -1                  # Set the EOF flag
    mv ra, s6                  # Restore the return address
    ret

# -------------------------------------------------------------------------------
# Function to copy data from one buffer to another
# -------------------------------------------------------------------------------

copy_buffer:
    # a0 - from (source buffer)
    # a1 - len from (length of the data to copy)
    # a2 - to (destination buffer)
    mv t0, a0                  # t0 - pointer to the source buffer
    mv t1, a1                  # t1 - length of the data
    mv t2, a2                  # t2 - pointer to the destination buffer
    sub s2, s4, s3
    add s2, s1, s2
    
copy_buffer_loop:
    lb t4, (t0)                # Read a byte from the source buffer
    sb t4, (t2)                # Write the byte to the destination buffer
    addi t0, t0, 1             # Increment the source buffer pointer
    addi t1, t1, -1            # Decrease the length
    addi t2, t2, 1             # Increment the destination buffer pointer
    bnez t1, copy_buffer_loop  # If there are more data, continue copying
    ret

# -------------------------------------------------------------------------------
# Function to free the buffer
# -------------------------------------------------------------------------------

free_buffer:
    # a0 - buffer
    # a1 - length of the buffer
    mv t1, a0                  # t1 - pointer to the buffer
    #add t1, t1, a2             # Uncomment this line if offset needs to be added

free_buffer_loop:
    sb zero, (t1)              # Set the byte in the buffer to zero
    addi t1, t1, 1             # Move to the next byte
    addi a1, a1, -1            # Decrease the length
    bnez a1, free_buffer_loop  # If the buffer is not completely freed, continue
    ret

# -------------------------------------------------------------------------------
# Finalization of processing
# -------------------------------------------------------------------------------

final:
    sub t5, s2, s1
    sub t6, t5, s5
    add s1, s1, t6
    mv a0, s1                  # Return the result in a0
    li a1, 0                   # Set EOF flag to 0
    mv ra, s6                  # Restore the return address
    ret