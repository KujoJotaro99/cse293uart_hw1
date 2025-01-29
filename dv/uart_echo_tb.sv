`timescale 1ns/1ps

module uart_echo_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 8;
    parameter BAUD_RATE = 9600;
    parameter TIME_SPENT_PER_BIT = 1_000_000_000 / BAUD_RATE;

    reg clk;
    reg rst;
    reg [DATA_WIDTH-1:0] a_i;
    reg t_valid_i;
    reg [DATA_WIDTH-1:0] a_o;

uart_echo #(.DATA_WIDTH(DATA_WIDTH)) uart_echo_inst (
    .clk(clk),
    .rst(rst),
    .t_valid_i(t_valid_i),
    .a_i(a_i),
    .a_o(a_o)
);

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk; //8ns period 125MHz clock
end

initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);
    $timeformat( -3, 3, "ms", 0);

    //signals
    rst = 0;
    t_valid_i = 0;


    $display( "Start simulation." );

    //reset test
    #16 rst = 1;
    #16 rst = 0;
    //wait 10 cycles
    #80;
    //input stimuli
    a_i = 8'hFF;
    t_valid_i = 1;
    #20;
    t_valid_i = 0;
    #2048;
    $display( "End simulation." );
    $finish;
end

endmodule
