class apb_passive_monitor extends uvm_monitor;
    `uvm_component_utils(apb_passive_monitor)
    virtual apb_if vif;
    uvm_analysis_port#(apb_sequence_item) mon_port;
    apb_sequence_item mon_trans;
    
  function new(string name="apb_passive_monitor", uvm_component parent=null);
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
		@(posedge vif.PRESETn);
    @(posedge vif.PCLK);
    $display("Time=%0t Monitor: Reset De-asserted",$time);

	  forever begin	
      @(posedge vif.pas_mon_cb);
      wait(vif.PSEL && vif.PENABLE && vif.PREADY)begin
        @(posedge vif.pas_mon_cb);
      monitor_dut();
      mon_port.write(mon_trans);
      end
   end
   
  endtask             
         
  virtual task monitor_dut();
    // mon_trans.PRDATA = vif.pas_mon_cb.PRDATA;
    // mon_trans.PREADY = vif.pas_mon_cb.PREADY;
    // mon_trans.PSLVERR = vif.pas_mon_cb.PSLVERR;
    
    mon_trans.PRDATA = vif.PRDATA;
    mon_trans.PREADY = vif.PREADY;
    mon_trans.PSLVERR = vif.PSLVERR;
    `uvm_info(get_type_name(), $sformatf("[%0t] Captured Outputs: PRDATA=%0d, PREADY=%0b, PSLVERR=%0b", $time, mon_trans.PRDATA, mon_trans.PREADY, mon_trans.PSLVERR), UVM_LOW);
  endtask
endclass
