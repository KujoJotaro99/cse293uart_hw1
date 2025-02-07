module uart_alu #(parameter DATA_WIDTH = 8) (
    input wire clk_i,
    input wire rst_i,
    input wire rx_i,
    output wire tx_o,
    output [4:0] led_o
);

//rx output signals
wire [DATA_WIDTH-1:0] rx_data_o;
wire rx_valid_o;

//fsm output signals
wire [7:0] opcode_o;
wire [31:0] operands_o [3:0];
wire fsm_valid_o;
wire [2:0] num_operands_o;

//multiply output signals
wire [31:0] mult_result_o;
wire mult_valid_o;
wire mult_ready_o;
logic [31:0] rolling_product;
logic [2:0] operand_index;
logic processing;
logic multiply_start;
logic multiplication_done;

//tx output signals
wire tx_ready_o;
logic [2:0] byte_index;
logic [7:0] tx_data_i;
logic tx_valid_i;
logic transmitting;

uart_rx #(.DATA_WIDTH(DATA_WIDTH)) uart_rx_inst (
    .clk(clk_i),
    .rst(rst_i),
    .m_axis_tready(1'b1),
    .m_axis_tdata(rx_data_o),
    .m_axis_tvalid(rx_valid_o),
    .rxd(rx_i),
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale(258)//19.875 MHz
);

uart_rx_decode uart_sm (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rx_data_i(rx_data_o),
    .rx_valid_i(rx_valid_o),
    .opcode_o(opcode_o),
    .operands_o(operands_o),
    .valid_o(fsm_valid_o),
    .num_operands_o(num_operands_o)
);

assign led_o[0] = multiplication_done;
assign led_o[1] = tx_valid_i;
assign led_o[4:2] = num_operands_o[2:0];

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        rolling_product <= 1;
        operand_index <= 0;
        processing <= 0;
        multiply_start <= 0;
        multiplication_done <= 0;
    end else if (fsm_valid_o) begin
        processing <= 1;
        operand_index <= 1;//assume at least 2 operands exist to skip 1*operand0 stage
        rolling_product <= operands_o[0];
        multiply_start <= (num_operands_o > 1);
        multiplication_done <= 0;
    end else if (processing && mult_valid_o) begin
        rolling_product <= mult_result_o;
        operand_index <= operand_index + 1;
        multiply_start <= (operand_index + 1 < num_operands_o);
        if ((operand_index + 1) == num_operands_o) begin
            multiplication_done <= 1;
            processing <= 0;
        end
    end if (multiplication_done && !transmitting) begin
        multiplication_done <= 0;//kind of shitty, but to ensure mult_done signal isnt high always
    end
end

pipe_mult multiplier (
    .clk_i(clk_i),
    .reset_i(rst_i),
    .valid_i(multiply_start),
    .ready_i(tx_ready_o),
    .ready_o(mult_ready_o),
    .a_i(rolling_product),
    .b_i(operands_o[operand_index]),
    .result_o(mult_result_o),
    .valid_o(mult_valid_o)
);

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        byte_index <= 0;
        tx_valid_i <= 0;
        tx_data_i <= 0;
        transmitting <= 0;
    end else if (multiplication_done && !transmitting) begin
        //start transmitting when multiplication is done
        byte_index <= 0;
        tx_data_i <= mult_result_o[7:0];//lsb
        tx_valid_i <= 1;
        transmitting <= 1;
    end else if (tx_ready_o && tx_valid_i) begin
        if (byte_index < 3) begin
            byte_index <= byte_index + 1;
            tx_data_i <= mult_result_o[(byte_index + 1) * 8 +: 8];
        end else begin
            tx_valid_i <= 0;
            transmitting <= 0;
        end
    end
end

uart_tx #(.DATA_WIDTH(DATA_WIDTH)) uart_tx_inst (
    .clk(clk_i),
    .rst(rst_i),
    .s_axis_tdata(tx_data_i),
    .s_axis_tvalid(tx_valid_i),
    .s_axis_tready(tx_ready_o),
    .txd(tx_o),
    .busy(),
    .prescale(258)//19.875 MHz
);

endmodule
