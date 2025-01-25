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
//prescale calculation, slows down sampling rate to match baud rate since system clock is much faster, samples in the middle of cycle n times
//prescale = system clk freq / (baud rate * sampples per bit)
// uart tx instance
//reset: all low
//idle:
//monitors s_axis_tvalid line, samples when valid data input, enters busy state
//busy:
//loads data with stop bits, sets txd_reg to 0 (start bit), loads prescale value, data reg shifted when prescale countdown reaches 0, bit cnt decremented
//check:
//if all bits done transmitting, sets txd_reg to high
//back to idle
wire busy_tx;
wire txd_o;
uart_tx uart_tx_echo_inst #(.DATA_WIDTH(DATA_WIDTH)) (
    .clk(clk),
    .rst(rst),

    //axi input
    .s_axis_tdata(data_in),
    .s_axis_tvalid(valid_li),
    .s_axis_tready(ready_li),

    //uart interface
    .txd(txd_o),

    //status
    .busy(busy_tx),

    //config
    .prescale(125000000/(9600*8))
);
//uart rx instance
//reset: all low
//idle:
//monitors rxd line, samples when transitions high to low, enters busy state
//busy:
//bit cnt updated (start bit + data bits + stop bit), pushes sampled bits into data_reg, prescale decremented and reloaded every bit
//check:
//if rxd high, valid -> data stored in m_axis_tdata, raises m_axis_tvalid, if rxd low, invalid -> raises overrun_error
//back to idle
wire busy_rx;
wire overrun_err_rx;
wire frame_err_rx;
wire [DATA_WIDTH-1:0] m_axis_tdata_o;
wire m_axis_tvalid_o;
wire m_axis_tready_o;
uart_rx uart_rx_echo_inst #(.DATA_WIDTH(DATA_WIDTH)) (
    .clk(clk),
    .rst(rst),

    //axi output
    .m_axis_tdata(m_axis_tdata_o),
    .m_axis_tvalid(m_axis_tvalid_o),
    .m_axis_tready(m_axis_tready_o),

    //uart interface
    .rxd(txd_o),

    //status
    .busy(busy_rx),
    .overrun_error(overrun_err_rx),
    .frame_error(frame_err_rx),

    //config
    .prescale(125000000/(9600*8))
);
//assign output of rx
assign data_out = m_axis_tdata_o;
assign valid_lo = m_axis_tvalid_o;
assign ready_lo = m_axis_tready_o;
endmodule
