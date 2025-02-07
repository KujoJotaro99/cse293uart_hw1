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
        uart_runner_inst.send_data(8'h02);//opcode
        uart_runner_inst.send_data(8'h00);//reserved
        uart_runner_inst.send_data(8'h02);//length lsb
        uart_runner_inst.send_data(8'h00);//length msb
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h11);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h11);
        //#22_867_385;
        //uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();

        uart_runner_inst.send_data(8'h02);//opcode
        uart_runner_inst.send_data(8'h00);//reserved
        uart_runner_inst.send_data(8'h02);//length lsb
        uart_runner_inst.send_data(8'h00);//length msb
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h01);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h09);

        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();

        uart_runner_inst.send_data(8'h02);//opcode
        uart_runner_inst.send_data(8'h00);//reserved
        uart_runner_inst.send_data(8'h03);//length lsb
        uart_runner_inst.send_data(8'h00);//length msb
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h01);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h09);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h00);
        uart_runner_inst.send_data(8'h09);

        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();
        uart_runner_inst.display_rx_data();
        $display("End simulation.");
        $finish;
    end

endmodule
