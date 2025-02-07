`timescale 1ns/1ps

module icebreaker (
    input CLK,
    input BTN_N,
    input rx_i,
    output tx_o,
    output [4:0] led_o
);

wire clk_12 = CLK;
wire clk_pll__19_875;//generated system clock from PLL
wire rst_inv;//synchronized reset signal
assign rst_inv = ~BTN_N;

// icepll -i 12 -o 50
SB_PLL40_PAD #(
    .DIVR(4'b0000),
    .DIVF(7'b0110100),
    .DIVQ(3'b101),
    .FILTER_RANGE(3'b001),
    .FEEDBACK_PATH("SIMPLE")
) pll_inst (
    .PACKAGEPIN(clk_12),
    .PLLOUTGLOBAL(clk_pll__19_875),
    .LOCK(),
    .BYPASS(1'b0),
    .RESETB(1'b1)
);

uart_alu alu_inst (
    .clk_i(clk_pll__19_875),
    .rst_i(rst_inv),
    .rx_i(rx_i),
    .tx_o(tx_o),
    .led_o(led_o),
);

/*
//UART echo module
uart_echo uart_inst (
    .clk(clk_pll_50_25), //50.25mhz clk
    .rst(rst_inv),
    .rx_i(rx_i),//input
    .tx_o(tx_o)//puput
);*/
endmodule
