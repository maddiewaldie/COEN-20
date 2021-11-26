// COEN 20 Lab #8
// Author: Madeleine Waldie
// Due Date: 12/2/21 
// 
// Create equivalent replacements in as- sembly language for the following four functions found in the C main program

	.syntax     unified
	.cpu        cortex-m4
	.text

// Function: Root1: Computes the root given by (-b + √Discriminant(a, b, c))/2a
// Parameters: float a, float b, float c
	.global     Root1
	.align
	.thumb_func
Root1:  
    PUSH        {R4, R5, LR}    // Preserve R4, R5, and LR

    // Top half of equation
    VMOV        R4, S0          // Save S0 = a: R4 = a
    VMOV        R5, S1          // Save S1 = b: R5 = b
    BL          Discriminant    // Calculate the discriminant: S0 = b*b – 4*a*c
    VMOV        S4, R4          // S4 = a
    VMOV        S1, R5          // S1 = b
    VSQRT.F32   S0, S0          // Calculate the square root: S0 = sqrt(b*b – 4*a*c)
    VNEG.F32    S1, S1          // Make b negative: S1 = -b
    VADD.F32    S0, S0, S1      // Find the top half of the equation: S0 = -b + sqrt(b*b – 4*a*c)

    // Bottom half of equation
    VMOV        S2, 2.0         // Get the constant for the bottom half
    VMUL.F32    S2, S2, S4      // Multiply a by 2: S2 = 2.0*a
    VDIV.F32    S0, S0, S2      // Now, divide the top half by 2a: S0 = (-b + sqrt(b*b–4*a*c))/2*a

    POP         {R4, R5, LR}    // Restore R4, R5, & PC
    BX          LR              // Return

// Function: Root2: Computes the root given by (-b - √Discriminant(a, b, c))/2a
// Parameters: float a, float b, float c
	.global     Root2
	.align
	.thumb_func
Root2:
    PUSH        {R4, R5, LR}    // Preserve R4, R5, and LR

    // Top half of equation
    VMOV        R4, S0          // Save S0 = a: R4 = a
    VMOV        R5, S1          // Save S1 = b: R5 = b
    BL          Discriminant    // Calculate the discriminant: S0 = b*b – 4*a*c
    VMOV        S4, R4          // S4 = a
    VMOV        S1, R5          // S1 = b
    VSQRT.F32   S0, S0          // Calculate the square root: S0 = sqrt(b*b – 4*a*c)
    VNEG.F32    S0, S0          // Make the previous result negative, as we're subtracting the √discriminant: S0 <- -(SquareRoot(Discriminant))
    VNEG.F32    S1, S1          // Make b negative: S1 = -b
    VADD.F32    S0, S0, S1      // Find the top half of the equation: S0 = -b - sqrt(b*b – 4*a*c)

    // Bottom half of equation
    VMOV        S2, 2.0         // Get the constant for the bottom half
    VMUL.F32    S2, S2, S4      // Multiply a by 2: S2 = 2.0*a
    VDIV.F32    S0, S0, S2      // Now, divide the top half by 2a: S0 = (-b - sqrt(b*b–4*a*c))/2*a

    POP         {R4, R5, LR}    // Restore R4, R5, & PC
    BX          LR              // Return

// Function: Quadratic:  Computes the quadratic, 𝑎𝑥^2 + 𝑏𝑥 + 𝑐; Most efficient implementation: 𝑐 + 𝑥(𝑏 + 𝑎𝑥)
// Parameters: float x, float a, float b, float c
	.global     Quadratic
	.align
	.thumb_func
Quadratic:
    VMOV        S4, S0
    
    VMUL.F32    S1, S1, S0      // First, multiply a * x: S1 = ax
    VADD.F32    S1, S1, S2      // Next, add b to the result: S1 = b + ax
    VMUL.F32    S0, S0, S1      // Multiply this by x: S0 = x(b + ax)
    VADD.F32    S0, S0, S3      // Finally, add c to this: c + x(b + ax)

    BX          LR              // Return

// Function: Discriminant:  Computes the value of the discriminant, 𝑏^2 − 4𝑎𝑐; Functions Root1 and Root2 should call this function.
// Parameters: float a, float b, float c
	.global     Discriminant
	.align
	.thumb_func
Discriminant:
    VMUL.F32    S1, S1, S1      // First, find b^2: S1 = b*b
    VMOV        S3, 4.0         // Next, get the constant: S3 = 4.0
    VMUL.F32    S3, S3, S0      // Next, find 4a: S3 = 4.0*a
    VMUL.F32    S3, S3, S2      // Next, find 4ac: S3 = 4.0*a*c
    VSUB.F32    S0, S1, S3      // Finally, find the discriminant: S0 = b*b – 4.0*a*c

    BX          LR              // Return
	.end