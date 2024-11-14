.data
    pi:     .float 3.0         # Initialize pi with the initial approximation value 3.0
    one:    .float 1.0         # Constant value 1.0 for calculations
    four:   .float 4.0         # Constant value 4.0 for the numerator multiplier in the Nilakantha series
    two:    .float 2.0         # Constant value 2.0 for the denominator multiplier in the Nilakantha series
    limit:  .float 1000.0      # The limit for the number of iterations (we compute up to this value)

.text
.globl pi_via_nilakantha

# Subroutine for calculating pi using the Nilakantha series
pi_via_nilakantha:
    # Output:
    # fa0 - result of the pi computation (final value of pi)

    # Load addresses of variables into registers
    la t0, pi                 # Load the address of pi into register t0
    la t1, one                # Load the address of one into register t1
    la t2, two                # Load the address of two into register t2
    la t3, four               # Load the address of four into register t3
    la t4, limit              # Load the address of the limit into register t4

    # Load initial values into floating-point registers
    flw   ft11, 0(t4)         # ft11 = limit (1000.0), which sets the maximum number of iterations
    flw   ft0, 0(t0)          # ft0 = pi = 3.0 (initial approximation)
    flw   ft1, 0(t1)          # ft1 = 1.0 (used in calculations)
    flw   ft2, 0(t2)          # ft2 = 2.0 (used in denominator of Nilakantha series)
    flw   ft3, 0(t3)          # ft3 = 4.0 (used as multiplier in the numerator of Nilakantha series)
    
    # Set initial values for the iteration index (n) and sign (alternating +1 and -1)
    flw   ft4, 0(t1)          # ft4 = n = 1 (starting with the first term)
    flw   ft5, 0(t1)          # ft5 = sign = 1 (starting with a positive sign)
    
loop:
    # Compute the term: 4 / (2n * (2n+1) * (2n+2)) and store in ft7
    fmul.s ft6, ft2, ft4      # ft6 = 2n (denominator part 2n)
    fdiv.s ft7, ft3, ft6      # ft7 = 4 / (2n)
    fadd.s ft6, ft6, ft1      # ft6 = 2n + 1
    fdiv.s ft7, ft7, ft6      # ft7 = 4 / (2n * (2n+1))
    fadd.s ft6, ft6, ft1      # ft6 = 2n + 2
    fdiv.s ft7, ft7, ft6      # ft7 = 4 / (2n * (2n+1) * (2n+2))

    # Multiply by the sign (alternating +1 or -1)
    fmul.s ft7, ft7, ft5      # ft7 = term * sign
    
    # Update the value of pi: pi = pi + term
    fadd.s ft8, ft0, ft7      # ft8 = pi + term
    
    # Check if we've completed the required number of iterations
    flt.s t1, ft11, ft4       # Compare n (ft4) with limit (ft11), check if n < limit
    fmv.s ft0, ft8            # Update the value of pi in ft0
    
    # If n >= limit, exit the loop
    bnez t1, done             # If n >= limit, exit the loop
    
    # Increment n and alternate the sign
    fadd.s ft4, ft4, ft1      # Increment n by 1
    fneg.s ft5, ft5           # Alternate the sign: if +1, make -1, and vice versa
    
    j loop                    # Repeat the loop

done:
    fmv.s fa0, ft0            # Store the final value of pi in fa0 (result)
    ret                       # Return from the function

