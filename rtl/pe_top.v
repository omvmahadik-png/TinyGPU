module pe_top (
    input clk,
    input resetn_btn,      // note: still active-high physical button, like Phase 0's resetn_btn

    input  [15:0] sw,       // sw[7:0] = a, sw[15:8] = b
    input         btnC,     // trigger: valid
    input         btnU,     // trigger: clear_acc
    input         btnD,     // held: show upper 16 bits of acc; released: show lower 16

    output [15:0] led
);

    wire resetn = !resetn_btn;

    // Convert momentary button presses into single-cycle pulses
    wire valid_pulse;
    wire clear_pulse;

    edge_pulse valid_edge (
        .clk       (clk),
        .resetn    (resetn),
        .btn_in    (btnC),
        .pulse_out (valid_pulse)
    );

    edge_pulse clear_edge (
        .clk       (clk),
        .resetn    (resetn),
        .btn_in    (btnU),
        .pulse_out (clear_pulse)
    );

    wire signed [31:0] acc;

    pe pe_inst (
        .clk       (clk),
        .resetn    (resetn),
        .a         (sw[7:0]),
        .b         (sw[15:8]),
        .valid     (valid_pulse),
        .clear_acc (clear_pulse),
        .acc       (acc)
    );

    // btnD held = show upper 16 bits, released = show lower 16 bits
    assign led = btnD ? acc[31:16] : acc[15:0];

endmodule
