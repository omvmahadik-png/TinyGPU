`timescale 1ns / 1ps

module pe_top_tb;

    reg clk = 0;
    reg resetn_btn = 1;
    reg [15:0] sw = 0;
    reg btnC = 0;
    reg btnU = 0;
    reg btnD = 0;
    wire [15:0] led;

    always #5 clk = ~clk;

    pe_top uut (
        .clk        (clk),
        .resetn_btn (resetn_btn),
        .sw         (sw),
        .btnC       (btnC),
        .btnU       (btnU),
        .btnD       (btnD),
        .led        (led)
    );

    initial begin
        $dumpfile("pe_top_wave.vcd");
        $dumpvars(0, pe_top_tb);

        resetn_btn = 1;
        repeat (2) @(negedge clk);
        resetn_btn = 0;
        @(negedge clk);

        // Set a=3, b=4, "press" btnC for several cycles (simulating a long human press)
        sw = {8'd4, 8'd3};  // sw[15:8]=b=4, sw[7:0]=a=3
        @(negedge clk);
        btnC = 1;
        repeat (20) @(negedge clk);  // hold button "pressed" for 20 cycles - should still only MAC once
        btnC = 0;
        repeat (2) @(negedge clk);

        $display("Test 1 (long btnC press, 3*4): led (lower) = %0d (expected 12)", led);

        // Clear
        btnU = 1;
        repeat (5) @(negedge clk);
        btnU = 0;
        repeat (2) @(negedge clk);
        $display("Test 2 (after btnU clear): led (lower) = %0d (expected 0)", led);

        // Negative test: a=-5, b=3
        sw = {8'd3, -8'sd5};
        @(negedge clk);
        btnC = 1;
        @(negedge clk);
        btnC = 0;
        repeat (2) @(negedge clk);
        $display("Test 3 (-5*3): led (lower) = %0d (expected -15, shown as unsigned 65521 on 16-bit LEDs)", led);

        // Check upper bits view with btnD
        btnD = 1;
        @(negedge clk);
        $display("Test 4 (btnD held, upper bits): led (upper) = %0d (expected 65535 = all 1s, since result is negative/sign-extended)", led);

        $display("Simulation finished.");
        $finish;
    end

endmodule
