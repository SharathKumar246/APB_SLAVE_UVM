class apb_driver extends uvm_driver#(apb_sequence_item);
 `uvm_component_utils(apb_driver)
	virtual apb_if vif;
	apb_sequence_item drv_trans;

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif)) begin
      `uvm_fatal("NOVIF","No virtual interface found")
    end
  endfunction
  
	virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
	    if(!vif.PRESETn)begin// wait until reset is de-asserted then drive inputs
				`uvm_info(get_type_name(),$sformatf("[%0t] DUT is in RESET=%0b !!!",$time,vif.PRESETn),UVM_LOW)
				@(posedge vif.PRESETn);
		end
		@(posedge vif.drv_cb);
		forever begin
			seq_item_port.get_next_item(drv_trans);
			drive();
			seq_item_port.item_done();
		end
  endtask

	task drive();
	//ideal state

	vif.PSEL    <= 0;
	vif.PENABLE <= 0;

  	// Setup phase
    @(posedge vif.drv_cb);

    vif.PSEL    <= drv_trans.PSEL;
    vif.PENABLE <= 0;
    vif.PWRITE  <= drv_trans.PWRITE;
    vif.PADDR   <= drv_trans.PADDR;
    vif.PWDATA  <= drv_trans.PWDATA;
    vif.PSTRB   <= drv_trans.PSTRB;
	`uvm_info(get_type_name(), $sformatf("[%0t] Driving Signals[SETUP]: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d, PWDATA=%0d PSTRB=%0b", $time, drv_trans.PSEL, drv_trans.PENABLE, drv_trans.PWRITE, drv_trans.PADDR, drv_trans.PWDATA, drv_trans.PSTRB), UVM_LOW);

    // Access phase
    @(posedge vif.drv_cb);
    vif.PENABLE <= 1;
	`uvm_info(get_type_name(), $sformatf("[%0t] Driving Signals[ACCESS]: PENABLE <= 1", $time), UVM_LOW);


    // Wait for slave response
	@(posedge vif.drv_cb);
	
    while (!vif.PREADY)begin
    @(posedge vif.drv_cb);
	`uvm_info(get_type_name(), $sformatf("[%0t] Waiting for PREADY signal...", $time), UVM_LOW);
	end

	// vif.PENABLE <= 0;

endtask
  
endclass

