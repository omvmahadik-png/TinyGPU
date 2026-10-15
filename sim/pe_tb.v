`timescale 1ns / 1ps

module pe_tb;

    reg clk = 0;
    reg resetn = 0;
    reg signed [7:0] a = 0;
    reg signed [7:0] b = 0;
    reg valid = 0;
    reg clear_acc = 0;
    wire signed [31:0] acc;

    always #5 clk = ~clk;

    pe uut (
        .clk       (clk),
        .resetn    (resetn),
        .a         (a),
        .b         (b),
        .valid     (valid),
        .clear_acc (clear_acc),
        .acc       (acc)
    );

    // Helper task: apply one MAC step safely, away from the posedge race
    task do_mac(input signed [7:0] in_a, input signed [7:0] in_b);
        begin
            @(negedge clk);
            a = in_a;
            b = in_b;
            valid = 1;
            @(negedge clk);
            valid = 0;
        end
    endtask

    task do_clear;
        begin
            @(negedge clk);
            clear_acc = 1;
            @(negedge clk);
            clear_acc = 0;
        end
    endtask

    initial begin
        $dumpfile("pe_wave.vcd");
        $dumpvars(0, pe_tb);

        resetn = 0;
        repeat (2) @(negedge clk);
        resetn = 1;
        @(negedge clk);

        do_mac(3, 4);
        $display("Test 1 (3*4): acc = %0d (expected 12)", acc);

        do_mac(-5, 3);
        $display("Test 2 (-5*3 accumulated): acc = %0d (expected -3)", acc);

        do_clear;
        $display("Test 3 (after clear_acc): acc = %0d (expected 0)", acc);

        do_mac(-5, 3);
        $display("Test 4 (-5*3 from zero): acc = %0d (expected -15)", acc);

        $display("Simulation finished.");
        $finish;
    end

endmodule
