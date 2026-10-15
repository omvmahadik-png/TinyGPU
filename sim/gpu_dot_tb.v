`timescale 1ns / 1ps

module gpu_dot_tb;

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
        $dumpfile("gpu_dot_wave.vcd");
        $dumpvars(0, gpu_dot_tb);

        resetn_btn = 1;
        repeat (10) @(posedge clk);
        resetn_btn = 0;

        repeat (5000) @(posedge clk);

        $display("trap = %b", uut.cpu.trap);
        $display("GPU dot product result (mem[0x300]) = %0d (expected 62)", uut.mem.mem[192]);
        $display("elapsed cycles (mem[0x304]) = %0d", uut.mem.mem[193]);

        $display("Simulation finished.");
        $finish;
    end

endmodule
