module pe (
    input clk,
    input resetn,

    input signed [7:0]  a,
    input signed [7:0]  b,
    input                valid,
    input                clear_acc,

    output reg signed [31:0] acc
);

    always @(posedge clk) begin
        if (!resetn) begin
            acc <= 32'sd0;
        end else if (clear_acc) begin
            acc <= 32'sd0;
        end else if (valid) begin
            acc <= acc + (a * b);
        end
    end

endmodule
