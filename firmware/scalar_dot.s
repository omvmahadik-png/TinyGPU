.section .text
.global _start

_start:
    # Vector A at RAM 0x200, Vector B at RAM 0x220 (8 words each, spaced safely apart)
    li   x10, 0x200      # base address of A
    li   x11, 0x220      # base address of B

    # Store test vectors into RAM first
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

    # --- Start timing ---
    rdcycle x20

    li   x12, 0          # i = 0
    li   x13, 0          # acc = 0
    li   x14, 8          # N = 8

dot_loop:
    slli x15, x12, 2     # x15 = i*4 (byte offset)
    add  x16, x10, x15   # address of A[i]
    add  x17, x11, x15   # address of B[i]
    lw   x18, 0(x16)     # x18 = A[i]
    lw   x19, 0(x17)     # x19 = B[i]
    mul  x21, x18, x19   # x21 = A[i]*B[i]
    add  x13, x13, x21   # acc += product

    addi x12, x12, 1
    bne  x12, x14, dot_loop

    # --- End timing ---
    rdcycle x22
    sub  x23, x22, x20   # elapsed cycles

    # Store result and cycle count
    li   x24, 0x300
    sw   x13, 0(x24)     # dot product result
    sw   x23, 4(x24)     # elapsed cycles

done_loop:
    j done_loop
