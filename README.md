# TinyGPU

A small SIMD accelerator built from scratch in Verilog, integrated into a RISC-V system-on-chip, and benchmarked against scalar CPU execution on dot product and matrix-vector multiplication.

## What this is

TinyGPU is a 4-lane SIMD processing array — four identical multiply-accumulate units executing the same instruction on different data each cycle — wired as a memory-mapped peripheral on a RISC-V core (PicoRV32). A RISC-V C/assembly program writes vector data into the accelerator, triggers computation, polls for completion, and reads back results, the same way it would drive any other peripheral.

The project also implements a per-lane masking mechanism, letting individual lanes skip an operation while others proceed under the same instruction stream — a small-scale version of how real GPUs handle branch divergence across SIMT threads.

## Architecture


cat > README.md << 'EOF'
# TinyGPU

A small SIMD accelerator built from scratch in Verilog, integrated into a RISC-V system-on-chip, and benchmarked against scalar CPU execution on dot product and matrix-vector multiplication.

## What this is

TinyGPU is a 4-lane SIMD processing array — four identical multiply-accumulate units executing the same instruction on different data each cycle — wired as a memory-mapped peripheral on a RISC-V core (PicoRV32). A RISC-V C/assembly program writes vector data into the accelerator, triggers computation, polls for completion, and reads back results, the same way it would drive any other peripheral.

The project also implements a per-lane masking mechanism, letting individual lanes skip an operation while others proceed under the same instruction stream — a small-scale version of how real GPUs handle branch divergence across SIMT threads.

## Architecture



cat > README.md << 'EOF'
# TinyGPU

A small SIMD accelerator built from scratch in Verilog, integrated into a RISC-V system-on-chip, and benchmarked against scalar CPU execution on dot product and matrix-vector multiplication.

## What this is

TinyGPU is a 4-lane SIMD processing array — four identical multiply-accumulate units executing the same instruction on different data each cycle — wired as a memory-mapped peripheral on a RISC-V core (PicoRV32). A RISC-V C/assembly program writes vector data into the accelerator, triggers computation, polls for completion, and reads back results, the same way it would drive any other peripheral.

The project also implements a per-lane masking mechanism, letting individual lanes skip an operation while others proceed under the same instruction stream — a small-scale version of how real GPUs handle branch divergence across SIMT threads.

## Architecture


cat > README.md << 'EOF'
# TinyGPU

A small SIMD accelerator built from scratch in Verilog, integrated into a RISC-V system-on-chip, and benchmarked against scalar CPU execution on dot product and matrix-vector multiplication.

## What this is

TinyGPU is a 4-lane SIMD processing array — four identical multiply-accumulate units executing the same instruction on different data each cycle — wired as a memory-mapped peripheral on a RISC-V core (PicoRV32). A RISC-V C/assembly program writes vector data into the accelerator, triggers computation, polls for completion, and reads back results, the same way it would drive any other peripheral.

The project also implements a per-lane masking mechanism, letting individual lanes skip an operation while others proceed under the same instruction stream — a small-scale version of how real GPUs handle branch divergence across SIMT threads.

## Architecture




- **`pe.v`** — single processing element: signed 8×8 multiply-accumulate
- **`vector_mem.v`** — shared operand storage, 4 independently-addressable lanes
- **`pe_array.v`** — 4 PEs wired to shared memory, with per-lane mask gating
- **`scheduler.v`** — sequences a MAC step on trigger, reports busy/done
- **`gpu_mmio.v`** — memory-mapped register interface (write operands, set mask, trigger, poll status, read results)
- **`top.v`** — full system integration: PicoRV32 + RAM + GPIO + TinyGPU, address-decoded onto one bus

## Results

Benchmarked on a cycle-accurate RTL simulation (Icarus Verilog + Vivado XSim, cross-validated on both toolchains), synthesized and implemented for the Basys3 (Artix-7 xc7a35t).

| Benchmark | Scalar RISC-V (cycles) | TinyGPU-accelerated (cycles) | Speedup |
|---|---:|---:|---:|
| Dot product (N=8) | 677 | 530 | 1.28x |
| Matrix-vector multiply (4×8) | 2977 | 2277 | 1.31x |

