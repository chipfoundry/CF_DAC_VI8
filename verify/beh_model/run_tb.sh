#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="${TMPDIR:-/tmp}/cf_dac_vi8_tb"
iverilog -g2005 -o "$OUT" \
  "$ROOT/hdl/gl/CF_DAC_VI8.v" \
  "$ROOT/verify/beh_model/CF_DAC_VI8_core.v" \
  "$ROOT/verify/beh_model/tb_CF_DAC_VI8.v"
vvp "$OUT"
