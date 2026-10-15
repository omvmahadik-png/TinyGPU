.section .text
.global _start

_start:
    lui  x1, 0x20000          # x1 = 0x20000000 (GPU base)

    # --- Clear accumulators first ---
    li   x2, 1
    sw   x2, 0xC(x1)          # write to CLEAR

    # --- Load lane 0: a=2, b=3 ---
    # packed value = (b<<10) | (a<<2) | idx
    li   x2, (3 << 10) | (2 << 2) | 0
    sw   x2, 0(x1)            # write to LANE_DATA

    # --- Load lane 1: a=-4, b=5 ---
    # -4 as 8-bit signed = 0xFC = 252
    li   x2, (5 << 10) | (252 << 2) | 1
    sw   x2, 0(x1)

    # --- Load lane 2: a=7, b=-2 ---
    # -2 as 8-bit signed = 0xFE = 254
    li   x2, (254 << 10) | (7 << 2) | 2
    sw   x2, 0(x1)

    # --- Load lane 3: a=10, b=10 ---
    li   x2, (10 << 10) | (10 << 2) | 3
    sw   x2, 0(x1)

    # --- Set mask = 1111 (all lanes active) ---
    li   x2, 0xF
    sw   x2, 4(x1)            # write to MASK

    # --- Trigger start ---
    li   x2, 1
    sw   x2, 8(x1)            # write to START

poll_loop:
    lw   x3, 0x10(x1)         # read STATUS
    andi x4, x3, 2            # check done bit
    beqz x4, poll_loop

    # --- Read results into registers for inspection ---
    lw   x5, 0x14(x1)         # acc0 -> x5
    lw   x6, 0x18(x1)         # acc1 -> x6
    lw   x7, 0x1C(x1)         # acc2 -> x7
    lw   x8, 0x20(x1)         # acc3 -> x8

    # --- Store results to RAM at 0x100, 0x104, 0x108, 0x10C for waveform inspection ---
    li   x9, 0x100
    sw   x5, 0(x9)
    sw   x6, 4(x9)
    sw   x7, 8(x9)
    sw   x8, 12(x9)

done_loop:
    j    done_loop
