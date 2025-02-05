`timescale 1ns/1ps

module uart_tb
import config_pkg::*;
import dv_pkg::*;
;


    uart_runner uart_runner_inst();

    initial begin
        $dumpfile( "dump.fst" );
        $dumpvars;
        $display("Begin simulation.");
        $urandom(100);
        $timeformat(-3, 3, "ms", 0);

        uart_runner_inst.reset();

        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.wait_for_tx_ready();
        uart_runner_inst.receive_data();

        uart_runner_inst.send_data(8'hAA);
        uart_runner_inst.wait_for_tx_ready();
        uart_runner_inst.receive_data();
        #500;
        $display("End simulation.");
        $finish;
    end

endmodule
