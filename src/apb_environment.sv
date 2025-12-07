class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)
  apb_passive_agent passive_agent;
  apb_active_agent active_agent;
  apb_scoreboard scoreboard;
  apb_subscriber subscriber;

  function new(string name="apb_env",uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    passive_agent = apb_passive_agent::type_id::create("passive_agent", this);
    active_agent = apb_active_agent::type_id::create("active_agent", this);
    scoreboard = apb_scoreboard::type_id::create("scoreboard", this);
    subscriber = apb_subscriber::type_id::create("subscriber", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    passive_agent.passive_monitor.mon_port.connect(scoreboard.op_fifo.analysis_export);
    passive_agent.passive_monitor.mon_port.connect(subscriber.op_fifo.analysis_export);
    active_agent.active_monitor.mon_port.connect(scoreboard.ip_fifo.analysis_export);
    active_agent.active_monitor.mon_port.connect(subscriber.ip_fifo.analysis_export);
  endfunction

endclass


