.section .text
.global _start

_start:
    li   x11, 0x220      # x (vector)
    li   x30, 0x400      # M (matrix base)
    li   x31, 0x500      # y (output base)

    # Store x
    li   x2, 1
    sw   x2, 0(x11)
    sw   x2, 4(x11)
    sw   x2, 8(x11)
    sw   x2, 12(x11)
    li   x2, 2
    sw   x2, 16(x11)
    sw   x2, 20(x11)
    sw   x2, 24(x11)
    sw   x2, 28(x11)

    # Store M row 0: 1,2,3,4,5,6,7,8
    li   x2, 1
    sw   x2, 0(x30)
    li   x2, 2
    sw   x2, 4(x30)
    li   x2, 3
    sw   x2, 8(x30)
    li   x2, 4
    sw   x2, 12(x30)
    li   x2, 5
    sw   x2, 16(x30)
    li   x2, 6
    sw   x2, 20(x30)
    li   x2, 7
    sw   x2, 24(x30)
    li   x2, 8
    sw   x2, 28(x30)

    # Row 1: all 2s
    li   x2, 2
    sw   x2, 32(x30)
    sw   x2, 36(x30)
    sw   x2, 40(x30)
    sw   x2, 44(x30)
    sw   x2, 48(x30)
    sw   x2, 52(x30)
    sw   x2, 56(x30)
    sw   x2, 60(x30)

    # Row 2: 1,0,1,0,1,0,1,0
    li   x2, 1
    sw   x2, 64(x30)
    li   x2, 0
    sw   x2, 68(x30)
    li   x2, 1
    sw   x2, 72(x30)
    li   x2, 0
    sw   x2, 76(x30)
    li   x2, 1
    sw   x2, 80(x30)
    li   x2, 0
    sw   x2, 84(x30)
    li   x2, 1
    sw   x2, 88(x30)
    li   x2, 0
    sw   x2, 92(x30)

    # Row 3: 3,1,4,1,5,9,2,6
    li   x2, 3
    sw   x2, 96(x30)
    li   x2, 1
    sw   x2, 100(x30)
    li   x2, 4
    sw   x2, 104(x30)
    li   x2, 1
    sw   x2, 108(x30)
    li   x2, 5
    sw   x2, 112(x30)
    li   x2, 9
    sw   x2, 116(x30)
    li   x2, 2
    sw   x2, 120(x30)
    li   x2, 6
    sw   x2, 124(x30)

    # --- Start timing ---
    rdcycle x20

    li   x12, 0          # row = 0
row_loop:
    slli x5, x12, 5       # row * 32 bytes = row offset in M
    add  x6, x30, x5      # address of M[row][0]

    li   x13, 0           # j = 0
    li   x14, 0           # acc = 0
inner_loop:
    slli x15, x13, 2
    add  x16, x6, x15     # &M[row][j]
    add  x17, x11, x15    # &x[j]
    lw   x18, 0(x16)
    lw   x19, 0(x17)
    mul  x21, x18, x19
    add  x14, x14, x21
    addi x13, x13, 1
    li   x7, 8
    bne  x13, x7, inner_loop

    slli x8, x12, 2
    add  x9, x31, x8
    sw   x14, 0(x9)       # y[row] = acc

    addi x12, x12, 1
    li   x7, 4
    bne  x12, x7, row_loop

    # --- End timing ---
    rdcycle x22
    sub  x23, x22, x20
    li   x24, 0x600
    sw   x23, 0(x24)      # elapsed cycles

done_loop:
    j done_loop
