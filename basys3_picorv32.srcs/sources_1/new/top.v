`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2026 01:03:17 AM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top(
    input clk,
    input [15:0] sw,
    input [4:0] btn,

    output [15:0] led,

    output reg [6:0] seg,
    output reg [3:0] an
);

reg resetn = 0;
reg [7:0] reset_counter = 0;

always @(posedge clk) begin
    if (reset_counter < 8'hff) begin
        reset_counter <= reset_counter + 1;
        resetn <= 0;
    end else begin
        resetn <= 1;
    end
end

wire        trap;
wire        mem_valid;
wire        mem_instr;
wire        mem_ready;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0]  mem_wstrb;
reg  [31:0] mem_rdata;

reg [15:0] led_reg = 0;
assign led = led_reg;

// ===============================
// Firmware ROM
// ===============================
reg [31:0] memory [0:4095];

initial begin
    memory[0]  = 32'h100002b7;
    memory[1]  = 32'h100003b7;
    memory[2]  = 32'h00c38393;
    memory[3]  = 32'h0002a303;
    memory[4]  = 32'h00f37413;
    memory[5]  = 32'h00435493;
    memory[6]  = 32'h00f4f493;
    memory[7]  = 32'h01035593;
    memory[8]  = 32'h00f5f593;
    memory[9]  = 32'h00940533;
    memory[10] = 32'h0015f613;
    memory[11] = 32'h02061663;
    memory[12] = 32'h0015d613;
    memory[13] = 32'h00167613;
    memory[14] = 32'h02061463;
    memory[15] = 32'h0025d613;
    memory[16] = 32'h00167613;
    memory[17] = 32'h02061263;
    memory[18] = 32'h0035d613;
    memory[19] = 32'h00167613;
    memory[20] = 32'h02061863;
    memory[21] = 32'h04c0006f;
    memory[22] = 32'h00940533;
    memory[23] = 32'h0440006f;
    memory[24] = 32'h40940533;
    memory[25] = 32'h03c0006f;
    memory[26] = 32'h00000513;
    memory[27] = 32'h009006b3;
    memory[28] = 32'h02068863;
    memory[29] = 32'h00850533;
    memory[30] = 32'hfff68693;
    memory[31] = 32'hff5ff06f;
    memory[32] = 32'h00048e63;
    memory[33] = 32'h00000513;
    memory[34] = 32'h008006b3;
    memory[35] = 32'h0096ca63;
    memory[36] = 32'h409686b3;
    memory[37] = 32'h00150513;
    memory[38] = 32'hff5ff06f;
    memory[39] = 32'h00000513;
    memory[40] = 32'h00a3a023;
    memory[41] = 32'hf69ff06f;
end

assign mem_ready = 1'b1;

// ===============================
// Memory-Mapped Read
// 0x00000000 ~ 0x00003FFF : ROM/RAM
// 0x10000000 : {btn, sw}
// ===============================
always @(*) begin
    mem_rdata = 32'h00000013;

    if (mem_addr < 32'h00004000)
        mem_rdata = memory[mem_addr[13:2]];

    if (mem_addr == 32'h10000000)
        mem_rdata = {11'b0, btn, sw};
end

// ===============================
// Memory-Mapped Write
// 0x1000000C : result output
// ===============================
always @(posedge clk) begin
    if (mem_valid && |mem_wstrb) begin
        if (mem_addr < 32'h00004000) begin
            if (mem_wstrb[0]) memory[mem_addr[13:2]][7:0]   <= mem_wdata[7:0];
            if (mem_wstrb[1]) memory[mem_addr[13:2]][15:8]  <= mem_wdata[15:8];
            if (mem_wstrb[2]) memory[mem_addr[13:2]][23:16] <= mem_wdata[23:16];
            if (mem_wstrb[3]) memory[mem_addr[13:2]][31:24] <= mem_wdata[31:24];
        end

        if (mem_addr == 32'h1000000C) begin
            led_reg <= mem_wdata[15:0];
        end
    end
end

// ===============================
// Seven Segment Display
// ===============================
wire [7:0] result;
assign result = led_reg[7:0];

wire [3:0] A;
wire [3:0] B;

assign A = sw[3:0];
assign B = sw[7:4];

wire compare_pressed;
assign compare_pressed = btn[4];   // BTND：比較鍵

wire compare_value;
assign compare_value = (A > B);

reg [3:0] hundreds;
reg [3:0] tens;
reg [3:0] ones;

always @(*) begin
    hundreds = result / 100;
    tens     = (result % 100) / 10;
    ones     = result % 10;
end

reg [19:0] scan_counter = 0;

always @(posedge clk) begin
    scan_counter <= scan_counter + 1;
end

function [6:0] seg_decode;
    input [3:0] num;
    begin
        case (num)
            4'd0: seg_decode = 7'b1000000;
            4'd1: seg_decode = 7'b1111001;
            4'd2: seg_decode = 7'b0100100;
            4'd3: seg_decode = 7'b0110000;
            4'd4: seg_decode = 7'b0011001;
            4'd5: seg_decode = 7'b0010010;
            4'd6: seg_decode = 7'b0000010;
            4'd7: seg_decode = 7'b1111000;
            4'd8: seg_decode = 7'b0000000;
            4'd9: seg_decode = 7'b0010000;
            default: seg_decode = 7'b1111111;
        endcase
    end
endfunction

always @(*) begin
    case (scan_counter[19:18])

        2'b00: begin
            an  = 4'b1110;          // 最右邊：個位
            seg = seg_decode(ones);
        end

        2'b01: begin
            an  = 4'b1101;          // 十位
            seg = seg_decode(tens);
        end

        2'b10: begin
            an  = 4'b1011;          // 百位
            seg = seg_decode(hundreds);
        end

        2'b11: begin
            an  = 4'b0111;          // 最左邊：比較結果
            if (compare_pressed) begin
                if (compare_value)
                    seg = seg_decode(4'd1);   // A > B
                else
                    seg = seg_decode(4'd0);   // A <= B
            end else begin
                seg = 7'b1111111;             // 沒按 BTND，最左邊不顯示
            end
        end

    endcase
end

// ===============================
// PicoRV32 CPU
// ===============================
picorv32 #(
    .ENABLE_COUNTERS(0),
    .ENABLE_COUNTERS64(0),
    .ENABLE_REGS_16_31(1),
    .ENABLE_REGS_DUALPORT(1),
    .LATCHED_MEM_RDATA(1),
    .TWO_STAGE_SHIFT(0),
    .BARREL_SHIFTER(0),
    .ENABLE_MUL(0),
    .ENABLE_DIV(0),
    .PROGADDR_RESET(32'h00000000),
    .STACKADDR(32'h00004000)
) cpu (
    .clk(clk),
    .resetn(resetn),
    .trap(trap),

    .mem_valid(mem_valid),
    .mem_instr(mem_instr),
    .mem_ready(mem_ready),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_wstrb(mem_wstrb),
    .mem_rdata(mem_rdata),

    .irq(32'b0)
);

endmodule