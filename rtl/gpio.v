module gpio (
    input clk,
    input resetn,

    input         valid,
    output reg    ready,
    input  [31:0] wdata,
    input  [3:0]  wstrb,
    output reg [31:0] rdata,

    output reg [15:0] led
);

    always @(posedge clk) begin
        ready <= 0;
        if (resetn && valid && !ready) begin
            ready <= 1;
            if (wstrb != 4'b0000) begin
                led <= wdata[15:0];
            end
            rdata <= {16'b0, led};
        end
    end

    initial led = 16'b0;

endmodule
