// COEN 20 Lab #7
// Author: Madeleine Waldie
// Due Date: 12/2/21 
// 
// Create equivalent replacements in assembly language for the following 3 functions found in the C main program
// All functions should use shifting to implement division by 4 and multiplication by 2
// Zeller's rule: 𝑓 = 𝑘 + (13𝑚 − 1)/5 + 𝐷 + 𝐷/4 + 𝐶/4 − 2𝐶
    // k = day of month
    // m = month number
    // D = last 2 digits of year
    // C = century - first 2 digits of year
// Website used in calculations: https://www.engr.scu.edu/~dlewis/book3/tools/DivideByConstant1.shtml
	.syntax     unified
	.cpu        cortex-m4
	.text

// Function: Zeller1: Serves as a performance baseline using multiply and divide instructions
	.global     Zeller1
	.align
	.thumb_func
Zeller1: // R0 = k, R1 = m, R2 = D, R3 = C 
    // First, add (13*m-1)/5 to k
    LDR     R12, =13            // Load register with 13, which will be multiplied by m
    MUL     R1, R1, R12         // Multiply 13 by m: R1 = 13*m
    SUB     R1, R1, 1           // Subtract 1 from result: R1 = 13*m - 1

    LDR     R12, =5             // Load register with 5, which will be used for division
    UDIV    R1, R1, R12         // Divide result by 5: R1 = (13*m - 1)/5
    ADD     R0, R0, R1          // Add to R0, which will eventually be returned: R0 = k + (13*m-1)/5

    // Next, add D + D/4 to R0 = k + (13*m-1)/5
    ADD     R0, R0, R2          // Add D to R0: R0 = k + (13*m-1)/5 + D
    ADD     R0, R0, R2, LSR 2   // Divide D by 4 (shifting right twice) and add result to R0: R0 = k + (13*m-1)/5 + D + D/4

    // Next, add C/4 - 2*C to R0 = k + (13*m-1)/5 + D + D/4
    ADD     R0, R0, R3, LSR 2   // Divide C by 4 (shifting right twice) and add result onto R0: R0 = k + (13*m-1)/5 + D + D/4 + C/4
    SUB     R0, R0, R3, LSL 1   // Multiply C by 2 (shifting left once) and subtract result from R0: R0 = k + (13*m-1)/5 + D + D/4 + C/4 - 2*C

    // Check the remainder (% 7), and if the answer is negative, add 7
    LDR     R12 ,=7             // Load register with 7, which will be used to check remainder
    SDIV    R1, R0, R12         // R0 = R0 % 7
    MLS     R0, R12, R1, R0
    CMP     R0, 0               // Check if the remainder is anything but 0
    IT      LT                  // If the remainder is less than 0, then you'll need to add 7
    ADDLT   R0, R0, 7           // Add 7 to R0: R0 = k + (13*m-1)/5 + D + D/4 + C/4 - 2*C + 7
    
    BX      LR                  // Return

// Function: Zeller2: Used to illustrate performance differences as the result of replacing multiply and divide instructions by equivalent instruction sequences
// Don't use multiply (can use divide)
	.global     Zeller2
	.align
	.thumb_func
Zeller2: // R0 = k, R1 = m, R2 = D, R3 = C
    // First, add (13*m-1)/5 to R0
    ADD     R12, R1, R1, LSL 3  // R12 = R1*9 (1+2^3)
    ADD     R1, R12, R1, LSL 2  // R1 = R12 + R1*4 (2^2)
    SUB     R1, R1, 1           // R1 = 13*m-1
    LDR     R12, =5             // Load register with 5, which will be used for division
    UDIV    R1, R1, R12         // R1 = (13*m-1)/5
    ADD     R0, R0, R1          // Add result to R0: R0 = k + (13*m-1)/5

    // Next, add D + D/4 to R0
    ADD     R0, R0, R2          // Add D to R0: R0 = k + (13*m-1)/5 + D
    ADD     R0, R0, R2, LSR 2   // Divide D by 4 (shifting right twice) and add result to R0: R0 = k + (13*m-1)/5 + D + D/4

    // Next, add C/4 - 2*C to R0
    ADD     R0, R0, R3, LSR 2   // Divide C by 4 (shifting right twice) and add result to R0: 0 = R0 = k + (13*m-1)/5 + D + D/4 + C/4
    SUB     R0, R0, R3, LSL 1   // Subtract 2*C from R0: R0 = k + (13*m-1)/5 + D + D/4 - 2*C

    // Check the remainder (% 7), and if the answer is negative, add 7
    LDR     R12, =7             // Load register with 7, which will be used below
    SDIV    R1, R0, R12         // With below, R0 = R0 % 7
    RSB     R1, R1, R1, LSL 3   // R1 = R1 (rounded result) * 7
    SUB     R0, R0, R1
    CMP     R0, 0
    IT      LT                  // If the remainder is less than 0, then you'll need to add 7
    ADDLT   R0, R0, 7           // Add 7 to R0: R0 = k + (13*m-1)/5 + D + D/4 + C/4 - 2*C + 7

    BX      LR                  // Return

// Function: Zeller3: Used to illustrate performance differences as the result of replacing multiply and divide instructions by equivalent instruction sequences
// Don't use multiply or divide
	.global     Zeller3
	.align
	.thumb_func
Zeller3: // R0 = k, R1 = m, R2 = D, R3 = C

    // First, add D + D/4 to R0
    ADD     R0, R0, R2          // Add D to R0: R0 = k + D
    ADD     R0, R0, R2, LSR 2   // Divide D by 4 (by shifting right twice), and add that to R0: R0 = k + D + D/4

    // Next, add C/4 - 2*C to R0
    ADD     R0, R0, R3, LSR 2   // Add C/4 to R0: R0 = k + D + D/4 + C/4
    LDR     R12, =2             // Load register with 2, which will be used
    SUB     R0, R0, R3, LSL 1   // Multiply C by 2 (shifting left once) and subtract result from R0: R0 = k + D + D/4 + C/4 - 2*C

    // Next, add (13*m-1)/5 to R0
    LSL     R12, R1, 4          // R12 = 16*m
    SUB     R12, R12, R1, LSL 1 // R12 = 14*m
    SUB     R12, R12, R1        // R12 = 13*m

    SUB     R1, R12, 1          // Subtract 1 from result: R1 = 13*m - 1
    LDR     R12, =3435973837    // From website: unsigned and divide by 5 (used in Integer Division by a Constant below)
    UMULL   R2, R12, R12, R1    
    ADD     R0, R0, R12, LSR 2  // Add result to R0 += (13*m-1)/5
 
    // Check the remainder (% 7), and if the answer is negative, add 7
    LDR     R12, =2454267027    // From website: signed and divide by 7 (used in Integer Division by a Constant below)
    SMMLA   R12, R12, R0, R0    
    LSR     R1, R0, 31          
    ADD     R1, R1, R12, ASR 2  // R0 = (k + (13*m-1)/5 + D + D/4 + C/4 - 2*C) / 7

    LDR     R12, =7             // Load register with 7, which will be used to check remainder
    MLS     R0, R12, R1, R0
    CMP     R0, 0               // Check if the remainder is anything but 0
    IT      LT                  // If the remainder is less than 0, then you'll need to add 7
    ADDLT   R0, R0, 7           // Add 7 to R0: R0 = k + (13*m-1)/5 + D + D/4 + C/4 - 2*C + 7

    BX      LR                  // Return

	.end
