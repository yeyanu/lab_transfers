set root_dir       "/home/synopsis/anish_eda_assgn"
set target_library "/home/synopsis/SYNOPSYS_LIBRARY/NangateOpenCellLibrary_fast.db"
set link_library   [concat "*" $target_library]

set timing_disable_recovery_removal_checks false

read_verilog "$root_dir/synth/cmd_trigger_fixed_netlist.v"
current_design cmd_trigger_top
link
read_sdc "$root_dir/synth/cmd_trigger_fixed_out.sdc"

report_exceptions > pt_exceptions.rpt
report_timing -from [get_clocks clkA] -to [get_clocks clkB] > pt_cdc_a2b.rpt
report_timing -from [get_clocks clkB] -to [get_clocks clkA] > pt_cdc_b2a.rpt

report_timing -delay_type max > pt_setup.rpt
report_timing -delay_type min > pt_hold.rpt

report_timing -from [get_ports rstA_n] -to [all_registers -clock clkA] -delay_type max > pt_rstA_recovery.rpt
report_timing -from [get_ports rstA_n] -to [all_registers -clock clkA] -delay_type min > pt_rstA_removal.rpt
report_timing -from [get_ports rstB_n] -to [all_registers -clock clkB] -delay_type max > pt_rstB_recovery.rpt
report_timing -from [get_ports rstB_n] -to [all_registers -clock clkB] -delay_type min > pt_rstB_removal.rpt

if {[info exists env(PT_GUI)] && $env(PT_GUI) eq "1"} {
    start_gui
} else {
    exit
}
