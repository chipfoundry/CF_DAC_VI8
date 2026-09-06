# CF_DAC_VI8 behavioral model

Ideal functional model for digital simulation. It is **not** SPICE-accurate
and it is **not** a silicon protocol dump. Use it to exercise firmware and
SoC wrappers. Do not add this file to OpenLane `VERILOG_FILES`.

## Files

| File | Replaces |
|---|---|
| `CF_DAC_VI8_core.v` | `hdl/gl/CF_DAC_VI8_core.v` |

Keep the customer wrap in `hdl/gl/CF_DAC_VI8.v`. Do **not** compile the empty
`hdl/gl/CF_DAC_VI8_core.v` stub in the same sim (duplicate module name).

```bash
./verify/beh_model/run_tb.sh
```

## Analog stimulus

Public analog pins are 1-bit nets. Voltages and currents live on Verilog
`real` backdoors inside the core:

```verilog
u_dac.u_core.vref_v = 0.256;   // 4*vref → 1.024 V, 16*vref → 4.096 V
// after a clock: u_dac.u_core.dac_vout_v
//                u_dac.u_core.dac_iout_a
//                u_dac.u_core.dac_iout_int_a
```

Digital `dac_vout` / `dac_iout` / `dac_iout_int` are 1 when the matching
real is above a small presence threshold.

## Assumed protocol

`data[7:0]` is sampled on `posedge clk` while `reset` is low, `pd` is low,
and `enable` / `enable_hv` are high.

- `mode=0` voltage DAC. `range[0]=0` full-scale `4*vref_v`; `range[0]=1`
  full-scale `16*vref_v`. Code 255 maps to full-scale.
- `mode=1` current DAC. `range` `00` / `01` / `10` → 32 µA / 256 µA /
  2.04 mA. The 2.04 mA range uses `dac_iout_int`; the others use `dac_iout`.
- `iout_sel=1` inverts current (sink). `current_off` forces 0 A.
- `reset` or `pd` forces 0 V / 0 A.

`cal`, `hs`, `test_sel`, pump, and analog accuracy are ignored.
