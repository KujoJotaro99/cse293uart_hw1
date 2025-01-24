module uart_echo_top #(paramater DATA_WIDTH = 8)(
    // input
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] data_in,
    input valid_li,
    input ready_li,

    // output
    output [DATA_WIDTH-1:0] data_out,
    output valid_lo,
    output ready_lo
);
// uart tx instance
wire busy_tx;
uart_tx uart_tx_echo_inst #(.DATA_WIDTH(DATA_WIDTH)) (
    .clk(clk),
    .rst(rst),

    //axi input
    .s_axis_tdata(data_in),
    .s_axis_tvalid(valid_li),
    .s_axis_tready(ready_li),

    //uart interface
    .txd(),

    //status
    .busy(busy_tx),

    //config
    .prescale()
);
//uart rx instance
wire busy_rx;
wire overrun_err_rx;
wire frame_err_rx;
uart_rx uart_tx_echo_inst #(.DATA_WIDTH(DATA_WIDTH)) (
    .clk(clk),
    .rst(rst),

    //axi output
    .m_axis_tdata(data_out),
    .m_axis_tvalid(valid_lo),
    .m_axis_tready(ready_lo),

    //uart interface
    .rxd(),

    //status
    .busy(busy_rx),
    .overrun_error(overrun_err_rx),
    .frame_error(frame_err_rx),

    //config
    .prescale()
);
endmodule
