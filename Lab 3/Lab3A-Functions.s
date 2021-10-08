// COEN 20 Lab #1
// Author: Madeleine Waldie
// Due Date: 10/21/21
// 
// Implement the 4 functions below in Assembly

	.syntax 	unified
	.cpu    	cortex-m4
	.text

// Function #1: Add: Adding two integers together
	.global 	Add
	.align
	.thumb_func
Add:
	ADD		R0,R0,R1	// Add R0 and R1 together, and save the result in register R0
	BX 		LR			// Return the result

// Function #2: Less1: Subtracting an integer by one
	.global 	Less1
	.align
	.thumb_func
Less1:
	SUB 	R0,R0,1		// Subtract one from R0, and save the result in register R0
	BX  	LR			// Return the result

// Function #3: Square2x: Finding two times an integer, squared
	.global 	Square2x
	.align
	.thumb_func
Square2x:
	MOV 	R1,R0		// Copy the value of R0 to R1 (R0=R1)
	ADD 	R0,R0,R1	// Add R0 and R1 together, to get 2 times R0
	B   	Square		// Square the resulting R0

// Function #4: Last: Adding an integer to the square root of itself
	.global 	Last
	.align
	.thumb_func
Last:
	PUSH	{R4,LR}		// Preserbe R4 and LR
	MOV		R4,R0		// Copy R0 into R4 (R0=R4)
	BL		SquareRoot	// Take the square root of R0
	ADD		R0,R0,R4	// Add R4 to R0
	POP		{R4,PC}		// Restore R4 (gives result)

	.end