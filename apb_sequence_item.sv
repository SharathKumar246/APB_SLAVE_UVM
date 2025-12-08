`include "defines.sv"
class apb_sequence_item extends uvm_sequence_item;
  rand bit PSEL;
  rand bit PENABLE;
  rand bit PWRITE; 
  rand logic [`ADDR_WIDTH-1:0] PADDR;
  rand logic [`DATA_WIDTH-1:0] PWDATA;
  rand bit [`STRB_WIDTH-1:0] PSTRB;
  logic [`DATA_WIDTH-1:0] PRDATA;
  logic PSLVERR;
  bit PREADY;

  function new(string name="apb_sequence_item");
    super.new(name);
  endfunction
  
  `uvm_object_utils_begin(apb_sequence_item)
    `uvm_field_int(PSEL,UVM_ALL_ON);
    `uvm_field_int(PENABLE,UVM_ALL_ON);
    `uvm_field_int(PWRITE,UVM_ALL_ON);
    `uvm_field_int(PADDR,UVM_ALL_ON);
    `uvm_field_int(PWDATA,UVM_ALL_ON);
    `uvm_field_int(PSTRB,UVM_ALL_ON);
    `uvm_field_int(PRDATA,UVM_ALL_ON);
    `uvm_field_int(PSLVERR,UVM_ALL_ON);
    `uvm_field_int(PREADY,UVM_ALL_ON);
  `uvm_object_utils_end 

endclass
