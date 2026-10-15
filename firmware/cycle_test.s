.section .text
.global _start

_start:
    rdcycle x1          # x1 = cycle count at start

    li   x2, 0
    li   x3, 100
count_loop:
    addi x2, x2, 1
    bne  x2, x3, count_loop

    rdcycle x4          # x4 = cycle count after loop
    sub  x5, x4, x1      # x5 = elapsed cycles

    li   x6, 0x100
    sw   x5, 0(x6)        # store elapsed cycle count to RAM for inspection

done_loop:
    j done_loop
