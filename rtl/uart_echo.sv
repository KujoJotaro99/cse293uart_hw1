module uart_echo #(parameter DATA_WIDTH = 8)(
    //input
    input rx_i,
    input clk,
    input rst,
    //output
    output tx_o
);
//prescale calculation, slows down sampling rate to match baud rate since system clock is much faster, samples in the middle of cycle n times
//prescale = system clk freq / (baud rate * sampples per bit)

wire [DATA_WIDTH-1:0] rx_data;//data received by the receiver
wire rx_valid;//indicates when rx_data is valid
wire tx_ready;//indicates when the transmitter is ready
wire [DATA_WIDTH-1:0] tx_data;//data to be transmitted/echoed

uart_rx #(.DATA_WIDTH(DATA_WIDTH)) uart_rx_echo_inst  (
    .clk(clk),
    .rst(rst),
    //axi input
    .m_axis_tready(1'b1),
    //axi output
    .m_axis_tdata(rx_data),
    .m_axis_tvalid(rx_valid),
    //uart interface input
    .rxd(rx_i),
    //status
    .busy(),
    .overrun_error(ov_err),
    .frame_error(frame_error),
    //config
    .prescale(654)//50,000,000/(9600*8)
);

uart_tx #(.DATA_WIDTH(DATA_WIDTH)) uart_tx_echo_inst  (
    .clk(clk),
    .rst(rst),
    //axi input
    .s_axis_tdata(rx_data),
    .s_axis_tvalid(rx_valid),
    //axi output
    .s_axis_tready(tx_ready),
    //uart interface output
    .txd(tx_o),
    //status
    .busy(),
    //config
    .prescale(654) //50,250,000/(9600*8)
);

endmodule

// uart tx instance
//reset: all low
//idle:
//monitors s_axis_tvalid line, samples when valid data input, enters busy state
//busy:
//loads data with stop bits, sets txd_reg to 0 (start bit), loads prescale value, data reg shifted when prescale countdown reaches 0, bit cnt decremented
//check:
//if all bits done transmitting, sets txd_reg to high

//uart rx instance
//reset: all low
//idle:
//monitors rxd line, samples when transitions high to low, enters busy state
//busy:
//bit cnt updated (start bit + data bits + stop bit), pushes sampled bits into data_reg, prescale decremented and reloaded every bit
//check:
//if rxd high, valid -> data stored in m_axis_tdata, raises m_axis_tvalid, if rxd low, invalid -> raises overrun_error
//back to idle
