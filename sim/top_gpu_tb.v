`timescale 1ns / 1ps

module top_gpu_tb;

    reg clk = 0;
    reg resetn_btn = 1;
    wire [15:0] led;

    always #5 clk = ~clk;

    top uut (
        .clk        (clk),
        .resetn_btn (resetn_btn),
        .led        (led)
    );

    initial begin
        $dumpfile("top_gpu_wave.vcd");
        $dumpvars(0, top_gpu_tb);

        resetn_btn = 1;
        repeat (10) @(posedge clk);
        resetn_btn = 0;

        repeat (2000) @(posedge clk);

        $display("trap = %b", uut.cpu.trap);
        $display("mem_addr (final) = %h", uut.mem_addr);
        $display("acc0 (mem[0x100]) = %0d (expected 6)",   $signed(uut.mem.mem[64]));
        $display("acc1 (mem[0x104]) = %0d (expected -20)", $signed(uut.mem.mem[65]));
        $display("acc2 (mem[0x108]) = %0d (expected -14)", $signed(uut.mem.mem[66]));
        $display("acc3 (mem[0x10C]) = %0d (expected 100)", $signed(uut.mem.mem[67]));

        $display("Simulation finished.");
        $finish;
    end

endmodule
