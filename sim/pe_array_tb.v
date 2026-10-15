`timescale 1ns / 1ps

module pe_array_tb;

    reg clk = 0;
    reg resetn = 0;
    reg wr_en = 0;
    reg [1:0] wr_idx = 0;
    reg signed [7:0] wr_a = 0;
    reg signed [7:0] wr_b = 0;
    reg valid = 0;
    reg clear_acc = 0;

    wire signed [31:0] acc0, acc1, acc2, acc3;

    always #5 clk = ~clk;

    pe_array uut (
        .clk       (clk),
        .resetn    (resetn),
        .wr_en     (wr_en),
        .wr_idx    (wr_idx),
        .wr_a      (wr_a),
        .wr_b      (wr_b),
        .valid     (valid),
        .clear_acc (clear_acc),
        .acc0      (acc0),
        .acc1      (acc1),
        .acc2      (acc2),
        .acc3      (acc3)
    );

    task load_lane(input [1:0] idx, input signed [7:0] in_a, input signed [7:0] in_b);
        begin
            @(negedge clk);
            wr_idx = idx;
            wr_a   = in_a;
            wr_b   = in_b;
            wr_en  = 1;
            @(negedge clk);
            wr_en  = 0;
        end
    endtask

    initial begin
        $dumpfile("pe_array_wave.vcd");
        $dumpvars(0, pe_array_tb);

        resetn = 0;
        repeat (2) @(negedge clk);
        resetn = 1;
        @(negedge clk);

        // Load 4 different operand pairs, one per lane
        // lane0: 2*3=6   lane1: -4*5=-20   lane2: 7*(-2)=-14   lane3: 10*10=100
        load_lane(0, 2, 3);
        load_lane(1, -4, 5);
        load_lane(2, 7, -2);
        load_lane(3, 10, 10);

        // Fire valid ONCE - all 4 PEs should MAC simultaneously on this one edge
        @(negedge clk);
        valid = 1;
        @(negedge clk);
        valid = 0;
        @(negedge clk);

        $display("acc0 = %0d (expected 6)",   acc0);
        $display("acc1 = %0d (expected -20)", acc1);
        $display("acc2 = %0d (expected -14)", acc2);
        $display("acc3 = %0d (expected 100)", acc3);

        // Second MAC step, same lanes, accumulate again - proves multi-step correctness per lane
        @(negedge clk);
        valid = 1;
        @(negedge clk);
        valid = 0;
        @(negedge clk);

        $display("After 2nd MAC step:");
        $display("acc0 = %0d (expected 12)",   acc0);
        $display("acc1 = %0d (expected -40)",  acc1);
        $display("acc2 = %0d (expected -28)",  acc2);
        $display("acc3 = %0d (expected 200)",  acc3);

        // clear_acc should reset all 4 lanes simultaneously
        clear_acc = 1;
        @(negedge clk);
        clear_acc = 0;
        @(negedge clk);

        $display("After clear_acc:");
        $display("acc0=%0d acc1=%0d acc2=%0d acc3=%0d (all expected 0)", acc0, acc1, acc2, acc3);

        $display("Simulation finished.");
        $finish;
    end

endmodule
