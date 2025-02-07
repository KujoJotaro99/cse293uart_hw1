module pipe_mult
  #(parameter width_p = 32)
   (
    input logic clk_i,
    input logic reset_i,
    input logic ready_i,
    // Input Interface
    input logic valid_i,
    output logic ready_o,
    input logic [width_p - 1 : 0] a_i, //multiplicand
    input logic [width_p - 1 : 0] b_i, //multiplier

    output logic valid_o,
    output logic [width_p - 1 : 0] result_o //product
   );

   logic [(2 * width_p):0] product_reg, product_reg_next, a_i_reg_shifted, b_i_reg_extended;
   logic [width_p:0] count, next_count;
   logic valid_o_reg;
   logic ready_o_reg;

   typedef enum logic [2:0] {
    IDLE,
    LOAD,
    DO,
    DONE
   } state_t;

   state_t current_state, next_state;

   always_ff @(posedge clk_i) begin
    if (reset_i) begin
        current_state <= IDLE;
        count <= 0;
        result_o <= 0;
        product_reg <= 0;
    end else begin
        current_state <= next_state;
        count <= next_count;
        product_reg <= product_reg_next;
        result_o <= product_reg_next[(2*width_p):1];
    end
   end

   always_ff @(posedge clk_i) begin
    if (reset_i) begin
        a_i_reg_shifted<=0;
        b_i_reg_extended<=0;
    end else begin
        a_i_reg_shifted <= {a_i, {(width_p + 1){1'b0}}};
        b_i_reg_extended <= {-a_i, {(width_p + 1){1'b0}}};
    end
   end

   always_comb begin
    next_state = current_state;
    next_count = count;
    product_reg_next = product_reg;
    ready_o_reg = 1'b0;
    valid_o_reg = 1'b0;

    case (current_state)
        IDLE: begin
            ready_o_reg = 1'b1;
            if (valid_i) begin
                next_state = LOAD;
                // = {a_i, {(width_p + 1){1'b0}}};
                //b_i_reg_extended = {-a_i, {(width_p + 1){1'b0}}};
            end
        end
        LOAD: begin
            product_reg_next = {{(width_p){1'b0}}, b_i, 1'b0};
            next_state = DO;
        end
        DO: begin
            if (count < width_p) begin
                case (product_reg[1:0])
                    2'b01 : product_reg_next = product_reg + a_i_reg_shifted;
                    2'b10 : product_reg_next = product_reg + b_i_reg_extended;
                    default: product_reg_next = product_reg;
                endcase
                product_reg_next = product_reg_next >>> 1;
                next_count = count + 1;
            end else begin
                next_state = DONE;
            end
        end
        DONE: begin
            ready_o_reg = 1'b1;
            valid_o_reg = 1'b1;
            if (ready_i) begin
                next_state = IDLE;
                next_count = 0;
            end
        end
        default: next_state = IDLE;
    endcase
   end

   assign ready_o = ready_o_reg;
   assign valid_o = valid_o_reg;

endmodule
