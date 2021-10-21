// COEN 20 Lab #1
// Author: Madeleine Waldie
// Due Date: 10/28/21
// 
// Implement the 5 functions below in Assembly

	.syntax     unified
	.cpu        cortex-m4
	.text

// Function 1: UseLDRB: Copy 1 byte at a time using LDRB and STRB, and optimize the execution time
	.global     UseLDRB
	.align
	.thumb_func
UseLDRB:
    .rept   512         // Repeat 512 times (to copy 512 bytes of data 1 at a time = 512/1 = 512)
    LDRB    R2,[R1],1   // Store R1 in R2; Increment address by 1
    STRB    R2,[R0],1   // Store R2 in R0; Increment address by 1
    .endr               // End repeat

    BX      LR          // Return

// Function 2: UseLDRH: Copy 2 bytes at a time using LDRH and STRH, and optimize the execution time
	.global 	UseLDRH
	.align
	.thumb_func
UseLDRH:
    .rept   256         // Repeat 512 times (to copy 512 bytes of data 2 at a time = 512/2 = 256)  
    LDRH    R2,[R1],2   // Store R1 in R2; Increments address by 2
    STRH    R2,[R0],2   // Store R2 in R0; Increments address by 2
    .endr               // End repeat

    BX      LR          // Return

// Function 3: UseLDR: Copy 4 bytes at a time using LDR and STR, and optimize the execution time
	.global 	UseLDR
	.align
	.thumb_func
UseLDR:
    .rept   128         // Repeat 512 times (to copy 512 bytes of data 4 at a time = 512/4 = 128)
    LDR     R2,[R1],4   // Store R1 in R2; Increments address by 4
    STR     R2,[R0],4   // Store R2 in R0; Increments address by 4
    .endr               // End repeat

    BX      LR          // Return

// Function 4: UseLDRD: Copy 8 bytes at a time using LDRD and STRD, and optimize the execution time
	.global 	UseLDRD
	.align
	.thumb_func
UseLDRD:
    .rept   64              // Repeat 512 times (to copy 512 bytes of data 8 at a time = 512/8 = 64) 
    LDRD    R2,R3,[R1],8    // Store R1 in R2 & R3; Increments address by 8
    STRD    R2,R3,[R0],8    // Store R2 & R3 in R0; Increments address by 8
    .endr                   // End repeat

    BX      LR              // Return

// Function 5: UseLDM: Copy 32 bytes at a time using LDMIA and STMIA & optimize the execution time
	.global 	UseLDM
	.align
	.thumb_func
UseLDM:
    PUSH    {R4-R12}        // Preserve registers R4-R12

    .rept   16              // Repeat 512 times (to copy 512 bytes of data 32 at a time = 512/32 = 16) 
    LDMIA   R1!,{R4-R12}    // Store R1 in R4-R12
    STMIA   R0!,{R4-R12}    // Store R4-R12 in R0
    .endr                   // End repeat
    
    POP     {R4-R12}        // Restore registers R4 - R12
    BX      LR              // Return


	.end