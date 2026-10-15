`timescale 1ns / 1ps

module cycle_test_tb;

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
        $dumpfile("cycle_test_wave.vcd");
        $dumpvars(0, cycle_test_tb);

        resetn_btn = 1;
        repeat (10) @(posedge clk);
        resetn_btn = 0;

        repeat (5000) @(posedge clk);

        $display("trap = %b", uut.cpu.trap);
        $display("elapsed cycles (mem[0x100]) = %0d", uut.mem.mem[64]);

        $display("Simulation finished.");
        $finish;
    end

endmodule
