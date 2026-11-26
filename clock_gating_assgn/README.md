# Clock Gating Assignment
Implement a clock gating circuit in Verilog to reduce dynamic power consumption in a synchronous system. The circuit should enable or disable the clock signal based on an enable signal.

## Author:
Anish Dey, ETCE UG'27, 002310701010

## File Structure

```text
/home/synopsis/clock_gating_assgn/
├── src/
│   ├── clk_gate.sv
│   └── tb_clk_gate.sv
├── scripts/
│   ├── dump.tcl
│   ├── run_lint.sh
│   └── run_sim.sh
├── lint/
├── sim/
└── README.md
```

## Commands

Make scripts executable:
```bash
chmod +x /home/synopsis/clock_gating_assgn/scripts/*.sh
```

Run VCS lint:
```bash
./scripts/run_lint.sh
./scripts/run_lint.sh --gui
```

Run VCS simulation (and open Verdi with `--gui`):
```bash
./scripts/run_sim.sh
./scripts/run_sim.sh --gui
```