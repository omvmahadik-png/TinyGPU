module top (
    input clk,
    input resetn_btn,
    output [15:0] led
);

    wire resetn = !resetn_btn;

    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    picorv32 #(
        .ENABLE_MUL(1),
        .ENABLE_DIV(0),
        .ENABLE_IRQ(0),
        .COMPRESSED_ISA(0)
    ) cpu (
        .clk       (clk),
        .resetn    (resetn),
        .trap      (),

        .mem_valid (mem_valid),
        .mem_instr (mem_instr),
        .mem_ready (mem_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (mem_rdata)
    );

    // Address decode: three regions
    wire is_gpio = (mem_addr == 32'h1000_0000);
    wire is_gpu  = (mem_addr[31:8] == 24'h200000);  // 0x20000000 - 0x200000FF
    wire is_ram  = !is_gpio && !is_gpu;

    wire        ram_valid  = mem_valid && is_ram;
    wire        gpio_valid = mem_valid && is_gpio;
    wire        gpu_valid  = mem_valid && is_gpu;

    wire        ram_ready;
    wire [31:0] ram_rdata;
    wire        gpio_ready;
    wire [31:0] gpio_rdata;
    wire        gpu_ready;
    wire [31:0] gpu_rdata;

    assign mem_ready = is_gpio ? gpio_ready : (is_gpu ? gpu_ready : ram_ready);
    assign mem_rdata = is_gpio ? gpio_rdata : (is_gpu ? gpu_rdata : ram_rdata);

    simple_memory #(
        .MEM_WORDS(1024)
    ) mem (
        .clk       (clk),
        .resetn    (resetn),
        .mem_valid (ram_valid),
        .mem_instr (mem_instr),
        .mem_ready (ram_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (ram_rdata)
    );

    gpio gpio_inst (
        .clk    (clk),
        .resetn (resetn),
        .valid  (gpio_valid),
        .ready  (gpio_ready),
        .wdata  (mem_wdata),
        .wstrb  (mem_wstrb),
        .rdata  (gpio_rdata),
        .led    (led)
    );

    gpu_mmio gpu_inst (
        .clk         (clk),
        .resetn      (resetn),
        .valid       (gpu_valid),
        .ready       (gpu_ready),
        .local_addr  (mem_addr[7:0]),
        .wdata       (mem_wdata),
        .wstrb       (mem_wstrb),
        .rdata       (gpu_rdata)
    );

endmodule
