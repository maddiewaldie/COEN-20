// COEN 20 Lab #4
// Author: Madeleine Waldie
// Due Date: 11/4/21 
// 
// Create ARM assembly functions for the diameter and circumference in inches
// Note: Since you'll be using int arithmetic, you won't be able to return values w/ fractional parts. 
// Instead, each function computes 2 32 bit values & returns them as a single 64 bit number

	.syntax     unified
	.cpu        cortex-m4
	.text

// Function 1: TireDiam: Calculate the tire diameter using the function & parameters below:
	// Diameter = R + 2 * (A/100) * (W/25.4) = R + (2*A*W)/2540 = R + (A*W)/1270
	// Parameters: uint32_t W, uint32_t A, uint32_t R
	.global     TireDiam
	.align
	.thumb_func
TireDiam:
	// Prepare registers; R0 = W; R1 = A; R2 = R
	PUSH    {R4,LR}     // Preserve R4 and LR
	LDR     R3,=1270    // We have everything for this equation (R + (A*W)/1270), except 1270. So, oad a register w/ 1270.

	// Start calculating diameter using equation (R + (A*W)/1270)
	MUL     R4,R0,R1    // First, multiply A * W; R4 <- R0 * R1
	UDIV    R0,R4,R3    // Next, divide result (A*W) by 1270; R0 <- R4 ÷ R3

	// Compute two 32 bit values to be returned as single 64 bit integer (quotient & remainder)
	ADDS    R1,R0,R2    // Add together R and the quotient (A*W)/1270; R1 <- R0 + R2
	MLS     R0,R4,R0,R3 // (A*W) - (A*W)/1270*1270 = R4 - (R0 * R3)

	POP     {R4,PC}     // Restore R4 & PC
	BX      LR          // Return

// Function 2: TireCirc: Calculate the tire circumference using the function & parameters below:
	// Circumference = π * diameter = (4987290 * D1 + 3927 * D2)/1587500
	// Parameters: uint32_t W, uint32_t A, uint32_t R
	.global     TireCirc
	.align
	.thumb_func
TireCirc:
	PUSH    {LR}        // Preserve R4 and LR
	BL      TireDiam    // Need to call tire diameter, as results are used in circumference calculation

	// Prepare registers; Will use R1 as quotient (D1) * R0 as remainder (D2)
	LDR     R2,=4987290
	LDR     R3,=3927

	// Start calculating circumferences using equation ((4987290 * D1 + 3927 * D2)/1587500)
	MUL     R2,R2,R1    // First, multiply 4987290 * D1 = R2 <- R2 * R1
	MUL     R3,R3,R0	// Next, multiply 3927 * D2 = R3 <- R3 * R0
	ADD     R2,R2,R3    // Add together the two products (4987290 * D1 + 3927 * D20) = R2 <- R2*R3

	// Prepare register with the last constant in the equation
	LDR	R3,=1587500

	// Compute two 32 bit values to be returned as single 64 bit integer (quotient & remainder)
	UDIV    R1,R2,R3    // Find quotient of ((4987290 * D1 + 3927 * D2)/1587500) = R1 <- R2 ÷ R4
	MLS     R0,R1,R3,R2 // Find the remainder of ((4987290 * D1 + 3927 * D2)/1587500) = R1 - (R3 * R2)

	POP     {PC}		// Restore R4 and PC
	BX      LR          // Return

	.end
