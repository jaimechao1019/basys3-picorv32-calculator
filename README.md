# Basys3 PicoRV32 Calculator

This project implements a PicoRV32-based RISC-V SoC on the Basys3 FPGA board.

## Features

- PicoRV32 RISC-V softcore
- Memory-mapped I/O
- Switch input
- Button-controlled calculator
- LED output
- Four-digit seven-segment display

## Inputs

- SW[3:0]: A
- SW[7:4]: B

## Buttons

- BTNC: Addition
- BTNU: Subtraction
- BTNL: Multiplication
- BTNR: Division
- BTND: A > B comparison

## Output

- LED displays the raw result
- Seven-segment display shows the calculation result
- BTND displays 1 if A > B, otherwise 0
