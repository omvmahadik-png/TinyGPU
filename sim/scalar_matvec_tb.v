`timescale 1ns / 1ps

module scalar_matvec_tb;

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
        $dumpfile("scalar_matvec_wave.vcd");
        $dumpvars(0, scalar_matvec_tb);

        resetn_btn = 1;
        repeat (10) @(posedge clk);
        resetn_btn = 0;

        repeat (20000) @(posedge clk);

        $display("trap = %b", uut.cpu.trap);
        $display("y[0] (mem[0x500]) = %0d (expected 62)", uut.mem.mem[320]);
        $display("y[1] (mem[0x504]) = %0d (expected 24)", uut.mem.mem[321]);
        $display("y[2] (mem[0x508]) = %0d (expected 6)",  uut.mem.mem[322]);
        $display("y[3] (mem[0x50C]) = %0d (expected 53)", uut.mem.mem[323]);
        $display("elapsed cycles (mem[0x600]) = %0d", uut.mem.mem[384]);

        $display("Simulation finished.");
        $finish;
    end

endmodule
