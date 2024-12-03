.include "io_macros.s"

.text
.global read_file
.global open_file
.global close_file
.global write_file
# ------------------------------------------------------------------------------ 
# Subroutine for opening a file 
# ------------------------------------------------------------------------------ 
# Input parameters:
# a0 - filename (address of the file path)
# a1 - flags (0 for read, other values for different access modes)
# Output data:
# a0 - file descriptor (if the file is successfully opened)
# t2 - error flag (-1 if there's an error)

open_file:
    # Save input parameters
    mv    t0, a0            # t0 = filename (a0)
    mv    t1, a1            # t1 = flag (a1)

    # Open the file (sys_open)
    li    a7, 1024          # system call for opening file
    mv    a1, t1            # a1 = flag for opening file
    ecall                   # perform the system call (result in a0)

    # Check for error in file opening
    li    t2, -1            # t2 = -1 (error flag)
    beq   a0, t2, er_name   # if a0 == -1, error opening file

    # File opened successfully, store the file descriptor
    mv    t0, a0            # t0 = file descriptor
    ret

# ------------------------------------------------------------------------------ 
# Subroutine for reading data from a file
# ------------------------------------------------------------------------------ 
# Input parameters:
# a0 - file descriptor (the file to read from)
# a1 - buffer (address where data will be stored)
# a2 - length of the buffer (max number of bytes to read)
# Output data:
# a0 - number of bytes read (returns 0 if end of file is reached)
# t2 - error flag (-1 if an error occurs)

read_file:
    li    a7, 63            # system call for reading from file
    li    a2, 512
    ecall                   # perform the system call (result in a0)

    # Check for error during reading
    li    t2, -1            # t2 = -1 (error flag)
    beq   a0, t2, er_read   # if a0 == -1, error reading file

    # Return successfully after reading
    ret

# ------------------------------------------------------------------------------ 
# Subroutine for closing the file 
# ------------------------------------------------------------------------------ 
# Input parameters:
# a0 - file descriptor (the file to close)

close_file:
    li    a7, 57            # system call for closing file
    ecall                   # perform the system call to close the file

    # Exit the subroutine
    ret

# ------------------------------------------------------------------------------ 
# Subroutine for writing data to a file
# ------------------------------------------------------------------------------ 
# Input parameters:
# a0 - file descriptor (the file to write to)
# a1 - buffer (the data to be written)
# a2 - size of the buffer (length of data to write)
# Output:
# a0 - number of bytes written (returns the number of bytes written)

write_file:
    li    a7, 64            # system call for writing to file
    ecall                   # perform the system call (result in a0, number of bytes written)

    # Check for error during writing
    li    t2, -1            # t2 = -1 (error flag)
    beq   a0, t2, er_write  # if a0 == -1, error writing file

    # Successfully written, return
    ret

# ------------------------------------------------------------------------------ 
# Error handling subroutines
# ------------------------------------------------------------------------------ 
er_name:
    er_name_macro           # Error opening the file

er_read:
    er_read_macro           # Error reading the file

er_write:
    er_write_macro          # Error writing to the file

# ------------------------------------------------------------------------------ 
# Program exit
# ------------------------------------------------------------------------------ 
end:
    exit_macro              # Exit the program

