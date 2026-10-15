.section .text
.global _start

_start:
    li   x11, 0x220      # x (vector)
    li   x30, 0x400      # M (matrix base)
    li   x31, 0x500      # y (output base)

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

    li   x2, 2
    sw   x2, 32(x30)
    sw   x2, 36(x30)
    sw   x2, 40(x30)
    sw   x2, 44(x30)
    sw   x2, 48(x30)
    sw   x2, 52(x30)
    sw   x2, 56(x30)
    sw   x2, 60(x30)

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

    lui  x1, 0x20000      # GPU base

    # --- Start timing ---
    rdcycle x20

    li   x12, 0           # row = 0
row_loop:
    slli x5, x12, 5
    add  x6, x30, x5       # &M[row][0]

    li   x2, 1
    sw   x2, 0xC(x1)       # CLEAR (per row)

    li   x25, 0            # chunk = 0
chunk_loop:
    slli x26, x25, 4
    add  x27, x6, x26      # &M[row][chunk*4]
    add  x28, x11, x26     # &x[chunk*4]

    lw   x3, 0(x27)
    lw   x4, 0(x28)
    slli x15, x4, 10
    slli x16, x3, 2
    or   x7, x15, x16
    ori  x7, x7, 0
    sw   x7, 0(x1)

    lw   x3, 4(x27)
    lw   x4, 4(x28)
    slli x15, x4, 10
    slli x16, x3, 2
    or   x7, x15, x16
    ori  x7, x7, 1
    sw   x7, 0(x1)

    lw   x3, 8(x27)
    lw   x4, 8(x28)
    slli x15, x4, 10
    slli x16, x3, 2
    or   x7, x15, x16
    ori  x7, x7, 2
    sw   x7, 0(x1)

    lw   x3, 12(x27)
    lw   x4, 12(x28)
    slli x15, x4, 10
    slli x16, x3, 2
    or   x7, x15, x16
    ori  x7, x7, 3
    sw   x7, 0(x1)

    li   x2, 0xF
    sw   x2, 4(x1)

    li   x2, 1
    sw   x2, 8(x1)

poll_loop:
    lw   x8, 0x10(x1)
    andi x9, x8, 2
    beqz x9, poll_loop

    addi x25, x25, 1
    li   x29, 2
    bne  x25, x29, chunk_loop

    lw   x13, 0x14(x1)
    lw   x14, 0x18(x1)
    lw   x17, 0x1C(x1)
    lw   x19, 0x20(x1)

    add  x13, x13, x14
    add  x13, x13, x17
    add  x13, x13, x19

    slli x18, x12, 2
    add  x9, x31, x18
    sw   x13, 0(x9)        # y[row]

    addi x12, x12, 1
    li   x29, 4
    bne  x12, x29, row_loop

    # --- End timing ---
    rdcycle x22
    sub  x23, x22, x20
    li   x24, 0x600
    sw   x23, 0(x24)

done_loop:
    li   x5, 1000
spin:
    addi x5, x5, -1
    bnez x5, spin
    j    done_loop
