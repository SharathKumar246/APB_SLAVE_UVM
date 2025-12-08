`include "defines.sv"
class apb_subscriber extends uvm_component;
  `uvm_component_utils(apb_subscriber)
  apb_sequence_item t1,t2;
  real ip_cov,op_cov;
  
  uvm_tlm_analysis_fifo #(apb_sequence_item) ip_fifo;
  uvm_tlm_analysis_fifo #(apb_sequence_item) op_fifo;

  covergroup input_cov;
    ENABLE :coverpoint t1.PENABLE{ bins enable ={0,1};}

    WRITE_READ:coverpoint  t1.PWRITE { bins write ={1};
                                       bins read  ={0};}

    SLAVE: coverpoint t1.PSEL { bins Slave = {0,1};}


    STRB: coverpoint t1.PSTRB {
        bins strb_none = {4'b0000};
        wildcard bins strb_0 = {4'b???1};  // bit0 = 1
        wildcard bins strb_1 = {4'b??1?};  // bit1 = 1
        wildcard bins strb_2 = {4'b?1??};  // bit2 = 1
        wildcard bins strb_3 = {4'b1???};  // bit3 = 1
        bins strb_high = {4'b1111};
    }
                                                
    APB_WRITE_DATA :coverpoint t1.PWDATA iff(t1.PWRITE){   
                      option.auto_bin_max = 5; }
    
   
   APB_ADDR : coverpoint t1.PADDR {
                      option.auto_bin_max = 5;}


   WRITE_READ_X_SLAVE : cross WRITE_READ,SLAVE; 
   WRITE_READ_X_ENABLE  : cross WRITE_READ,ENABLE;
   WRITE_READ_X_ADDR  : cross WRITE_READ,APB_ADDR;
   ADDR_X_APB_WRITE_DATA  : cross APB_ADDR,APB_WRITE_DATA;
  endgroup
  
  covergroup output_cov;
    APB_READ_DATA_OUT: coverpoint t2.PRDATA iff (~t2.PWRITE) {   
                      option.auto_bin_max = 5;}
                    
    READY: coverpoint t2.PREADY { bins ready = {1}; bins not_ready = {0};}
                                                
                                                 	 
    APB_SLVERR: coverpoint t2.PSLVERR {bins no_slave_error = {0}; bins slave_error = {1};} 
   endgroup


 function new(string name = "apb_coverage", uvm_component parent=null);
    super.new(name, parent);
    ip_fifo = new("ip_fifo", this);
    op_fifo = new("op_fifo", this);
    input_cov = new();
    output_cov = new();
  endfunction
  

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
      fork
      forever begin
        ip_fifo.get(t1);
        input_cov.sample();
      end

        forever begin
        op_fifo.get(t2);
        output_cov.sample();
      end
      join_none
  endtask
  
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    ip_cov = input_cov.get_coverage();
    op_cov = output_cov.get_coverage();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("[I/P] Coverage : %0.2f%%", ip_cov), UVM_MEDIUM);
    `uvm_info(get_type_name(), $sformatf("[O/P] Coverage : %0.2f%%", op_cov), UVM_MEDIUM);
  endfunction 
endclass
