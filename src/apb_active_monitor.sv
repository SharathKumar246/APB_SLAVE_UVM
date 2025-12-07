class apb_active_monitor extends uvm_monitor;
  `uvm_component_utils(apb_active_monitor)
  virtual apb_if vif;
  uvm_analysis_port#(apb_sequence_item) mon_port;
  apb_sequence_item mon_trans;
    
  function new(string name="apb_active_monitor", uvm_component parent=null);
        super.new(name, parent);
        mon_trans = new();
        mon_port = new("mon_port", this);
  endfunction
    
  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("NOVIF", "No virtual interface found");
      end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    if(!vif.PRESETn)begin
			  @(posedge vif.PRESETn);
	  end

    forever begin
      @(posedge vif.act_mon_cb);
      wait(vif.PSEL && vif.PENABLE && vif.PREADY);
      @(posedge vif.act_mon_cb);
      monitor_dut();
      mon_port.write(mon_trans);
      `uvm_info(get_type_name(), $sformatf("[%0t] ACT_MON: Captured INPUT: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0h, PWDATA=%0h PSTRB=%0b", 
      $time, mon_trans.PSEL, mon_trans.PENABLE, mon_trans.PWRITE, mon_trans.PADDR, mon_trans.PWDATA, mon_trans.PSTRB), UVM_LOW); 
    end
endtask


task monitor_dut();
	  mon_trans.PSEL = vif.PSEL;
    mon_trans.PENABLE = vif.PENABLE;
    mon_trans.PWRITE = vif.PWRITE;
    mon_trans.PADDR = vif.PADDR;
    mon_trans.PWDATA = vif.PWDATA;
    mon_trans.PADDR = vif.PADDR;
    mon_trans.PSTRB = vif.PSTRB;
 endtask


endclass    
