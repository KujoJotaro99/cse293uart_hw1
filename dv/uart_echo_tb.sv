`timescale 1ns/1ps

module uart_echo_tb;
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 20;
    parameter BAUD_RATE = 9600;
    parameter TIME_SPENT_PER_BIT = 1_000_010_000 / BAUD_RATE;
    parameter CYCLES_PER_BIT = TIME_SPENT_PER_BIT / CLK_PERIOD;//104,627/20 = 5209 cycles required for one bit

    reg clk;
    reg rst;
    reg rx_i;
    wire tx_o;
    wire tx_ready;

    uart_echo uart_echo_inst (
        .clk(clk),
        .rst(rst),
        .rx_i(rx_i),
        .tx_o(tx_o)
    );

    //wait till tx output has parllel data ready
    //assign tx_ready = uart_echo_inst.tx_ready;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("dump.fst");
        $dumpvars;
        $display("Begin simulation.");
        $urandom(100);
        $timeformat(-3, 3, "ms", 0);

        rst = 0;
        rx_i = 1'b1;//high on idle

        #16 rst = 1;
        #16 rst = 0;
        #80;

        send_data(8'h00);
        wait_for_tx_ready();//wait for transmission to complete
        recieve_data();

        send_data(8'hAA);
        wait_for_tx_ready();//wait for transmission to complete
        recieve_data();

        #500;

        $display("End simulation.");
        $finish;
    end

    task send_data(input [DATA_WIDTH-1:0] data);
        integer i;
        #TIME_SPENT_PER_BIT;
        rx_i = 1'b0;
        #TIME_SPENT_PER_BIT;
        begin
            for (i = DATA_WIDTH-1; i >= 0; i = i - 1) begin//msb to lsb
                rx_i = data[i];//set rx_i to the current bit
                #TIME_SPENT_PER_BIT;//wait to sample
            end
            //stop bit, rx goes back high
            rx_i = 1'b1;
            #TIME_SPENT_PER_BIT;
        end
    endtask

    task wait_for_tx_ready();
        begin
            //transmission is done
            //wait(tx_ready == 0);
            #TIME_SPENT_PER_BIT;
        end
    endtask

    task recieve_data();
        integer i;
        logic [DATA_WIDTH-1:0] b_temp;
        begin
            for (i = DATA_WIDTH-1; i >= 0; i = i - 1) begin
                b_temp[i] = tx_o;//add incoming bit to reconstruct data
                $display("Got output: %b", tx_o);
                #TIME_SPENT_PER_BIT;//wait to sample
            end
            $display("Got output: %h", b_temp);
            #TIME_SPENT_PER_BIT;
        end
    endtask

endmodule
