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

OUT_DIR="$ROOT_DIR/lint/$DESIGN"
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

vcs -full64 -sverilog -lint=all -kdb -debug_access+all \
    "$ROOT_DIR/src/sync_2ff.sv" \
    "$ROOT_DIR/src/cmd_trigger_${DESIGN}.sv" \
    "$ROOT_DIR/src/tb_cmd_trigger.sv" \
    -o simv_lint \
    -l vcs_lint.log

if [ "$GUI" -eq 1 ]; then
    verdi -dbdir simv_lint.daidir &
fi
