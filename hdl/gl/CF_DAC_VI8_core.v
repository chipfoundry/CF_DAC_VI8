// Empty blackbox stub for hierarchical integration LVS.
module CF_DAC_VI8_core (
    dac_iout_int,
    dac_iout,
    dac_vout,
    ibias,
    iref,
    test_io,
    vhv,
    cal,
    clk,
    current_off,
    data,
    enable,
    enable_hv,
    hs,
    iout_sel,
    mode,
    pd,
    range,
    reset,
    test_sel,
    vgnd,
    vnb,
    vpump,
    vpwra,
    vpwrd,
    vref
);
    inout dac_iout_int;
    inout dac_iout;
    inout dac_vout;
    inout ibias;
    inout iref;
    inout test_io;
    inout vhv;
    input [7:0] cal;
    input clk;
    input current_off;
    input [7:0] data;
    input enable;
    input enable_hv;
    input hs;
    input iout_sel;
    input mode;
    input pd;
    input [1:0] range;
    input reset;
    input [4:0] test_sel;
    input vgnd;
    input vnb;
    input vpump;
    input vpwra;
    input vpwrd;
    input vref;
endmodule
