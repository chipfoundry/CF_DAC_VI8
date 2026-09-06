`timescale 1ns / 1ps

// Self-check for the ideal CF_DAC_VI8 behavioral core.
// Instantiates the customer wrap so the sim file list matches integration.

module tb_CF_DAC_VI8;
    integer errors;

    reg clk;
    reg reset;
    reg pd;
    reg enable;
    reg enable_hv;
    reg mode;
    reg current_off;
    reg iout_sel;
    reg hs;
    reg [1:0] range;
    reg [7:0] data;
    reg [7:0] cal;
    reg [4:0] test_sel;
    reg vref;
    reg vpwr;
    reg vgnd;
    reg vpwra;
    reg vpump;

    wire dac_vout;
    wire dac_iout;
    wire dac_iout_int;
    wire ibias = 1'b1;
    wire iref = 1'b1;
    wire vhv = 1'b1;
    wire test_io;

    CF_DAC_VI8 u_dac (
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
        .vpump(vpump),
        .vpwra(vpwra),
        .vpwr(vpwr),
        .vref(vref)
    );

    initial clk = 1'b0;
    always #50 clk = ~clk;

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task expect_v;
        input real got;
        input real exp;
        input real tol;
        input [8*32-1:0] tag;
        begin
            if (got < exp - tol || got > exp + tol) begin
                $display("FAIL %s got=%g exp=%g", tag, got, exp);
                errors = errors + 1;
            end else begin
                $display("PASS %s %g", tag, got);
            end
        end
    endtask

    initial begin
        errors = 0;
        reset = 1'b1;
        pd = 1'b0;
        enable = 1'b0;
        enable_hv = 1'b1;
        mode = 1'b0;
        current_off = 1'b0;
        iout_sel = 1'b0;
        hs = 1'b0;
        range = 2'b00;
        data = 8'd0;
        cal = 8'd0;
        test_sel = 5'd0;
        vref = 1'b1;
        vpwr = 1'b1;
        vgnd = 1'b0;
        vpwra = 1'b1;
        vpump = 1'b1;
        u_dac.u_core.vref_v = 0.256;

        repeat (2) tick;
        reset = 1'b0;
        enable = 1'b1;

        data = 8'd0;
        tick;
        expect_v(u_dac.u_core.dac_vout_v, 0.0, 1e-6, "vdac code0");

        data = 8'd255;
        tick;
        expect_v(u_dac.u_core.dac_vout_v, 1.024, 1e-6, "vdac 1V FS");
        if (dac_vout !== 1'b1) begin
            $display("FAIL vdac pin not driven");
            errors = errors + 1;
        end

        data = 8'd128;
        tick;
        expect_v(u_dac.u_core.dac_vout_v, 128.0 / 255.0 * 1.024, 1e-9, "vdac mid");

        range = 2'b01;
        data = 8'd255;
        tick;
        expect_v(u_dac.u_core.dac_vout_v, 4.096, 1e-6, "vdac 4V FS");

        mode = 1'b1;
        range = 2'b00;
        data = 8'd255;
        tick;
        expect_v(u_dac.u_core.dac_iout_a, 32.0e-6, 1e-12, "idac 32u FS");
        expect_v(u_dac.u_core.dac_vout_v, 0.0, 1e-12, "idac vout idle");
        if (dac_iout !== 1'b1) begin
            $display("FAIL idac pin not driven");
            errors = errors + 1;
        end

        range = 2'b01;
        tick;
        expect_v(u_dac.u_core.dac_iout_a, 256.0e-6, 1e-12, "idac 256u FS");

        range = 2'b10;
        tick;
        expect_v(u_dac.u_core.dac_iout_int_a, 2.04e-3, 1e-12, "idac 2m FS");
        expect_v(u_dac.u_core.dac_iout_a, 0.0, 1e-12, "idac 2m pin idle");

        iout_sel = 1'b1;
        range = 2'b00;
        tick;
        expect_v(u_dac.u_core.dac_iout_a, -32.0e-6, 1e-12, "idac sink");

        current_off = 1'b1;
        #1;
        expect_v(u_dac.u_core.dac_iout_a, 0.0, 1e-12, "current_off");
        current_off = 1'b0;
        iout_sel = 1'b0;

        reset = 1'b1;
        #1;
        expect_v(u_dac.u_core.dac_vout_v, 0.0, 1e-12, "reset v");
        expect_v(u_dac.u_core.dac_iout_a, 0.0, 1e-12, "reset i");
        reset = 1'b0;
        tick;

        pd = 1'b1;
        #1;
        expect_v(u_dac.u_core.dac_iout_a, 0.0, 1e-12, "pd");

        if (errors == 0)
            $display("CF_DAC_VI8 behavioral self-check passed");
        else
            $display("CF_DAC_VI8 behavioral self-check FAILED %0d", errors);
        $finish(errors != 0);
    end
endmodule
