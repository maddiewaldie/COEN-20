/*
    This code was written to support the book, "ARM Assembly for Embedded Applications",
    by Daniel W. Lewis. Permission is granted to freely share this software provided
    that this notice is not removed. This software is intended to be used with a run-time
    library adapted by the author from the STM Cube Library for the 32F429IDISCOVERY 
    board and available for download from http://www.engr.scu.edu/~dlewis/book3.
*/

#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include "library.h"
#include "graphics.h"

#pragma GCC push_options
#pragma GCC optimize ("O0")

uint32_t __attribute__((weak)) ReverseBits(uint32_t word)
    {
    uint32_t reversed ;
    int bit ;

    reversed = 0 ;
    for (bit = 0; bit < 32; bit++)
        {
        if ((word & (1 << bit)) != 0)
            {
            reversed |= 1 << (31 - bit) ;
            }
        }

    return reversed ;
    }

uint32_t __attribute__((weak)) ReverseBytes(uint32_t word)
    {
    uint32_t reversed ;
    int byte ;

    reversed = 0 ;
    for (byte = 0; byte < 4; byte++)
        {
        ((uint8_t *) &reversed)[byte] = ((uint8_t *) &word)[3 - byte] ;
        }

    return reversed ;
    }

#pragma GCC pop_options

#define ENTRIES(a) (sizeof(a)/sizeof(a[0]))

#define CPU_CLOCK_MHZ   168
#define ROW_HEIGHT      14
#define BITS_ROW        60
#define BYTES_ROW       (BITS_ROW + 125)
#define BIT_WIDTH       7
#define BIT_HEIGHT      14
#define LABEL_COL       8

static void             Delay(uint32_t msec) ;
static void             LEDs(int grn_on, int red_on) ;
static void             PaintDisplay(int row) ;
static int              PutStringAt(int row, int col, char *fmt, ...) ;
static int              PutBinaryAt(int row, int col, uint32_t word, uint32_t verify) ;
static uint32_t         RBIT(uint32_t input) ;
static uint32_t         REV(uint32_t input) ;
static uint32_t         ROR(uint32_t input, uint32_t bits) ;

#pragma GCC push_options
#pragma GCC optimize ("O0")
int main(void)
    {
    uint32_t input, output[2], diff, ovhd, bytes, bits, verify ;
    int row, error ;

    InitializeHardware(HEADER, "Lab 7A: Reversing Bits & Bytes") ;
    ovhd = CountCycles(CallReturnOverhead, &input, &input, output) ;

    SetForeground(COLOR_BLACK) ;
    SetBackground(COLOR_WHITE) ;
    diff = CountCycles(ReverseBits, &input, &input, output) ;
    row = PutStringAt(BITS_ROW, LABEL_COL, "ReverseBits (%d clock cycles)", diff - ovhd) ;
    PaintDisplay(row) ;

    SetForeground(COLOR_BLACK) ;
    SetBackground(COLOR_WHITE) ;
    diff = CountCycles(ReverseBytes, &input, &input, output) ;
    row = PutStringAt(BYTES_ROW, LABEL_COL, "ReverseBytes (%d clock cycles)", diff - ovhd) ;
    PaintDisplay(row) ;

    bytes = 0x000000FF << 8*(GetRandomNumber() %  4) ;
    bits  = 0x00000001 << 1*(GetRandomNumber() % 32) ;
    SetForeground(COLOR_BLACK) ;
    SetBackground(COLOR_LIGHTYELLOW) ;
    LEDs(1, 0) ;
    while (1)
        {
        error = 0 ;

        row = PutStringAt(BITS_ROW + ROW_HEIGHT + 3, LABEL_COL, "Input (0x%08X):", bits) ;
        row = PutBinaryAt(row, LABEL_COL, bits, bits) + ROW_HEIGHT ;
        output[0] = ReverseBits(bits) ;
        verify = RBIT(bits) ;
        row = PutStringAt(row, LABEL_COL, "Output (0x%08X):", output[0]) ;
        if (PutBinaryAt(row, LABEL_COL, output[0], verify) == -1) error = 1 ;

        row = PutStringAt(BYTES_ROW + ROW_HEIGHT + 3, LABEL_COL, "Input (0x%08X):", bytes) ;
        row = PutBinaryAt(row, LABEL_COL, bytes, bytes) + ROW_HEIGHT ;
        output[0] = ReverseBytes(bytes) ;
        verify = REV(bytes) ;
        row = PutStringAt(row, LABEL_COL, "Output (0x%08X):", output[0]) ;
        if (PutBinaryAt(row, LABEL_COL, output[0], verify) == -1) error = 1 ;

        bits = ROR(bits, 1) ;
        bytes = ROR(bytes, 8) ;

        if (error) LEDs(0, 1) ;
        if (error) WaitForPushButton() ;
        else Delay(500) ;
        }

    return 0 ;
    }
