bind apb_if apb_assertions apb_if_assert_inst (
  .PCLK(PCLK),
  .PRESETn(PRESETn),
  .PSEL(PSEL),
  .PENABLE(PENABLE),
  .PWRITE(PWRITE),
  .PADDR(PADDR),
  .PWDATA(PWDATA),
  .PRDATA(PRDATA),
  .PSTRB(PSTRB),
  .PREADY(PREADY),
  .PSLVERR(PSLVERR)
);
