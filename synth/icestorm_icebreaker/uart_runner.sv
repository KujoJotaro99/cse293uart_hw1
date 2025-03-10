`timescale 1ns/1ps

module uart_runner;

    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD_12 = 83.333;
    parameter CLK_PERIOD = 50.314;
    parameter BAUD_RATE = 9600;
    parameter TIME_SPENT_PER_BIT = 1_000_000_000 / BAUD_RATE;
    parameter CYCLES_PER_BIT = TIME_SPENT_PER_BIT / CLK_PERIOD;

    logic clk;
    logic BTN_N;
    logic rx_i;
    wire tx_o;
    wire [4:0] led_o;
    wire [31:0] mult_result_o;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD_12 / 2) clk = ~clk;
    end

    logic pll_out;
    initial begin
        pll_out = 0;
        forever begin
            #(CLK_PERIOD/2);
            pll_out = !pll_out;
        end
    end
    assign icebreaker.pll_inst.PLLOUTGLOBAL = pll_out;

    //acive high reset
    task automatic reset;
        begin
            BTN_N = 0;
            @(posedge pll_out);
            @(posedge pll_out);
            @(posedge pll_out);
            @(posedge pll_out);
            @(posedge pll_out);
            BTN_N = 1;
        end
        //set start bit to 1 again
        rx_i = 1'b1;
    endtask

    icebreaker icebreaker (
        .CLK(clk),
        .BTN_N(~BTN_N),
        .rx_i(rx_i),
        .tx_o(tx_o),
        .led_o(led_o)
    );

    //send data task
    task automatic send_data(input [DATA_WIDTH-1:0] data);
        integer i;
        $display("Sent input: %h", data);
        #TIME_SPENT_PER_BIT;
        //start bit
        rx_i = 1'b0;
        #TIME_SPENT_PER_BIT;
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            rx_i = data[i];  //rx_i to current bit
            #TIME_SPENT_PER_BIT;
        end
        //stop bit
        rx_i = 1'b1;
        #TIME_SPENT_PER_BIT;
    endtask

    //task to wait
    task automatic wait_for_tx_ready();
        begin
            #TIME_SPENT_PER_BIT;
        end
    endtask

    wire [DATA_WIDTH-1:0] rx_data_o;
    wire rx_valid_o;

    //uart rx to receve data
    //uart rx cock and ball torture
    uart_rx uart_rx_inst_tb (
        .clk(pll_out),
        .rst(~BTN_N),
        .m_axis_tready(1'b1),//always ready
        .m_axis_tdata(rx_data_o),
        .m_axis_tvalid(rx_valid_o),
        .rxd(tx_o),
        .busy(),
        .overrun_error(),
        .frame_error(),
        .prescale(258)//19_875mhz
    );

    //receiev data task
    task automatic receive_data();
        begin
            @(posedge rx_valid_o);
            $display("Received output: %h", mult_result_o);
        end
    endtask

    task automatic display_rx_data();
        begin
            forever begin
                repeat (1_000_000) begin
                    @(posedge pll_out);
                end
                $display("rx_o output: %b", rx_data_o);
            end
        end
    endtask

    /*
    task automatic receive_data();
        integer i;
        logic [DATA_WIDTH-1:0] b_temp;
        @(posedge tx_o);
        begin
            for (i = 0; i<DATA_WIDTH ; i = i + 1) begin
                b_temp[i] = tx_o;
                //$display("Received output: %b", tx_o);
                #TIME_SPENT_PER_BIT;
            end
        end
        $display("Received output: %h", b_temp);
    endtask
    */

endmodule
