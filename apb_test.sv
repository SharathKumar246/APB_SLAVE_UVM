class apb_write_test extends uvm_test;
  `uvm_component_utils(apb_write_test)
  apb_env env;
  apb_write_sequence seq;

  function new(string name = "apb_write_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    seq = apb_write_sequence::type_id::create("seq");
    seq.start(env.active_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass

class apb_read_test extends uvm_test;
  `uvm_component_utils(apb_read_test)
  apb_env env;
  apb_read_sequence seq;

  function new(string name = "apb_read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    seq = apb_read_sequence::type_id::create("seq");
    seq.start(env.active_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass

class apb_write_read_test  extends uvm_test;
  `uvm_component_utils(apb_write_read_test)
  apb_env env;
  apb_write_read_sequence seq;

  function new(string name = "apb_write_read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    seq = apb_write_read_sequence::type_id::create("seq");
    seq.start(env.active_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass 

class apb_write_then_read_test extends uvm_test;
  `uvm_component_utils(apb_write_then_read_test)
  apb_env env;
  apb_write_sequence write_seq;
  apb_read_sequence read_seq;

  function new(string name = "apb_write_then_read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    write_seq = apb_write_sequence::type_id::create("write_seq");
    read_seq = apb_read_sequence::type_id::create("read_seq");
        write_seq.start(env.active_agent.sequencer);
        read_seq.start(env.active_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass

class apb_corner_test extends apb_write_read_test;
  `uvm_component_utils(apb_corner_test)
  apb_slverr_sequence slverr_seq;
  
  function new(string name = "apb_corner_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    slverr_seq = apb_slverr_sequence::type_id::create("slverr_seq");
    slverr_seq.start(env.active_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass
