# Assignment 3
Command	Trigger	Loop:	A	CDC	Pulse-Swallowing	
Case	Study	-	A	command	is	generated	in	one	clock	domain	
and	must	reliably	cause	exactly	one	action	in	another	unrelated	
clock	domain;	first	show	why	the	obvious	solution	loses	
commands,	then	design	and	verify	a	CDC	mechanism	that	
preserves	the	events.	

## Author:
Anish Dey, ETCE UG'27, 002310701010

## File Structure

```text
/home/synopsis/anish_eda_assgn/
├── src/
│   ├── sync_2ff.sv
│   ├── cmd_trigger_naive.sv
│   ├── cmd_trigger_fixed.sv
│   └── tb_cmd_trigger.sv
├── scripts/
│   ├── cmd_trigger.sdc
│   ├── dump.tcl
│   ├── run_lint.sh
│   ├── run_sim.sh
│   ├── run_dc.tcl
│   ├── run_synth.sh
│   ├── run_pt.tcl
│   └── run_sta.sh
├── lint/    (naive/, fixed/)
├── sim/     (naive/, fixed/)
├── synth/
└── sta/
```

## Commands

Make the shell scripts executable first:
```bash
chmod +x /home/synopsis/anish_eda_assgn/scripts/*.sh
```
Then run any stage (add --gui or -g to open Verdi, Design Vision, or PrimeTime GUI):
```bash
./scripts/run_lint.sh naive
```
```bash
./scripts/run_lint.sh fixed --gui
```
```bash
./scripts/run_sim.sh naive --gui
```
```bash
./scripts/run_sim.sh fixed --gui
```
```bash
./scripts/run_synth.sh --gui
```
```bash
./scripts/run_sta.sh --gui
```