#!/bin/bash
set -e

ROOT_DIR="/home/synopsis/anish_eda_assgn"
DESIGN="fixed"
GUI=0

for arg in "$@"; do
    case "$arg" in
        naive|fixed) DESIGN="$arg" ;;
        --gui|-g)    GUI=1 ;;
    esac
done

OUT_DIR="$ROOT_DIR/sim/$DESIGN"
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

vcs -full64 -sverilog -debug_access+all -kdb -assert enable_diag \
    "$ROOT_DIR/src/sync_2ff.sv" \
    "$ROOT_DIR/src/cmd_trigger_${DESIGN}.sv" \
    "$ROOT_DIR/src/tb_cmd_trigger.sv" \
    -o simv \
    -l vcs_compile.log

FSDB_FILE="${DESIGN}.fsdb" ./simv -ucli -i "$ROOT_DIR/scripts/dump.tcl" -l vcs_sim.log

if [ "$GUI" -eq 1 ]; then
    verdi -dbdir simv.daidir -ssf "${DESIGN}.fsdb" &
fi