All results independently verified correct against hand-computed expected values on both the scalar and accelerated paths.

### Why the speedup is ~1.3x, not ~4x

The 4 PE lanes compute in true parallel — a full 4-wide multiply-accumulate step costs 1 clock cycle. But at this problem size, that 1-cycle compute is dwarfed by the RISC-V control overhead surrounding each step: loading operands from RAM, packing and writing them to the accelerator's registers, setting the mask, triggering, and polling for completion — all done as individual RISC-V instructions. The bottleneck here is data movement and control, not compute, which is a genuine and common finding in real accelerator design, not a project shortcoming. A larger vector length would amortize this per-chunk overhead better; a wider memory interface (writing multiple lanes per CPU cycle instead of one at a time) would be the natural next optimization.

## Debugging notes

A few bugs worth documenting, since they were the most instructive part of the build:

**Hex-format mismatch (Phase 0).** `objcopy -O verilog` emits one byte per line by default; `$readmemh` was loading those bytes into a 32-bit-wide memory array, misaligning every instruction. Diagnosed by comparing `objdump -d` output against the raw `.hex` file line-by-line, rather than trusting that "the simulation ran without errors" meant it was correct.

**Testbench race condition (Phase 1).** A PE's MAC results came out exactly double what was expected. Cause: testbench signals were changed on the same simulation instant as the clock edge the DUT sampled on (`@(posedge clk); valid = 0;`), creating a race that sometimes double-triggered the operation. Fixed by driving all testbench stimulus on `negedge clk` instead, well clear of the DUT's sampling edge.

**Pulse-vs-level signaling bug (Phase 4).** After wiring the accelerator to the CPU, the poll loop hung indefinitely even though the accelerator had genuinely finished. Cause: the scheduler's `done` signal was a single-cycle pulse, but PicoRV32 takes several clock cycles per instruction — so the CPU's poll loop would sometimes check `done` in the gap between pulses and never catch it high. Fixed by latching `done` as a level signal that persists until the next operation starts, rather than pulsing and immediately clearing every cycle.

## Toolchain

- Verilog: Icarus Verilog (simulation) + Vivado (synthesis, implementation, hardware)
- RISC-V core: [PicoRV32](https://github.com/YosysHQ/picorv32) (submodule)
- Firmware: RISC-V GCC toolchain (`riscv64-unknown-elf-*`), hand-written RV32IM assembly
- Target board: Digilent Basys3 (Xilinx Artix-7, xc7a35tcpg236-1)

## Repository structure

## Building and running

Simulation (Icarus Verilog):
```bash
iverilog -o sim.out -I rtl third_party/picorv32/picorv32.v rtl/*.v sim/<testbench>.v
vvp sim.out
```

Hardware (Vivado): add all `rtl/*.v` and `third_party/picorv32/picorv32.v` as design sources, add `constraints/basys3.xdc`, set `top` as the top module, run Synthesis → Implementation → Generate Bitstream.

## Getting started

Clone with the submodule:
```bash
git clone --recurse-submodules https://github.com/omvmahadik-png/TinyGPU.git
cd TinyGPU
```

Build a firmware image (example: GPU matvec benchmark). The simulation loads `firmware/firmware.hex`, so this step is required before running any testbench:
```bash
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 -o firmware/gpu_matvec.o firmware/gpu_matvec.s
riscv64-unknown-elf-ld -m elf32lriscv -Ttext=0x0 -o firmware/gpu_matvec.elf firmware/gpu_matvec.o
riscv64-unknown-elf-objcopy -O binary firmware/gpu_matvec.elf firmware/gpu_matvec.bin
xxd -e -g4 -c4 firmware/gpu_matvec.bin | awk '{print $2}' > firmware/firmware.hex
```

## Known issue

In the GPU matvec firmware, PicoRV32 raises `trap` in the idle loop after all results and cycle counts have been computed and stored. Results and measurements are unaffected, since they are captured before the trap. Root cause not yet identified.
