// Structural PG wrapper. Analog leaf is CF_DAC_VI8_core.
// Customer rails are vpwr/vgnd; well taps vpb/vnb/vpbe are tied inside.
module CF_DAC_VI8 (
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
    vpump,
    vpwra,
    vpwr,
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
    input vpump;
    input vpwra;
    input vpwr;
    input vref;
    CF_DAC_VI8_core u_core (
        .dac_iout_int(dac_iout_int),
        .dac_iout(dac_iout),
        .dac_vout(dac_vout),
        .ibias(ibias),
        .iref(iref),
        .test_io(test_io),
        .vhv(vhv),
        .cal(cal),
        .clk(clk),
        .current_off(current_off),
        .data(data),
        .enable(enable),
        .enable_hv(enable_hv),
        .hs(hs),
        .iout_sel(iout_sel),
        .mode(mode),
        .pd(pd),
        .range(range),
        .reset(reset),
        .test_sel(test_sel),
        .vgnd(vgnd),
        .vnb(vgnd),
        .vpump(vpump),
        .vpwra(vpwra),
        .vpwrd(vpwr),
        .vref(vref)
    );
endmodule
