#!/bin/bash
set -e

ROOT_DIR="/home/synopsis/clock_gating_assgn"
GUI=0

for arg in "$@"; do
    case "$arg" in
        --gui|-g) GUI=1 ;;
    esac
done

LOCAL_LIB="$ROOT_DIR/.lib"
mkdir -p "$LOCAL_LIB"
if [ ! -e "$LOCAL_LIB/libtinfo.so" ]; then
    for cand in /usr/lib64/libtinfo.so.6 /usr/lib64/libtinfo.so.5 /lib64/libtinfo.so.6 /lib64/libtinfo.so.5 /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.5; do
        if [ -e "$cand" ]; then
            ln -sf "$cand" "$LOCAL_LIB/libtinfo.so"
            break
        fi
    done
fi

OUT_DIR="$ROOT_DIR/lint"
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

vcs -full64 -sverilog -lint=all -kdb -debug_access+all \
    -LDFLAGS "-L$LOCAL_LIB" \
    "$ROOT_DIR/src/clk_gate.sv" \
    "$ROOT_DIR/src/tb_clk_gate.sv" \
    -o simv_lint \
    -l vcs_lint.log

if [ "$GUI" -eq 1 ]; then
    verdi -dbdir simv_lint.daidir &
fi
