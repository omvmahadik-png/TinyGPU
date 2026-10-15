module gpu_mmio (
    input clk,
    input resetn,

    input         valid,
    output reg    ready,
    input  [7:0]  local_addr,   // offset within the GPU's address region
    input  [31:0] wdata,
    input  [3:0]  wstrb,
    output reg [31:0] rdata
);

    // --- Wires to/from gpu_top's constituent parts ---
    wire        wr_en;
    wire [1:0]  wr_idx;
    wire signed [7:0] wr_a, wr_b;
    wire        start_pulse;
    wire        clear_pulse;
    wire [3:0]  mask_reg_out;
    wire        busy, done;
    wire signed [31:0] acc0, acc1, acc2, acc3;

    reg [3:0] mask_reg;
    assign mask_reg_out = mask_reg;

    reg wr_en_r, start_r, clear_r;
    reg [1:0] wr_idx_r;
    reg signed [7:0] wr_a_r, wr_b_r;

    assign wr_en  = wr_en_r;
    assign wr_idx = wr_idx_r;
    assign wr_a   = wr_a_r;
    assign wr_b   = wr_b_r;
    assign start_pulse = start_r;
    assign clear_pulse = clear_r;

    gpu_top gpu (
        .clk         (clk),
        .resetn      (resetn),
        .wr_en       (wr_en),
        .wr_idx      (wr_idx),
        .wr_a        (wr_a),
        .wr_b        (wr_b),
        .start       (start_pulse),
        .clear_pulse (clear_pulse),
        .mask_in     (mask_reg_out),
        .acc0        (acc0),
        .acc1        (acc1),
        .acc2        (acc2),
        .acc3        (acc3),
        .busy        (busy),
        .done        (done)
    );

    always @(posedge clk) begin
        ready   <= 0;
        wr_en_r <= 0;
        start_r <= 0;
        clear_r <= 0;

        if (resetn && valid && !ready) begin
            ready <= 1;

            if (wstrb != 4'b0000) begin
                // Write access
                case (local_addr)
                    8'h00: begin
                        wr_idx_r <= wdata[1:0];
                        wr_a_r   <= wdata[9:2];
                        wr_b_r   <= wdata[17:10];
                        wr_en_r  <= 1;
                    end
                    8'h04: mask_reg <= wdata[3:0];
                    8'h08: start_r  <= 1;
                    8'h0C: clear_r  <= 1;
                endcase
            end else begin
                // Read access
                case (local_addr)
                    8'h10: rdata <= {30'b0, done, busy};
                    8'h14: rdata <= acc0;
                    8'h18: rdata <= acc1;
                    8'h1C: rdata <= acc2;
                    8'h20: rdata <= acc3;
                    default: rdata <= 32'hDEADBEEF; // easy-to-spot invalid-address marker
                endcase
            end
        end
    end

endmodule
