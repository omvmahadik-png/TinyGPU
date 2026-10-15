.section .text
.global _start

_start:
    lui  x1, 0x10000        # x1 = 0x10000000 (GPIO base address)
    li   x2, 0xAA           # x2 = value to write (LED pattern)
    sw   x2, 0(x1)          # store x2 to GPIO -> should light LEDs

loop:
    j    loop
