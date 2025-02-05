`timescale 1ns/1ps

module icebreaker (
    input CLK,
    input BTN_N,
    input rx_i,
    output tx_o
);

wire clk_12 = CLK;
wire led;
assign LEDG_N = !led;
wire clk_pll_50_25;//generated system clock from PLL
wire rst_inv;//synchronized reset signal
assign rst_inv = ~BTN_N;

// icepll -i 12 -o 50
SB_PLL40_PAD #(
    .DIVR(4'b0000),
    .DIVF(7'b1000010),
    .DIVQ(3'b100),
    .FILTER_RANGE(3'b001),
    .FEEDBACK_PATH("SIMPLE")
) pll_inst (
    .PACKAGEPIN(clk_12),
    .PLLOUTGLOBAL(clk_pll_50_25),
    .LOCK(),
    .BYPASS(1'b0),
    .RESETB(1'b1)
);

//UART echo module
uart_echo uart_inst (
    .clk(clk_pll_50_25), //50.25mhz clk
    .rst(rst_inv),
    .rx_i(rx_i),//input
    .tx_o(tx_o)//puput
);
endmodule
