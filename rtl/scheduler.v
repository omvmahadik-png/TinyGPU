module scheduler (
    input clk,
    input resetn,

    input       start,
    input       clear_pulse,
    input [3:0] mask_in,

    output reg [3:0] mask,
    output reg       valid,
    output reg       clear_acc,
    output reg       busy,
    output reg       done
);

    localparam IDLE = 0, FINISH = 1;
    reg state;

    always @(posedge clk) begin
        if (!resetn) begin
            state     <= IDLE;
            valid     <= 0;
            clear_acc <= 0;
            busy      <= 0;
            done      <= 0;
            mask      <= 4'b0000;
        end else begin
            valid     <= 0;
            clear_acc <= 0;

            case (state)
                IDLE: begin
                    busy <= 0;
                    if (clear_pulse) begin
                        clear_acc <= 1;
                        busy      <= 1;
                        done      <= 0;   // clear old done - a new operation is starting
                        state     <= FINISH;
                    end else if (start) begin
                        mask  <= mask_in;
                        valid <= 1;
                        busy  <= 1;
                        done  <= 0;       // clear old done - a new operation is starting
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    busy  <= 0;
                    done  <= 1;           // latches high - stays until next start/clear
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
