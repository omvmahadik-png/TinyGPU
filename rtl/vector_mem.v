module vector_mem (
    input clk,
    input resetn,

    // Write port: load one lane's operand pair at a time
    input        wr_en,
    input  [1:0] wr_idx,
    input signed [7:0] wr_a,
    input signed [7:0] wr_b,

    // Read port: all 4 lanes' data available simultaneously
    output signed [7:0] a0, output signed [7:0] b0,
    output signed [7:0] a1, output signed [7:0] b1,
    output signed [7:0] a2, output signed [7:0] b2,
    output signed [7:0] a3, output signed [7:0] b3
);

    reg signed [7:0] mem_a [0:3];
    reg signed [7:0] mem_b [0:3];

    always @(posedge clk) begin
        if (!resetn) begin
            mem_a[0] <= 0; mem_b[0] <= 0;
            mem_a[1] <= 0; mem_b[1] <= 0;
            mem_a[2] <= 0; mem_b[2] <= 0;
            mem_a[3] <= 0; mem_b[3] <= 0;
        end else if (wr_en) begin
            mem_a[wr_idx] <= wr_a;
            mem_b[wr_idx] <= wr_b;
        end
    end

    assign a0 = mem_a[0]; assign b0 = mem_b[0];
    assign a1 = mem_a[1]; assign b1 = mem_b[1];
    assign a2 = mem_a[2]; assign b2 = mem_b[2];
    assign a3 = mem_a[3]; assign b3 = mem_b[3];

endmodule
