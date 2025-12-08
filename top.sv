`timescale 1ns/1ns

`include "uvm_macros.svh"
`include "defines.sv"
`include "apb_if.sv"
`include "apb_bind.sv"
`include "apb_assertions.sv"
`include "apb_slave.v"
// `include "apb_pkg.sv"

import uvm_pkg::*;
import apb_pkg::*;


// `include "uvm_macros.svh"
// `include "defines.sv"
// `include "apb_if.sv"
// `include "apb_slave.v"
//   `include "apb_sequence_item.sv"
//   `include "apb_sequence.sv"
//   `include "apb_sequencer.sv"
//   `include "apb_driver.sv"
//   `include "apb_active_monitor.sv"
//   `include "apb_passive_monitor.sv"
//   `include "apb_active_agent.sv"
//   `include "apb_passive_agent.sv"
//   `include "apb_scoreboard.sv"
//   `include "apb_subscriber.sv"
//   `include "apb_environment.sv"
//   `include "apb_test.sv"
//   `include "apb_bind.sv"
//   `include "apb_assertions.sv"

module top;
  	bit PCLK;
  	bit PRESETn;
  	
  	initial PCLK = 1'b0;
  	always #5 PCLK = ~ PCLK;
  
  	initial begin
      PRESETn = 1'b0; 
			#15 PRESETn = 1'b1;
      
      #1;PRESETn = 1'b0;
      #1;PRESETn = 1'b1;
    end
  
  apb_if intf(PCLK, PRESETn);

 apb_slave #(
    .ADDR_WIDTH(`ADDR_WIDTH),
    .DATA_WIDTH(`DATA_WIDTH),
    .MEM_DEPTH(`MEM_DEPTH)
) DUV (
    .PCLK     (PCLK),
    .PRESETn  (PRESETn),
    .PADDR    (intf.PADDR),
    .PSEL     (intf.PSEL),
    .PENABLE  (intf.PENABLE),
    .PWRITE   (intf.PWRITE),
    .PWDATA   (intf.PWDATA),
    .PSTRB    (intf.PSTRB),
    .PRDATA   (intf.PRDATA),
    .PREADY   (intf.PREADY),
    .PSLVERR  (intf.PSLVERR)
);

  initial begin
    uvm_config_db#(virtual apb_if)::set(null,"*","vif",intf); 
  end
  
  initial begin
    run_test();
    #100; $finish;
  end
endmodule
