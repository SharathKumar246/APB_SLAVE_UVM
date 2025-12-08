`include"uvm_macros.svh"
class apb_write_sequence extends uvm_sequence #(apb_sequence_item);
  `uvm_object_utils(apb_write_sequence)
   int no_of_trans;

  function new(string name="apb_write_sequence");
    super.new(name);
  endfunction
 
  virtual task body();
    int count, data;
    apb_sequence_item item;
    if (!$value$plusargs("no_of_trans=%d", no_of_trans)) begin
      no_of_trans = 10; // default value 
    end
    repeat (no_of_trans) begin
      item = apb_sequence_item::type_id::create("write_item");
      start_item(item);
      item.randomize() with {PSEL == 1; PENABLE == 0; PWRITE == 1; PADDR == count; PWDATA == data;};
      `uvm_info(get_type_name(), $sformatf("[%0t] Write Transaction %0d: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d, PWDATA=%0d PSTRB=%0b", $time, count, item.PSEL, item.PENABLE, item.PWRITE, item.PADDR, item.PWDATA, item.PSTRB), UVM_LOW);
      finish_item(item);
     
      count++;//0,1,2,3...
      data++;//0,1,2,3...
    end
  endtask
endclass

class apb_read_sequence extends uvm_sequence #(apb_sequence_item);
  `uvm_object_utils(apb_read_sequence)
    int no_of_trans;
  function new(string name="apb_read_sequence");
    super.new(name);
  endfunction
 
  virtual task body();
    int count;
    apb_sequence_item item;
    if (!$value$plusargs("no_of_trans=%d", no_of_trans)) begin
      no_of_trans = 10; // default value 
    end
    repeat (no_of_trans) begin
      item = apb_sequence_item::type_id::create("read_item");
      start_item(item);
      item.randomize() with {PSEL == 1; PENABLE == 0; PWRITE == 0; PADDR == count;};
      `uvm_info(get_type_name(), $sformatf("[%0t] Read Transaction %0d: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d", $time, count, item.PSEL, item.PENABLE, item.PWRITE, item.PADDR), UVM_LOW);
      finish_item(item);
      count++;
    end
  endtask
endclass

class apb_write_read_sequence extends uvm_sequence #(apb_sequence_item);
  `uvm_object_utils(apb_write_read_sequence)
  int no_of_trans;
  function new(string name="apb_write_read_sequence");
    super.new(name);
  endfunction
 
  virtual task body();
    int count, data;
    apb_sequence_item item;
    if (!$value$plusargs("no_of_trans=%d", no_of_trans)) begin
      no_of_trans = 10; // default value 
    end
    repeat (no_of_trans) begin  //,make it as plusargs
      item = apb_sequence_item::type_id::create("write_item");
      start_item(item);
      item.randomize() with {PSEL == 1; PENABLE == 0; PWRITE == 1; PADDR == count;}; //PWDATA == data;};
      `uvm_info(get_type_name(), $sformatf("[%0t]------------------------------------------------------------------------------------", $time), UVM_LOW);
      `uvm_info(get_type_name(), $sformatf("[%0t] Write Transaction %0d: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d, PWDATA=%0h PSTRB=%0b", $time, count, item.PSEL, item.PENABLE, item.PWRITE, item.PADDR, item.PWDATA, item.PSTRB), UVM_LOW);
      finish_item(item);
     
      item = apb_sequence_item::type_id::create("read_item");
      start_item(item);
      item.randomize() with {PSEL == 1; PENABLE == 0; PWRITE == 0; PADDR == count;};
      `uvm_info(get_type_name(), $sformatf("[%0t] Read Transaction %0d: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d", $time, count, item.PSEL, item.PENABLE, item.PWRITE, item.PADDR), UVM_LOW);
      finish_item(item);
      count++;
      // if(count >= 512 ) // to avoid address overflow and to toggle from addr[8]=1 to addr[8]=0 and addr_valid [0->1]
      //    count = 0;
      // data++;
    end
  endtask
 
endclass

class apb_slverr_sequence extends uvm_sequence #(apb_sequence_item);
  `uvm_object_utils(apb_slverr_sequence)
  function new(string name="apb_slverr_sequence");
    super.new(name);
  endfunction
 
  virtual task body();
      apb_sequence_item item;
     
      item = apb_sequence_item::type_id::create("slv_write_item 1");
      start_item(item);
      item.randomize() with {PSEL == 1; PENABLE == 0; PWRITE == 1; PADDR == 0; PSTRB == '1;};
      item.PWDATA = 'dx;
      `uvm_info(get_type_name(), $sformatf("[%0t]------------------------------------------------------------------------------------", $time), UVM_LOW);
      `uvm_info(get_type_name(), $sformatf("[%0t] SLVERR write Transaction [addr=0, data=x ]: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d, PWDATA=%0h PSTRB=%0b", $time, item.PSEL, item.PENABLE, item.PWRITE, item.PADDR, item.PWDATA, item.PSTRB), UVM_LOW);
      finish_item(item);

      item = apb_sequence_item::type_id::create("slv_read_item");
      start_item(item);
      item.randomize() with {PSEL == 1; PENABLE == 0; PWRITE == 0; PADDR == 0;};
      `uvm_info(get_type_name(), $sformatf("[%0t] SLVERR Read Transaction [addr=0 (where data=x)]: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d", $time, item.PSEL, item.PENABLE, item.PWRITE, item.PADDR), UVM_LOW);
      finish_item(item);

      item = apb_sequence_item::type_id::create("slv_write_item 2");
      start_item(item);
      item.randomize() with {PSEL == 1; PENABLE == 0; PWRITE == 1; PSTRB == '1;};
      item.PADDR = 'dx;
      `uvm_info(get_type_name(), $sformatf("[%0t]------------------------------------------------------------------------------------", $time), UVM_LOW);
      `uvm_info(get_type_name(), $sformatf("[%0t] SLVERR write Transaction [addr=x]: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d, PWDATA=%0h PSTRB=%0b", $time, item.PSEL, item.PENABLE, item.PWRITE, item.PADDR, item.PWDATA, item.PSTRB), UVM_LOW);
      finish_item(item);
      
      item = apb_sequence_item::type_id::create("slv_read_item 1");
      start_item(item);
      item.randomize() with {PSEL == 1; PENABLE == 0; PWRITE == 0;};
      item.PADDR = 'dx;
      `uvm_info(get_type_name(), $sformatf("[%0t] SLVERR read Transaction [addr=x]: PSEL=%0b, PENABLE=%0b, PWRITE=%0b, PADDR=%0d", $time, item.PSEL, item.PENABLE, item.PWRITE, item.PADDR), UVM_LOW);
      finish_item(item);

  endtask
endclass
