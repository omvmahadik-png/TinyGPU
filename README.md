# TinyGPU

A 4-lane SIMD multiply-accumulate accelerator written in Verilog, attached as a memory-mapped peripheral to a PicoRV32 RISC-V core, and benchmarked against scalar CPU execution on dot product and matrix-vector multiplication.

## Overview

Four identical processing elements (PEs) execute the same operation on different data each cycle. A RISC-V program loads operand pairs into the accelerator through memory-mapped registers, triggers a step, polls a done flag, and reads back four accumulators. A per-lane mask lets individual lanes skip an update while the others proceed (predication, not full branch divergence).

## Architecture

```
RISC-V CPU (PicoRV32)
      |
 memory-mapped bus (address-decoded)
      |
  ------------------------------
  |          |                 |
 RAM       GPIO          TinyGPU (gpu_mmio)
                                |
                           scheduler
                                |
                            pe_array  <-- vector_mem (4 operand lanes)
                          /  |   |  \
                        PE0 PE1 PE2 PE3
```

| File | Role |
|---|---|
| `rtl/pe.v` | Signed 8x8 multiply-accumulate with 32-bit accumulator |
| `rtl/vector_mem.v` | Operand storage, all four lanes readable at once |
| `rtl/pe_array.v` | Four PEs with shared control and per-lane mask gating |
| `rtl/scheduler.v` | Turns a CPU trigger into one MAC step, latches `done` |
| `rtl/gpu_mmio.v` | Register interface (lane data, mask, start, clear, status, 4 results) |
| `rtl/top.v` | PicoRV32 + RAM + GPIO + GPU with address decoding |

Register map (base `0x20000000`): `0x00` lane data, `0x04` mask, `0x08` start, `0x0C` clear, `0x10` status, `0x14-0x20` accumulators 0-3.

## Results

RTL simulation in Icarus Verilog, cycle counts from PicoRV32's `rdcycle`.

| Benchmark | Scalar (cycles) | Accelerated (cycles) | Speedup |
|---|---:|---:|---:|
| Dot product (N=8) | 677 | 530 | 1.28x |
| Matrix-vector (4x8) | 2977 | 2277 | 1.31x |

Outputs match hand-computed values on both paths (dot product 62; matvec [62, 24, 6, 53]).

The speedup is modest because each 4-wide MAC takes one cycle, while the CPU spends many instructions per chunk loading operands, packing them into registers, writing the mask and trigger, and polling for completion. This is an inference from the instruction sequence, not a profiled breakdown.

### Caveats

- The scalar baseline uses PicoRV32's multi-cycle `mul` and an unoptimized, non-unrolled loop, so part of the gap comes from the multiplier and not only from parallelism.
- The accelerator uses 8-bit operands; the scalar path uses 32-bit. The test data fits in 8 bits, but the two are not equivalent in general.
- Per-lane masking was verified in a standalone scheduler test. The final benchmarks always use mask `1111`, so masking is not exercised in the integrated system.

## Hardware status

- The CPU + GPIO system and the standalone PE test were taken through Vivado to a bitstream for the Basys3 (xc7a35t). The CPU + GPIO design met timing at a 100 MHz clock constraint.
- The full accelerator system has only been simulated. It has not been synthesized, and nothing has been flashed to a board.

## Debugging notes

**Hex format mismatch.** `objcopy -O verilog` emits one byte per line, but `$readmemh` was loading into a 32-bit memory, so every instruction was misaligned and the CPU trapped. Found by comparing `objdump -d` against the hex file, then fixed by generating one 32-bit word per line.

**Testbench race condition.** PE results came out exactly doubled. The testbench changed `valid` at the same instant as the clock edge the DUT sampled on. Driving stimulus on `negedge clk` fixed it.

**Pulse vs. level signalling.** The CPU's poll loop hung because `done` was a one-cycle pulse and PicoRV32 takes several cycles per instruction, so it could miss it. `done` is now latched until the next operation starts.

## Known issue

In the GPU matvec firmware, PicoRV32 raises `trap` in the idle loop after all results and cycle counts have been stored. Results and measurements are unaffected. Changing the idle loop did not change when or where the trap fires, so the root cause is unresolved.

## Getting started

Clone with the submodule:

```bash
git clone --recurse-submodules https://github.com/omvmahadik-png/TinyGPU.git
cd TinyGPU
```

The simulation loads `firmware/firmware.hex`, so build a firmware image first (example: GPU matvec):

```bash
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 -o firmware/gpu_matvec.o firmware/gpu_matvec.s
riscv64-unknown-elf-ld -m elf32lriscv -Ttext=0x0 -o firmware/gpu_matvec.elf firmware/gpu_matvec.o
riscv64-unknown-elf-objcopy -O binary firmware/gpu_matvec.elf firmware/gpu_matvec.bin
xxd -e -g4 -c4 firmware/gpu_matvec.bin | awk '{print $2}' > firmware/firmware.hex
```

Then simulate:

```bash
iverilog -o sim.out -I rtl third_party/picorv32/picorv32.v rtl/*.v sim/gpu_matvec_tb.v
vvp sim.out
```

## Toolchain

Icarus Verilog, Vivado, RISC-V GCC (`riscv64-unknown-elf-*`), PicoRV32 (submodule), Digilent Basys3.
