interface apb_if(input bit PCLK, input bit PRESETn);
	bit PSEL;
  bit PENABLE;
	bit PWRITE;
  bit [`ADDR_WIDTH-1:0] PADDR;
  bit [`DATA_WIDTH-1:0] PWDATA;
  bit [`DATA_WIDTH-1:0] PRDATA;
  bit  [`STRB_WIDTH-1:0] PSTRB;
 bit PSLVERR;
  bit PREADY;



  clocking drv_cb @(posedge PCLK);
    input PRESETn;
    input PREADY;
		output PSEL;
    output PENABLE;
    output PWRITE;
    output PADDR;
    output PWDATA;
    output PSTRB;
  endclocking 
  
  clocking act_mon_cb @(posedge PCLK);
    input PRESETn;
		input PSEL;
    input PENABLE;
    input PWRITE;
    input PADDR;
    input PWDATA;
    input PSTRB;
  endclocking

  clocking pas_mon_cb @(posedge PCLK);
    input PRESETn;
    input PSEL;
    input PENABLE;
    input PSLVERR;
		input PREADY;
    input PRDATA;
  endclocking

  clocking sb_cb @(posedge PCLK);
    input PRESETn;
		input PSEL;
    input PENABLE;
    input PWRITE;
    input PADDR;
    input PWDATA;
    input PSTRB;
    input PSLVERR;
		input PREADY;
    input PRDATA;
  endclocking 

  /*modport DRV(clocking drv_cb);
  modport ACT_MON(clocking act_mon_cb);
  modport PAS_MON(clocking pas_mon_cb);
  modport SB(clocking sb_cb);*/

endinterface

