module uart_echo_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 8;
    reg clk;
    reg rst;
    reg [DATA_WIDTH-1:0] data_in;
    reg valid_li;
    reg ready_li;
    wire [DATA_WIDTH-1:0] data_out;
    wire valid_lo;
    wire ready_lo;

uart_echo #(.DATA_WIDTH(DATA_WIDTH)) uart_echo_inst (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .valid_li(valid_li),
    .ready_li(ready_li),

    .data_out(data_out),
    .valid_lo(valid_lo),
    .ready_lo(ready_lo)
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
    data_in = 0;
    valid_li = 0;
    ready_li = 1;

    $display( "Start simulation." );

    //reset test
    #16 rst = 1;
    #16 rst = 0;
    //wait 10 cycles
    #80;
    //input stimuli
    for (integer i = 0; i < 100; i = i + 1) begin
        data_in = $urandom_range(0, 255);
        $display( "%d", data_in );
        send_data(data_in[7:0]);
        recieve_data(data_in[7:0]);
    end

    $display( "End simulation." );
    $finish;
end

//task to set valid high and low for data stream
task send_data(input [DATA_WIDTH-1:0] tx_data);
    begin
        valid_li = 1;
        data_in = tx_data;
        //assert for at least one cycle so enough samples can be taken by rx uart
        #8;
        valid_li = 0;
        data_in = 0;
    end
endtask

//task to check output
task recieve_data(input [DATA_WIDTH-1:0] expected_data);
    integer timeout_counter;
    begin
        timeout_counter = 100;
        while (!valid_lo && timeout_counter > 0) begin
            #8;
            timeout_counter = timeout_counter - 1;
        end

        if (timeout_counter == 0) begin
            $display("FAIL: Timeout waiting for valid_lo. Expected 0x%02X", expected_data);
        end else if (data_out === expected_data) begin
            $display("PASS: Received echo data = 0x%02X", data_out);
        end else begin
            $display("FAIL: Expected 0x%02X, but got 0x%02X", expected_data, data_out);
        end
    end
endtask


endmodule
