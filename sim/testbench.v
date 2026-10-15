`timescale 1ns / 1ps

module testbench;

    reg clk = 0;
    reg resetn_btn = 1;   // active-high: 1 = reset asserted, 0 = released
    wire [15:0] led;

    // 100MHz-ish clock: toggle every 5ns -> 10ns period
    always #5 clk = ~clk;

    top uut (
        .clk        (clk),
        .resetn_btn (resetn_btn),
        .led        (led)
    );

    initial begin
        // Dump waveform for GTKWave
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);

        // Hold reset asserted for a few cycles, then release
        resetn_btn = 1;
        repeat (10) @(posedge clk);
        resetn_btn = 0;

        // Let the CPU run for a while
        repeat (500) @(posedge clk);

        $display("Simulation finished.");
        $finish;
    end

endmodule
