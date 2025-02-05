`timescale 1ns/1ps

module uart_runner;

    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 19.9;
    parameter BAUD_RATE = 9600;
    parameter TIME_SPENT_PER_BIT = 1_000_010_000 / BAUD_RATE;
    parameter CYCLES_PER_BIT = TIME_SPENT_PER_BIT / CLK_PERIOD;

    reg clk;
    reg BTN_N;
    reg rx_i;
    wire tx_o;

    icebreaker icebreaker (
        .CLK(clk),
        .BTN_N(BTN_N),
        .rx_i(rx_i),
        .tx_o(tx_o)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    //acive high reset
    task automatic reset;
        begin
            BTN_N = 0;
            @(posedge clk);
            BTN_N = 1;
        end
        //set start bit to 1 again
        rx_i = 1'b1;
    endtask

    logic pll_out;
    initial begin
        pll_out = 0;
        forever begin
            #9.950ns;//50_250MHz
            pll_out = !pll_out;
        end
    end
    assign icebreaker.pll_inst.PLLOUTGLOBAL = pll_out;

    //send data task
    task automatic send_data(input [DATA_WIDTH-1:0] data);
        integer i;
        $display("Sent input: %h", data);
        #TIME_SPENT_PER_BIT;
        //start bit
        rx_i = 1'b0;
        #TIME_SPENT_PER_BIT;
        for (i = DATA_WIDTH-1; i >= 0; i = i - 1) begin
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

    //receiev data task
    task automatic receive_data();
        integer i;
        logic [DATA_WIDTH-1:0] b_temp;
        begin
            for (i = DATA_WIDTH-1; i >= 0; i = i - 1) begin
                b_temp[i] = tx_o;
                #TIME_SPENT_PER_BIT;
            end
            $display("Received output: %h", b_temp);
            #TIME_SPENT_PER_BIT;
        end
    endtask

endmodule
