interface apb_assertions (
  input logic PCLK,
  input logic PRESETn,
  input logic PSEL,
  input logic PENABLE,
  input logic PWRITE,
  input logic [`ADDR_WIDTH-1:0] PADDR,
  input logic [`DATA_WIDTH-1:0] PWDATA,
  input logic [`STRB_WIDTH-1:0] PSTRB,
  input logic [`DATA_WIDTH-1:0] PRDATA,
  input logic PREADY,
  input logic PSLVERR
);

  property pclk_valid_check;//1
    @(posedge PCLK) !$isunknown(PCLK);
  endproperty
  assert_pclk_valid: assert property (pclk_valid_check)
    else $error("[ASSERTION] Clock signal is unknown at time %0t", $time);

  property presetn_valid_check;//2
    @(posedge PCLK) !$isunknown(PRESETn);
  endproperty
  assert_presetn_valid: assert property (presetn_valid_check)
    else $error("[ASSERTION] Reset signal is unknown at time %0t", $time);

  property psel_valid_check;//3
    @(posedge PCLK) disable iff (!PRESETn) !$isunknown(PSEL);
  endproperty
  assert_psel_valid: assert property (psel_valid_check)
    else $error("[ASSERTION] PSEL signal is unknown at time %0t", $time);

  property penable_valid_check;//4
    @(posedge PCLK) disable iff (!PRESETn) !$isunknown(PENABLE);
  endproperty
  assert_penable_valid: assert property (penable_valid_check)
    else $error("[ASSERTION] PENABLE signal is unknown at time %0t", $time);

  property pwrite_valid_check;//5
    @(posedge PCLK) disable iff (!PRESETn) !$isunknown(PWRITE);
  endproperty
  assert_pwrite_valid: assert property (pwrite_valid_check)
    else $error("[ASSERTION] PWRITE signal is unknown at time %0t", $time);

  property paddr_valid_check;//6
    @(posedge PCLK) disable iff (!PRESETn) !$isunknown(PADDR);
  endproperty
  assert_paddr_valid: assert property (paddr_valid_check)
    else $error("[ASSERTION] PADDR signal is unknown at time %0t", $time);

  property pwdata_valid_check;//7
    @(posedge PCLK) disable iff (!PRESETn) !$isunknown(PWDATA);
  endproperty
  assert_pwdata_valid: assert property (pwdata_valid_check)
    else $error("[ASSERTION] PWDATA signal is unknown at time %0t", $time);

  property pstrb_valid_check;//8
    @(posedge PCLK) disable iff (!PRESETn) !$isunknown( PSTRB);
  endproperty
  assert_pstrb_valid: assert property (pstrb_valid_check)
    else $error("[ASSERTION] PSTRB signal is unknown at time %0t", $time);


  property setup_access_phase_check;//9
    @(posedge PCLK) disable iff (!PRESETn) (PSEL && !PENABLE) |=> (PSEL && PENABLE);
  endproperty
  setup_access_phase: assert property (setup_access_phase_check)
    else $warning("[ASSERTION] PSEL should be followed by PENABLE in next cycle at time %0t", $time);

  // property pwrite_psel_check;
  //   @(posedge PCLK) disable iff (!PRESETn) PWRITE |-> PSEL;
  // endproperty
  // pwrite_psel: assert property (pwrite_psel_check)
  //   else $error("[ASSERTION] PWRITE should only occur when PSEL is asserted at time %0t", $time);

  property no_wait_states_check;//10
    @(posedge PCLK) disable iff (!PRESETn) (PSEL && PENABLE) |=> PREADY;
  endproperty
  no_wait_states: assert property (no_wait_states_check)
    else $error("[ASSERTION] PREADY is not asserted during access phase at time %0t", $time);

  // property presetn_hold_check;
  //   @(posedge PCLK) $fell(PRESETn) |=> $stable(PRDATA) && $stable(PSLVERR);
  // endproperty
  // presetn_hold: assert property (presetn_hold_check)
  //   else $error("[ASSERTION] Outputs changed after reset deassertion at time %0t", $time);

  property psel_stable_check;//11
    @(posedge PCLK) disable iff (!PRESETn) (PSEL && !PENABLE) |=> PSEL;
  endproperty
  psel_stable: assert property (psel_stable_check)
    else $error("[ASSERTION] PSEL should remain stable during setup phase at time %0t", $time);

  property prdata_valid_check;//12
    @(posedge PCLK) disable iff (!PRESETn) (PSEL && PENABLE && !PWRITE && PREADY) |=>  !$isunknown(PRDATA);
  endproperty
  prdata_valid: assert property (prdata_valid_check)
    else $error("[ASSERTION] PRDATA should be valid after read access at time %0t", $time);

  property pslverr_valid_check;//13
    @(posedge PCLK) disable iff (!PRESETn) (PSEL && PENABLE && PREADY) |->  !$isunknown(PSLVERR);
  endproperty
  pslverr_valid: assert property (pslverr_valid_check)
    else $error("[ASSERTION] PSLVERR should be valid during access phase at time %0t", $time);

   property no_new_input_during_access_check;//14
      @(posedge PCLK) disable iff (!PRESETn)
        (PSEL && PENABLE) |-> $stable(PSEL) and 
                $stable(PWRITE) and
                $stable(PADDR) and
                $stable(PWDATA);
    endproperty 
  no_new_input_during_access: assert property (no_new_input_during_access_check)
    else $error("[ASSERTION] APB signals changed during access phase at time %0t", $time);
endinterface
