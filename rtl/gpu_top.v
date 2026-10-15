module gpu_top (
    input clk,
    input resetn,

    input        wr_en,
    input  [1:0] wr_idx,
    input signed [7:0] wr_a,
    input signed [7:0] wr_b,

    input        start,
    input        clear_pulse,
    input  [3:0] mask_in,

    output signed [31:0] acc0,
    output signed [31:0] acc1,
    output signed [31:0] acc2,
    output signed [31:0] acc3,
    output busy,
    output done
);

    wire [3:0] mask;
    wire       valid, clear_acc;

    scheduler sched (
        .clk         (clk),
        .resetn      (resetn),
        .start       (start),
        .clear_pulse (clear_pulse),
        .mask_in     (mask_in),
        .mask        (mask),
        .valid       (valid),
        .clear_acc   (clear_acc),
        .busy        (busy),
        .done        (done)
    );

    pe_array parray (
        .clk       (clk),
        .resetn    (resetn),
        .wr_en     (wr_en),
        .wr_idx    (wr_idx),
        .wr_a      (wr_a),
        .wr_b      (wr_b),
        .valid     (valid),
        .clear_acc (clear_acc),
        .mask      (mask),
        .acc0      (acc0),
        .acc1      (acc1),
        .acc2      (acc2),
        .acc3      (acc3)
    );

endmodule
