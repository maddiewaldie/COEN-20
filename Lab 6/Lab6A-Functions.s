// COEN 20 Lab #5
// Author: Madeleine Waldie
// Due Date: 11/4/21 
// 
// Create an equivalent replacement in assembly language for function MatrixMultiply found in the C main program

	.syntax     unified
	.cpu        cortex-m4
	.text

// Function: MatrixMultiply: Find the product of two 3x3 matrices (will be another 3x3 matrix)
// Parameters: int32_t A[3][3], int32_t B[3][3], int32_t C[3][3]
	.global     MatrixMultiply
	.align
	.thumb_func
MatrixMultiply:
        PUSH    {R4-R11,LR}     // Preserve registers R4-R11 and LR
        LDR     R4,=0           // R4 will keep track of the row number
        MOV     R9,R0           // Make a copy of the A pointer to R9
        MOV     R10,R1          // Make a copy of the B pointer to R10
        MOV     R11,R2          // Make a copy of the C pointer to R11

// Loop for row
Row:    CMP     R4,3            // Compare the current row # to see if it exceeds 2 (three rows = 0, 1, 2)
        BGE     EndIf           // If row # is greater than possible, exit loop
        LDR     R5,=0           // Reset the column number to 0 before going through each column

// Loop for column
Column: CMP     R5,3            // Compare the current column # to see if it exceeds 2 (three columns = 0, 1, 2)
        BGE     EndCol          // If column # is greater than possible, exit loop
        LDR     R6,=0           // R6 will be the k iterator. Set k = 0 initially
        LDR     R0,=3           // R0 will be used to hold all of the constants we use in math. The first constant we need is 3

        //Formula: Address of A[row][col] = (Starting address of A) + 4 * (3*row + col)
        MUL     R7,R4,R0        // Multiply the row by 3 (3*row)
        ADD     R7,R7,R5        // Add result (3*row) + column
        LDR     R0,=4           // The next constant we need is 4 (see formula above)
        MLA     R7,R7,R0,R9     // Holds the address for A[r][c]
        LDR     R0,=0           // The next constant we need is 0
        STR     R0,[R7]         // Set A[r][c] = 0

// Loop for k
K:      CMP     R6,3            // Compare the current k # to see if it exceeds 2 (three iterations = 0, 1, 2)
        BGE     EndK            // If k # is greater than possible, exit loop

        //Formula: Address of B[row][k] = (Starting address of B) + 4 * (3*row + k)
        LDR     R0,=3           // The next constant we need is 3 (see formula above)
        MUL     R0,R4,R0        // Multiply the row by 3 (3*row)
        ADD     R0,R0,R6        // Add result (3*row) + k
        LDR     R8,=4           // The next constant we need is 4 (see formula above)
        MLA     R1,R8,R0,R10    // Holds the address for B[r][k]
        LDR     R1,[R1]

        //Formula: Address of C[k][col] = (Starting address of A) + 4 * (3*k + col)
        LDR     R0,=3           // The next constant we need is 3 (see formula above)
        MUL     R0,R0,R6        // Multiply the k by 3 (3*k)
        ADD     R0,R0,R5        // Add result (3*k) + col
        MLA     R2,R8,R0,R11    // Holds the address for C[k][col]
        LDR     R2,[R2]

        MOV     R0,R7           // A[r][c] becomes a parameter
        LDR     R0,[R0]         

        BL      MultAndAdd      // Call function defined in Lab6A-Main.c
        STR     R0,[R7]         //Stores contents of MultAndAdd into A[r][c]

        ADD     R6,R6,1         // Increment k iterator
        B       K               // Go back to "K" for another loop

// End of k loop
EndK:   ADD     R5,R5,1         //Increment column #
        B       Column          // Go back to "Column" for another loop

// End of column loop
EndCol: ADD     R4,R4,1         //Increment row #
        B       Row             // Go back to "Row" for another loop

// End of loops & function
EndIf:  POP     {R4-R11,PC}     // Restore R4-R11 (gives result)

	.end