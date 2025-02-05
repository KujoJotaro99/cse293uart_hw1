module top_echo (
    input clk,
    input rst,
    input rx_i,
    output tx_o
);

    //UART echo module
    uart_echo uart_inst (
        .clk(clk), //50.25mhz clk
        .rst(rst),
        .rx_i(rx_i),//input
        .tx_o(tx_o)//puput
    );
endmodule
