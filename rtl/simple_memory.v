module simple_memory #(
    parameter MEM_WORDS = 1024
) (
    input clk,
    input resetn,

    input         mem_valid,
    input         mem_instr,
    output reg    mem_ready,

    input  [31:0] mem_addr,
    input  [31:0] mem_wdata,
    input  [3:0]  mem_wstrb,
    output reg [31:0] mem_rdata
);

    reg [31:0] mem [0:MEM_WORDS-1];
    wire [31:0] word_addr = mem_addr[31:2];

    always @(posedge clk) begin
        mem_ready <= 0;
        if (resetn && mem_valid && !mem_ready) begin
            mem_ready <= 1;
            if (mem_wstrb[0]) mem[word_addr][7:0]   <= mem_wdata[7:0];
            if (mem_wstrb[1]) mem[word_addr][15:8]  <= mem_wdata[15:8];
            if (mem_wstrb[2]) mem[word_addr][23:16] <= mem_wdata[23:16];
            if (mem_wstrb[3]) mem[word_addr][31:24] <= mem_wdata[31:24];
            if (mem_wstrb == 4'b0000)
                mem_rdata <= mem[word_addr];
        end
    end

    initial begin
        $readmemh("firmware/firmware.hex", mem);
    end

endmodule
