class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)
  apb_sequence_item ip_trans, op_trans;
  virtual apb_if vif;

  int write_transactions;
  int read_transactions;
  int passed_transactions;
  int failed_transactions;
  int slave_error_pass;
  int slave_error_fail;
  logic [`DATA_WIDTH-1:0] prev_result;

  uvm_tlm_analysis_fifo #(apb_sequence_item) ip_fifo;
  uvm_tlm_analysis_fifo #(apb_sequence_item) op_fifo;

  bit [`DATA_WIDTH-1:0] expected; 
  bit [`DATA_WIDTH-1:0] slave_memory [0:`MEM_DEPTH-1];



  function new(string name="apb_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    ip_fifo = new("ip_fifo", this);
    op_fifo = new("op_fifo", this);
    passed_transactions = 0;
    failed_transactions = 0;
    slave_error_pass = 0;
    slave_error_fail = 0;
    prev_result = '0;
    expected = '0;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "No virtual interface found");
    end
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin

      ip_fifo.get(ip_trans);
      `uvm_info(get_type_name(), $sformatf("[%0t] SB: Received INPUT: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0h, PWDATA=%0h PSTRB=%0b", $time, ip_trans.PSEL, ip_trans.PENABLE, ip_trans.PWRITE, ip_trans.PADDR, ip_trans.PWDATA, ip_trans.PSTRB), UVM_LOW);
      op_fifo.get(op_trans);
        `uvm_info(get_type_name(), $sformatf("[%0t] SB: Received OUTPUT: PRDATA=%0h, PREADY=%0b, PSLVERR=%0b", $time, op_trans.PRDATA, op_trans.PREADY, op_trans.PSLVERR), UVM_LOW);

      if (ip_trans.PWRITE) begin // WRITE transaction
        write_transactions++;
          if (!(ip_trans.PADDR < `MEM_DEPTH)) begin
            if (op_trans.PSLVERR) begin
              `uvm_info(get_type_name(), $sformatf("[%0t] SB: SLVERR MATCH on write: PADDR=%0h PWDATA=%0h Expected=1 Actual=%0h", $time, ip_trans.PADDR, ip_trans.PWDATA, op_trans.PSLVERR), UVM_LOW);
              slave_error_pass++;
            end else begin
              `uvm_info(get_type_name(), $sformatf("[%0t] SB: SLVERR MISMATCH on write: PADDR=%0h PWDATA=%0h Expected=1 Actual=%0h", $time, ip_trans.PADDR, ip_trans.PWDATA, op_trans.PSLVERR), UVM_LOW);
              slave_error_fail++;
            end
          end else begin//NO slverr then write to memory
            // Apply PSTRB masking for byte-lane writes
            if(ip_trans.PSTRB === '0) begin
              `uvm_info(get_type_name(), $sformatf("[%0t] SB: PSTRB is zero, no write performed for PADDR=%0h", $time, ip_trans.PADDR), UVM_LOW);
            end
            else begin
              for (int i = 0; i < `STRB_WIDTH; i++) begin
                if (ip_trans.PSTRB[i]) begin
                  slave_memory[ip_trans.PADDR][(i*8) +: 8] = ip_trans.PWDATA[(i*8) +: 8];
                  `uvm_info(get_type_name(), $sformatf("[%0t] SB: Writing byte lane %0d: PADDR=%0h Data=%0h", $time, i, ip_trans.PADDR, ip_trans.PWDATA[(i*8) +: 8]), UVM_LOW);
                end
             end
            `uvm_info(get_type_name(), $sformatf("[%0t] SB: WRITING PADDR=%0h PWDATA=%0h PSTRB=%0b", $time, ip_trans.PADDR, ip_trans.PWDATA, ip_trans.PSTRB), UVM_LOW);
          end
        end
       end
       else begin // READ transaction
        read_transactions++;
         if (!(ip_trans.PADDR < `MEM_DEPTH)) begin
          if (op_trans.PSLVERR) begin
              `uvm_info(get_type_name(), $sformatf("[%0t] SB: SLVERR MATCH on read: paddr=%0h Expected=1 Actual=%0h", $time, ip_trans.PADDR, op_trans.PSLVERR), UVM_LOW);
              slave_error_pass++;
            end else begin
              `uvm_info(get_type_name(), $sformatf("[%0t] SB: SLVERR MISMATCH on read: paddr=%0h Expected=1 Actual=%0h", $time, ip_trans.PADDR, op_trans.PSLVERR), UVM_LOW);
              slave_error_fail++;
            end
          end else begin//NO slverr then check read data
            
            expected = slave_memory[ip_trans.PADDR];

            if (op_trans.PRDATA === expected) begin
              `uvm_info(get_type_name(), $sformatf("[%0t] ||||SB: READ MATCH PADDR=%0h Expected=%0h Actual=%0h ||||", $time, ip_trans.PADDR, expected, op_trans.PRDATA), UVM_LOW);
              passed_transactions++;
              prev_result = op_trans.PRDATA;
            end else begin
              `uvm_info(get_type_name(), $sformatf("[%0t]|||| SB: READ MISMATCH PADDR=%0h Expected=%0h Actual=%0h ||||", $time, ip_trans.PADDR, expected, op_trans.PRDATA), UVM_LOW);
              failed_transactions++;
            end
          end
        end
      end
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Write Transactions: %0d",write_transactions ), UVM_LOW);
    `uvm_info(get_type_name(), $sformatf("Read Transactions: %0d", read_transactions), UVM_LOW);
    `uvm_info(get_type_name(), $sformatf("Total Transactions: %0d", write_transactions + read_transactions), UVM_LOW);
    `uvm_info(get_type_name(), $sformatf("Passed Transactions: %0d", passed_transactions), UVM_LOW);
    `uvm_info(get_type_name(), $sformatf("Failed Transactions: %0d", failed_transactions), UVM_LOW);
    `uvm_info(get_type_name(), $sformatf("Slave Error Pass: %0d", slave_error_pass), UVM_LOW);
    `uvm_info(get_type_name(), $sformatf("Slave Error Fail: %0d", slave_error_fail), UVM_LOW);
  endfunction
endclass


