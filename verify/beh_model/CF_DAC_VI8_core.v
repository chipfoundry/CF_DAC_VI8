`timescale 1ns / 1ps

// Ideal functional model of analog leaf CF_DAC_VI8_core.
// Drop this file in place of hdl/gl/CF_DAC_VI8_core.v for simulation.
// Do not add it to OpenLane VERILOG_FILES.
//
// Analog values are Verilog real backdoors (1-bit pins stay digital):
//   vref_v, dac_vout_v, dac_iout_a, dac_iout_int_a
//
// Assumed protocol (ideal, not silicon-verified):
//   * reset, pd, or enable/enable_hv low → 0 V / 0 A
//   * data is sampled on posedge clk when enable is high
//   * mode 0 = voltage DAC, mode 1 = current DAC
//   * VDAC range[0] 0 → 4*vref_v (~1 V if vref_v=0.256)
//                 1 → 16*vref_v (~4 V if vref_v=0.256)
//   * IDAC range 00 → 32 µA on dac_iout
//                01 → 256 µA on dac_iout
//                10 → 2.04 mA on dac_iout_int
//                11 → reserved (0)
//   * current_off Hi-Zs current outputs
//   * iout_sel 0 = source (positive), 1 = sink (negative)
// Calibration, high-speed, pump, and test mux are not modeled.

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

    localparam real VREF_DEFAULT = 0.256;
    localparam real IDAC_FS_32U  = 32.0e-6;
    localparam real IDAC_FS_256U = 256.0e-6;
    localparam real IDAC_FS_2M   = 2.04e-3;
    localparam real V_PRESENT    = 0.05;
    localparam real I_PRESENT    = 1.0e-9;

    real vref_v;
    real dac_vout_v;
    real dac_iout_a;
    real dac_iout_int_a;

    reg [7:0] data_q;
    real      vout_q;
    real      iout_q;
    real      iout_int_q;

    wire active = ~reset & ~pd & enable & enable_hv;

    initial begin
        vref_v        = VREF_DEFAULT;
        dac_vout_v    = 0.0;
        dac_iout_a    = 0.0;
        dac_iout_int_a = 0.0;
        vout_q        = 0.0;
        iout_q        = 0.0;
        iout_int_q    = 0.0;
        data_q        = 8'd0;
    end

    function real code_frac;
        input [7:0] code;
        begin
            code_frac = code / 255.0;
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_q     <= 8'd0;
            vout_q     <= 0.0;
            iout_q     <= 0.0;
            iout_int_q <= 0.0;
        end else if (active) begin
            data_q <= data;
            if (!mode) begin
                vout_q     <= code_frac(data) * (range[0] ? (16.0 * vref_v) : (4.0 * vref_v));
                iout_q     <= 0.0;
                iout_int_q <= 0.0;
            end else begin
                vout_q <= 0.0;
                case (range)
                    2'b00: begin
                        iout_q     <= (iout_sel ? -1.0 : 1.0) * code_frac(data) * IDAC_FS_32U;
                        iout_int_q <= 0.0;
                    end
                    2'b01: begin
                        iout_q     <= (iout_sel ? -1.0 : 1.0) * code_frac(data) * IDAC_FS_256U;
                        iout_int_q <= 0.0;
                    end
                    2'b10: begin
                        iout_q     <= 0.0;
                        iout_int_q <= (iout_sel ? -1.0 : 1.0) * code_frac(data) * IDAC_FS_2M;
                    end
                    default: begin
                        iout_q     <= 0.0;
                        iout_int_q <= 0.0;
                    end
                endcase
            end
        end else begin
            vout_q     <= 0.0;
            iout_q     <= 0.0;
            iout_int_q <= 0.0;
        end
    end

    always @(*) begin
        if (!active) begin
            dac_vout_v     = 0.0;
            dac_iout_a     = 0.0;
            dac_iout_int_a = 0.0;
        end else if (mode && current_off) begin
            dac_vout_v     = 0.0;
            dac_iout_a     = 0.0;
            dac_iout_int_a = 0.0;
        end else begin
            dac_vout_v     = vout_q;
            dac_iout_a     = iout_q;
            dac_iout_int_a = iout_int_q;
        end
    end

    assign dac_vout     = (active && !mode && (dac_vout_v > V_PRESENT)) ? 1'b1 : 1'bz;
    assign dac_iout     = (active && mode && !current_off && (dac_iout_a > I_PRESENT || dac_iout_a < -I_PRESENT)) ? 1'b1 : 1'bz;
    assign dac_iout_int = (active && mode && !current_off && (dac_iout_int_a > I_PRESENT || dac_iout_int_a < -I_PRESENT)) ? 1'b1 : 1'bz;
    assign test_io      = 1'bz;
endmodule
