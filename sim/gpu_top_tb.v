`timescale 1ns / 1ps

module gpu_top_tb;

    reg clk = 0;
    reg resetn = 0;
    reg start = 0;

    wire signed [31:0] acc0, acc1, acc2, acc3;
    wire busy, done;

    always #5 clk = ~clk;

    gpu_top uut (
        .clk    (clk),
        .resetn (resetn),
        .start  (start),
        .acc0   (acc0),
        .acc1   (acc1),
        .acc2   (acc2),
        .acc3   (acc3),
        .busy   (busy),
        .done   (done)
    );

    initial begin
        $dumpfile("gpu_top_wave.vcd");
        $dumpvars(0, gpu_top_tb);

        resetn = 0;
        repeat (2) @(negedge clk);
        resetn = 1;
        @(negedge clk);

        // Kick off the hardcoded 4-step program
        start = 1;
        @(negedge clk);
        start = 0;

        // Wait for done to pulse (poll busy going low, generous timeout)
        wait (done == 1);
        @(negedge clk);

        $display("acc0 = %0d (expected 28)", acc0);
        $display("acc1 = %0d (expected 34)", acc1);
        $display("acc2 = %0d (expected 44)", acc2);
        $display("acc3 = %0d (expected 33) <- proves masking worked (would be 58 if broken)", acc3);

        $display("Simulation finished.");
        $finish;
    end

    // Safety timeout in case done never fires (avoids hanging forever)
    initial begin
        #2000;
        $display("TIMEOUT: done never asserted - check scheduler FSM");
        $finish;
    end

endmodule