#pragma GCC pop_options

static void PaintDisplay(int row)
    {
    DrawHLine(LABEL_COL, row, XPIXELS - 2*LABEL_COL) ;
    SetForeground(COLOR_LIGHTYELLOW) ;
    FillRect(LABEL_COL - 2, row, XPIXELS - 2*LABEL_COL + 4, 5 * ROW_HEIGHT + 12) ;
    SetForeground(COLOR_RED) ;
    DrawRect(LABEL_COL - 3, row - 1, XPIXELS - 2*LABEL_COL + 6, 5 * ROW_HEIGHT + 14) ;
    }

static void Delay(uint32_t msec)
    {
    uint32_t timeout = GetClockCycleCount() + 1000 * CPU_CLOCK_MHZ * msec ;
    while ((int) (timeout - GetClockCycleCount()) > 0) ;
    }

static int PutStringAt(int row, int col, char *fmt, ...)
    {
    va_list args ;
    char text[100] ;

    va_start(args, fmt) ;
    vsprintf(text, fmt, args) ;
    DisplayStringAt(col, row, text) ;
    va_end(args) ;
    return row + ROW_HEIGHT ;
    }

static int PutBinaryAt(int row, int col, uint32_t word, uint32_t verify)
    {
    int error = (word != verify) ;
    uint32_t bit1 = error ? COLOR_DARKRED : COLOR_DARKGREEN ;
    uint32_t bit0 = error ? COLOR_LIGHTRED : COLOR_LIGHTGREEN ;
    int bit ;

    for (bit = 31; bit >= 0; bit--)
        {
        SetForeground(((word & (1 << bit)) != 0) ? bit1 : bit0) ;
        FillRect(col, row, BIT_WIDTH, BIT_HEIGHT) ;
        SetForeground(COLOR_BLACK) ;
        DrawRect(col, row, BIT_WIDTH, BIT_HEIGHT) ;
        col += BIT_WIDTH ;
        }

    return !error ? (row + BIT_HEIGHT) : -1 ;
    }

static void LEDs(int grn_on, int red_on)
    {
    static uint32_t * const pGPIOG_MODER    = (uint32_t *) 0x40021800 ;
    static uint32_t * const pGPIOG_ODR      = (uint32_t *) 0x40021814 ;
    
    *pGPIOG_MODER |= (1 << 28) | (1 << 26) ;    // output mode
    *pGPIOG_ODR &= ~(3 << 13) ;         // both off
    *pGPIOG_ODR |= (grn_on ? 1 : 0) << 13 ;
    *pGPIOG_ODR |= (red_on ? 1 : 0) << 14 ;
    }

static uint32_t RBIT(uint32_t input)
    {
    uint32_t output ;

    asm(
        "   RBIT        %[output],%[input]  \n\t"
        :   [output]    "=r"    (output)
        :   [input]     "r"     (input)
    ) ;

    return output ;
    }

static uint32_t REV(uint32_t input)
    {
    uint32_t output ;

    asm(
        "   REV         %[output],%[input]  \n\t"
        :   [output]    "=r"    (output)
        :   [input]     "r"     (input)
    ) ;

    return output ;
    }

static uint32_t ROR(uint32_t input, uint32_t bits)
    {
    uint32_t output ;

    asm(
        "   ROR         %[output],%[input],%[bits]  \n\t"
        :   [output]    "=r"    (output)
        :   [input]     "r"     (input),
            [bits]      "r"     (bits)
    ) ;

    return output ;
    }
