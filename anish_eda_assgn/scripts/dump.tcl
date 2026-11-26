set fsdb_file "sim.fsdb"
if {[info exists env(FSDB_FILE)]} {
    set fsdb_file $env(FSDB_FILE)
}
fsdbDumpfile $fsdb_file
fsdbDumpvars 0 "tb_cmd_trigger"
run
exit
