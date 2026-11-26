#!/bin/bash
set -e

ROOT_DIR="/home/synopsis/anish_eda_assgn"
GUI=0

for arg in "$@"; do
    case "$arg" in
        --gui|-g) GUI=1 ;;
    esac
done

OUT_DIR="$ROOT_DIR/sta"
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

if [ "$GUI" -eq 1 ]; then
    PT_GUI=1 pt_shell -f "$ROOT_DIR/scripts/run_pt.tcl" | tee pt_sta.log
else
    pt_shell -f "$ROOT_DIR/scripts/run_pt.tcl" | tee pt_sta.log
fi
