set root_dir          "/home/synopsis/anish_eda_assgn"
set target_library    "/home/synopsis/SYNOPSYS_LIBRARY/NangateOpenCellLibrary_fast.db"
set synthetic_library "/home/synopsis/SYNOPSYS_LIBRARY/dw_foundation.sldb"
set link_library      [concat "*" $target_library $synthetic_library]

analyze -format sverilog [list \
    "$root_dir/src/sync_2ff.sv" \
    "$root_dir/src/cmd_trigger_fixed.sv" \
]
elaborate cmd_trigger_top
current_design cmd_trigger_top
link
uniquify

source "$root_dir/scripts/cmd_trigger.sdc"
compile_ultra

write -format verilog -hierarchy -output cmd_trigger_fixed_netlist.v
write -format ddc     -hierarchy -output cmd_trigger_fixed.ddc
write_sdc cmd_trigger_fixed_out.sdc

report_area   > synth_area.rpt
report_timing > synth_timing.rpt
report_qor    > synth_qor.rpt

if {!([info exists env(DC_GUI)] && $env(DC_GUI) eq "1")} {
    exit
}
