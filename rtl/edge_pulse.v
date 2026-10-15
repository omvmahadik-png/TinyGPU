module edge_pulse (
    input clk,
    input resetn,
    input btn_in,        // raw, possibly-held-for-a-long-time button signal
    output reg pulse_out  // exactly one clock cycle high, on rising edge of btn_in
);

    reg btn_prev;

    always @(posedge clk) begin
        if (!resetn) begin
            btn_prev  <= 0;
            pulse_out <= 0;
        end else begin
            pulse_out <= btn_in & ~btn_prev;  // high only on the cycle btn_in transitions 0->1
            btn_prev  <= btn_in;
        end
    end

endmodule
