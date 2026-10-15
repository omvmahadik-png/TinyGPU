module pe_array (
    input clk,
    input resetn,

    input        wr_en,
    input  [1:0] wr_idx,
    input signed [7:0] wr_a,
    input signed [7:0] wr_b,

    input        valid,
    input        clear_acc,
    input  [3:0] mask,      // per-lane enable, gates valid individually

    output signed [31:0] acc0,
    output signed [31:0] acc1,
    output signed [31:0] acc2,
    output signed [31:0] acc3
);

    wire signed [7:0] a0, b0, a1, b1, a2, b2, a3, b3;

    vector_mem vmem (
        .clk    (clk),
        .resetn (resetn),
        .wr_en  (wr_en),
        .wr_idx (wr_idx),
        .wr_a   (wr_a),
        .wr_b   (wr_b),
        .a0 (a0), .b0 (b0),
        .a1 (a1), .b1 (b1),
        .a2 (a2), .b2 (b2),
        .a3 (a3), .b3 (b3)
    );

    wire valid0 = valid & mask[0];
    wire valid1 = valid & mask[1];
    wire valid2 = valid & mask[2];
    wire valid3 = valid & mask[3];

    pe pe0 (
        .clk       (clk), .resetn (resetn),
        .a (a0), .b (b0),
        .valid (valid0), .clear_acc (clear_acc),
        .acc (acc0)
    );

    pe pe1 (
        .clk       (clk), .resetn (resetn),
        .a (a1), .b (b1),
        .valid (valid1), .clear_acc (clear_acc),
        .acc (acc1)
    );

    pe pe2 (
        .clk       (clk), .resetn (resetn),
        .a (a2), .b (b2),
        .valid (valid2), .clear_acc (clear_acc),
        .acc (acc2)
    );

    pe pe3 (
        .clk       (clk), .resetn (resetn),
        .a (a3), .b (b3),
        .valid (valid3), .clear_acc (clear_acc),
        .acc (acc3)
    );

endmodule
