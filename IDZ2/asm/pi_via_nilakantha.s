.data
    pi:     .float 3.0         # Initialize pi with the initial approximation value 3.0
    one:    .float 1.0         # Constant value 1.0 for calculations
    four:   .float 4.0         # Constant value 4.0 for the numerator multiplier in the Nilakantha series
    two:    .float 2.0         # Constant value 2.0 for the denominator multiplier in the Nilakantha series
    hundred:    .float 100.0   # Constant value 100.0, used in normalization
    reference: .float 3.141592653589793      # Reference value of pi (for comparison)

.text
.globl pi_via_nilakantha

# Subroutine for calculating pi using the Nilakantha series
pi_via_nilakantha:
    # Input:
    # fa0 - accuracy (desired precision)
    # Output:
    # fa1 - result of the pi computation (final value of pi)
    # fa2 - computed accuracy

    la t0, hundred               # Load the address of the constant value 100 into register t0
    flw ft9, 0(t0)               # Load the value of 100.0 into floating-point register ft9
    fdiv.s fa0, fa0, ft9         # Divide the input accuracy by 100.0 to normalize the input

    # Load addresses of variables into registers
    la t0, pi                    # Load address of pi into t0 register
    la t1, one                   # Load address of one into t1 register
    la t2, two                   # Load address of two into t2 register
    la t3, four                  # Load address of four into t3 register
    la t4, reference             # Load address of the reference pi value into t4 register

    # Load initial values into floating-point registers
    flw ft11, 0(t4)              # ft11 = reference pi (3.141592653589793)
    flw ft0, 0(t0)               # ft0 = pi = 3.0 (initial approximation)
    flw ft1, 0(t1)               # ft1 = 1.0 (used in calculations for n and sign)
    flw ft2, 0(t2)               # ft2 = 2.0 (used in denominator of Nilakantha series)
    flw ft3, 0(t3)               # ft3 = 4.0 (used as multiplier in the numerator of Nilakantha series)
    
    # Set initial values for iteration index (n) and alternating sign (+1 or -1)
    flw ft4, 0(t1)               # ft4 = n = 1 (starting term index)
    flw ft5, 0(t1)               # ft5 = sign = 1 (starting with positive sign)

loop:
    # Compute the current term of the Nilakantha series: 4 / (2n * (2n+1) * (2n+2))
    fmul.s ft6, ft2, ft4         # ft6 = 2n (denominator part 2n)
    fdiv.s ft7, ft3, ft6         # ft7 = 4 / (2n)
    fadd.s ft6, ft6, ft1         # ft6 = 2n + 1
    fdiv.s ft7, ft7, ft6         # ft7 = 4 / (2n * (2n+1))
    fadd.s ft6, ft6, ft1         # ft6 = 2n + 2
    fdiv.s ft7, ft7, ft6         # ft7 = 4 / (2n * (2n+1) * (2n+2))

    # Multiply the term by the sign (alternating +1 or -1)
    fmul.s ft7, ft7, ft5         # ft7 = term * sign
    
    # Update the value of pi: pi = pi + term
    fadd.s ft8, ft0, ft7         # ft8 = pi + term
    
    # Check if the required number of iterations has been completed (based on accuracy)
    flt.s t1, ft11, ft4          # Compare n (iteration count) with the reference limit (ft11)
    fmv.s ft0, ft8               # Update the value of pi in ft0
    
    # If accuracy achieved, exit the loop
    fsub.s ft10, ft11, ft0       # Compute the difference between reference pi and current pi estimate
    fabs.s ft10, ft10            # Get the absolute value of the difference
    fdiv.s ft10, ft10, ft11      # Normalize the difference by dividing by reference pi value
    flt.s t6, fa0, ft10          # If normalized difference is less than accuracy, stop iteration
    beqz t6, done                # If the condition is met, exit the loop
    
    # Increment n (iteration index) and alternate the sign for the next term
    fadd.s ft4, ft4, ft1         # Increment n by 1
    fneg.s ft5, ft5              # Alternate the sign (positive <-> negative)
    
    j loop                       # Repeat the loop for the next iteration

done:
    # Multiply the final accuracy result by 100.0 (ft9) to obtain the computed accuracy
    fmul.s ft10, ft10, ft9
    fmv.s fa2, ft10             # Store the computed accuracy in fa2
    fmv.s fa1, ft0              # Store the final computed value of pi in fa1
    ret                         # Return from the subroutine
