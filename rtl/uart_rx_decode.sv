module uart_rx_decode (
    input clk_i,
    input rst_i,
    input [7:0] rx_data_i,//byte input
    input rx_valid_i,//will trigger every 8 bits or 1 byte
    output [7:0] opcode_o,
    output [2:0] num_operands_o,
    output [31:0] operands_o [3:0],
    output valid_o
);
    typedef enum logic [2:0] {READ_OPCODE, READ_RESERVED, READ_LENGTH_LSB, READ_LENGTH_MSB, READ_OPERANDS, DONE} state_t;
    state_t state; //           000         001             010             011             100             101

    logic [2:0] operand_count_reg;
    logic [15:0] length_o_reg;
    logic [1:0] byte_index;
    logic [31:0] operand_buffer [3:0];
    logic [31:0] operands_o_reg [3:0];
    logic valid_o_reg;
    logic [7:0] opcode_o_reg;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state <= READ_OPCODE;
            operand_count_reg <= 0;
            operand_buffer[0] <= 0;
            operand_buffer[1] <= 0;
            operand_buffer[2] <= 0;
            operand_buffer[3] <= 0;
            byte_index <= 0;
            valid_o_reg <= 0;
            length_o_reg <= 0;
            opcode_o_reg <= 0;
        end else begin
            case (state)
                READ_OPCODE: begin
                    valid_o_reg <= 0;
                    if (rx_valid_i) begin
                        opcode_o_reg <= rx_data_i;
                        state <= READ_RESERVED;
                    end
                end
                READ_RESERVED: begin
                    if (rx_valid_i) begin
                        state <= READ_LENGTH_LSB;//skip
                    end
                end
                READ_LENGTH_LSB: begin
                    if (rx_valid_i) begin
                        state <= READ_LENGTH_MSB;
                        length_o_reg[7:0] <= rx_data_i;
                    end
                end
                READ_LENGTH_MSB: begin
                    if (rx_valid_i) begin
                        length_o_reg[15:8] <= rx_data_i;
                        operand_count_reg <= 0;
                        byte_index <= 0;
                        state <= READ_OPERANDS;
                    end
                end
                READ_OPERANDS: begin
                    if (rx_valid_i) begin
                        //since rx_valid is high, store 4 bytes for N oerands
                        operand_buffer[operand_count_reg][(3-byte_index) * 8 +: 8] <= rx_data_i;
                        byte_index <= byte_index + 1;
                        //reset operand if 32 bits reached
                        if (byte_index === 3) begin
                            byte_index <= 0;
                            operand_count_reg <= operand_count_reg + 1;
                        end
                    end
                    //if target operand count reached
                    if (operand_count_reg[2:0] === length_o_reg[2:0]) begin
                        state <= DONE;
                    end
                end
                DONE: begin
                    valid_o_reg <= 1;
                    state <= READ_OPCODE;
                end
                default:
                    state <= READ_OPCODE;
            endcase
        end
    end
    assign valid_o = valid_o_reg;
    assign num_operands_o = operand_count_reg[2:0];
    //store oeprands
    assign operands_o[0] = operand_buffer[0];
    assign operands_o[1] = operand_buffer[1];
    assign operands_o[2] = operand_buffer[2];
    assign operands_o[3] = operand_buffer[3];
    assign opcode_o = opcode_o_reg;
endmodule
