.section .text
.global _start

_start:
    li   x10, 0x200      # base address of A (reuse same test vectors as scalar version)
    li   x11, 0x220      # base address of B

    # Store test vectors (same as scalar_dot.s)
    li   x2, 1
    sw   x2, 0(x10)
    li   x2, 2
    sw   x2, 4(x10)
    li   x2, 3
    sw   x2, 8(x10)
    li   x2, 4
    sw   x2, 12(x10)
    li   x2, 5
    sw   x2, 16(x10)
    li   x2, 6
    sw   x2, 20(x10)
    li   x2, 7
    sw   x2, 24(x10)
    li   x2, 8
    sw   x2, 28(x10)

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

    lui  x1, 0x20000      # x1 = GPU base address

    # --- Start timing ---
    rdcycle x20

    # Clear accumulators once
    li   x2, 1
    sw   x2, 0xC(x1)      # CLEAR

    li   x25, 0           # chunk = 0

chunk_loop:
    slli x26, x25, 4      # chunk * 16 bytes (4 elements * 4 bytes) = offset into A/B for this chunk
    add  x27, x10, x26    # address of A[chunk*4]
    add  x28, x11, x26    # address of B[chunk*4]

    # --- lane 0 ---
    lw   x3, 0(x27)       # a
    lw   x4, 0(x28)       # b
    slli x5, x4, 10
    slli x6, x3, 2
    or   x7, x5, x6
    ori  x7, x7, 0
    sw   x7, 0(x1)        # LANE_DATA, idx=0

    # --- lane 1 ---
    lw   x3, 4(x27)
    lw   x4, 4(x28)
    slli x5, x4, 10
    slli x6, x3, 2
    or   x7, x5, x6
    ori  x7, x7, 1
    sw   x7, 0(x1)

    # --- lane 2 ---
    lw   x3, 8(x27)
    lw   x4, 8(x28)
    slli x5, x4, 10
    slli x6, x3, 2
    or   x7, x5, x6
    ori  x7, x7, 2
    sw   x7, 0(x1)

    # --- lane 3 ---
    lw   x3, 12(x27)
    lw   x4, 12(x28)
    slli x5, x4, 10
    slli x6, x3, 2
    or   x7, x5, x6
    ori  x7, x7, 3
    sw   x7, 0(x1)

    # mask = 1111
    li   x2, 0xF
    sw   x2, 4(x1)        # MASK

    # trigger start
    li   x2, 1
    sw   x2, 8(x1)        # START

poll_loop:
    lw   x8, 0x10(x1)     # STATUS
    andi x9, x8, 2
    beqz x9, poll_loop

    addi x25, x25, 1
    li   x29, 2
    bne  x25, x29, chunk_loop

    # --- Read final accumulators and sum ---
    lw   x13, 0x14(x1)    # acc0
    lw   x14, 0x18(x1)    # acc1
    lw   x15, 0x1C(x1)    # acc2
    lw   x16, 0x20(x1)    # acc3

    add  x17, x13, x14
    add  x17, x17, x15
    add  x17, x17, x16    # x17 = total dot product

    # --- End timing ---
    rdcycle x22
    sub  x23, x22, x20

    li   x24, 0x300
    sw   x17, 0(x24)      # result
    sw   x23, 4(x24)      # elapsed cycles

done_loop:
    j done_loop
