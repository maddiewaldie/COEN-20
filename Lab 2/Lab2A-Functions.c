/* 
 * COEN 20 Lab #1
 * Author: Madeleine Waldie
 * Due Date: 10/14/21
 * 
 * Implement the 4 functions below
 *      Note: Each array parameter holds an 8-bit binary number, 
 *      b7b6b5b4b3b2b1𝑏0, where bits[7] = 𝑏7 and bits[0] = 𝑏0.
 */

// Includes
#include <stdint.h> // Library to use C99 unsigned/signed integer data types
#include "math.h" // Library needed for "pow" function used in Bits2Unsigned

 // Converts array of bits to an unsigned integer
 uint32_t Bits2Unsigned(int8_t bits[8]) {
	 // Converted array to return
	 // Initialize array to the unsigned (positive) value
	uint32_t bitsAsInt = 0;

	// Variable to keep track of value of bits in for loop
	uint32_t bitValue = 0;

	// Loop through the bits in the array
	for(int i = 0; i < 8; i++) {
		// Calculate the decimal value from the bits
		if(bits[i] == 1) {
			// Depending on placement of bit, calculate bit value
			bitValue = pow(2, i);
		}
		else {
			// If bit isn't a 1, then its value is a 0
			bitValue = 0;
		}

		// Add bit value onto whole value
		bitsAsInt = bitsAsInt + bitValue;
	}

	// Return unsigned representation of bits
	return bitsAsInt;
 }
 
 // Convert array of bits to signed int
int32_t Bits2Signed(int8_t bits[8]) {
	// Converted array to return
	int32_t bitsAsInt = 0;

	// Initialize array to the unsigned (positive) value
	bitsAsInt = Bits2Unsigned(bits);

	// Determine if number is positive or negative
	if(bits[7] == 1) { // Number is negative
		// Subtract 256 from unsigned (positive) value
		bitsAsInt = bitsAsInt - 256;
	}
	// Else: Number is positive, and the unsigned value will be the same as the unsigned representation

	// Return signed representation of bits
	return bitsAsInt;
}
 
// Add 1 to value represented by bit pattern
void Increment(int8_t bits[8]) {
	// Loop through the bits in the array
	for(int i = 0; i < 8; i++) {
		// Check whether the bit is a 1 or 0
		if(bits[i] == 1) {
			// Bit is a 1, so incrementing will carry over and make this a 0
			bits[i] = 0;
		}
		else {
			// Add 1 to 0 to make the bit 1
			bits[i] = 1;
			
			// Don't need to increment any further
			break;
		}
	}
}

// Opposite of Bits2Unsigned - convert unsigned int to bits
 void Unsigned2Bits(uint32_t n, int8_t bits[8]) {
	// Initialize number that will be modified in for loop
	 int number = n;

	// Loop through the bits in the array
	 for(int i = 0; i < 8; i++) {

		// Repeated division - check if number is divisible by 2 & get the remainder
		int remainder = number % 2; 

		// Repeated division - get the whole number (to be used in the next loop)
		number = number / 2;
		
		// Depending on the remainder, make bit a 1 or 0
		if (remainder == 1) {
			// Whole number, so bit representation at i is 1
			bits[i] = 1;
		}
		else {
			// Not a whole number, so bit representation at i is 0
			bits[i] = 0;
		}
	 }
 }