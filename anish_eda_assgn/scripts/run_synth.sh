#!/bin/bash
set -e

ROOT_DIR="/home/synopsis/anish_eda_assgn"
GUI=0

for arg in "$@"; do
    case "$arg" in
        --gui|-g) GUI=1 ;;
    esac
done

OUT_DIR="$ROOT_DIR/synth"
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

if [ "$GUI" -eq 1 ]; then
    DC_GUI=1 design_vision -f "$ROOT_DIR/scripts/run_dc.tcl" | tee dc_synth.log
else
    dc_shell -f "$ROOT_DIR/scripts/run_dc.tcl" | tee dc_synth.log
fi
