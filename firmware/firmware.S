.section .text
.global main

main:
    lui  x5, 0x10000        # x5 = 0x10000000 input addr
    lui  x7, 0x10000
    addi x7, x7, 12         # x7 = 0x1000000C output addr

loop:
    lw   x6, 0(x5)          # read {btn, sw}

    andi x8, x6, 15         # A = sw[3:0]
    srli x9, x6, 4
    andi x9, x9, 15         # B = sw[7:4]

    srli x11, x6, 16        # btn = input[19:16]
    andi x11, x11, 15

    add  x10, x8, x9        # default: A+B

    andi x12, x11, 1
    bne  x12, x0, do_add

    srli x12, x11, 1
    andi x12, x12, 1
    bne  x12, x0, do_sub

    srli x12, x11, 2
    andi x12, x12, 1
    bne  x12, x0, do_mul

    srli x12, x11, 3
    andi x12, x12, 1
    bne  x12, x0, do_div

    jal  x0, output

do_add:
    add  x10, x8, x9
    jal  x0, output

do_sub:
    sub  x10, x8, x9
    jal  x0, output

do_mul:
    addi x10, x0, 0
    add  x13, x0, x9

mul_loop:
    beq  x13, x0, output
    add  x10, x10, x8
    addi x13, x13, -1
    jal  x0, mul_loop

do_div:
    beq  x9, x0, div_zero
    addi x10, x0, 0
    add  x13, x0, x8

div_loop:
    blt  x13, x9, output
    sub  x13, x13, x9
    addi x10, x10, 1
    jal  x0, div_loop

div_zero:
    addi x10, x0, 0

output:
    sw   x10, 0(x7)
    jal  x0, loop
