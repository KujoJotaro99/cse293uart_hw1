module uart_echo #(parameter DATA_WIDTH = 8)(
    // input
    input [DATA_WIDTH-1:0] a_i,
    input t_valid_i,
    input clk,
    input rst,

    // output
    output [DATA_WIDTH-1:0] a_o
);
//either first piece of data in when valid is high, otherwise echo previous data from output back to input
wire [DATA_WIDTH-1:0] a_i_feedback;
assign a_i_feedback = {8{t_valid_i}} & a_i | a_o & {8{r_valid_o}};
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
wire t_ready_o;
wire txd_o;

uart_tx #(.DATA_WIDTH(DATA_WIDTH)) uart_tx_echo_inst  (
    .clk(clk),
    .rst(rst),
    //axi input
    .s_axis_tdata(a_i_feedback),
    .s_axis_tvalid(t_valid_i | r_valid_o),
    //axi output
    .s_axis_tready(t_ready_o),
    //uart interface
    .txd(txd_o),
    //status
    .busy(busy_tx),
    //config
    .prescale(1) //125,000,000/(9600/8)
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
wire r_valid_o;
uart_rx #(.DATA_WIDTH(DATA_WIDTH)) uart_rx_echo_inst  (
    .clk(clk),
    .rst(rst),
    //axi input
    .m_axis_tready(t_ready_o),
    //axi output
    .m_axis_tdata(a_o),
    .m_axis_tvalid(r_valid_o),
    //uart interface
    .rxd(txd_o),
    //status
    .busy(busy_rx),
    .overrun_error(overrun_err_rx),
    .frame_error(frame_err_rx),
    //config
    .prescale(1) //125,000,000/(9600/8)
);


endmodule
