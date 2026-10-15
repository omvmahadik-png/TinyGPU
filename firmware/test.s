.section .text
.global _start

_start:
    li   x1, 5          # x1 = 5
    li   x2, 7          # x2 = 7
    add  x3, x1, x2     # x3 = x1 + x2 = 12
    sw   x3, 0(x0)      # store x3 to memory address 0

loop:
    j    loop           # infinite loop, halt here
