// COEN 20 Lab #6
// Author: Madeleine Waldie
// Due Date: 11/18/21 
// 
// Implement ReverseBits and ReverseBytes without using the REV and RBIT instructions
// Your solutions should execute as fast as possible, so implementing them with loops is not acceptable
// Instead, you need to find the shortest possible straight-line sequence of instructions that will do the reversal
// Hint: You may find the .rept directive to be useful.
	.syntax     unified
	.cpu        cortex-m4
	.text

// Function:ReverseBits: Returns a result that corresponds to reversing the order of all the bits in its input
// Parameter: uint32_t word (in R0)
	.global     ReverseBits
	.align
	.thumb_func
ReverseBits:
    .rept   32          // Repeat loop 32 times, as there are 32 bits in the word
    LSLS    R0, R0, 1   // Left shift the most significant bit into carry
    RRX     R1, R1      // Push the most significant bit into the right side of new register (thus reversing the bits)
    .endr               // End loop

    MOV     R0, R1      // Move result back into R0, as it's currently in R1
    BX      LR          // Return the result

// Function: ReverseBytes: Returns a result that corresponds to reversing the order of all the bytes in its input
// Parameter: uint32_t word (in R0)
	.global     ReverseBytes
	.align
	.thumb_func
ReverseBytes:
    MOV     R1, R0          // Move R0 into R1, where we'll be reversing the bytes

    // 32 bits / 8 bits in a byte = 4 bytes to be reversed

    // Reversal of the first byte
    BFI     R1, R0, 24, 8   // Insert the first byte (bits 0-7) of the word into the last byte (bits 24-31) of the reversed word
    LSR     R0, R0, 8       // Move on to second byte

    // Reversal of the second byte
    BFI     R1, R0, 16, 8   // Insert the second byte (bits 8-15) of the word into the second to last byte (bits 16-23) of the reversed word
    LSR     R0, R0, 8       // Move on to third byte

    // Reversal of the third byte
    BFI     R1, R0, 8, 8    // Insert the third byte (bits 16-23) of the word into the second byte (bits 8-15) of the reversed word
    LSR     R0, R0, 8       // Move on to fourth byte

    // Reversal of the fourth byte
    BFI     R1, R0, 0, 8    // Insert the fourth byte (bits 24-31) of the word into the first byte (bits 0-7) of the reversed word

    MOV     R0, R1          // Move result back into R0, as it's currently in R1
    BX      LR              // Return the result

	.end
    