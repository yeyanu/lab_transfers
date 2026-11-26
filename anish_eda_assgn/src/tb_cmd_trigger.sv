`timescale 1ns/1ps

module tb_cmd_trigger;
    logic       clkA;
    logic       rstA_n;
    logic       clkB;
    logic       rstB_n;
    logic       trigger_en;
    logic       burst_mode;
    logic [7:0] exec_count;
    logic [7:0] producer_pulse_count;

    logic [7:0] p_norm;
    logic [7:0] e_norm;
    logic [7:0] p_burst;
    logic [7:0] e_burst;

    cmd_trigger_top dut (
        .clkA                 (clkA),
        .rstA_n               (rstA_n),
        .clkB                 (clkB),
        .rstB_n               (rstB_n),
        .trigger_en           (trigger_en),
        .burst_mode           (burst_mode),
        .exec_count           (exec_count),
        .producer_pulse_count (producer_pulse_count)
    );

    initial clkA = 1'b0;
    always #5.0 clkA = ~clkA;

    initial clkB = 1'b0;
    always #16.85 clkB = ~clkB;

    property p_rst_clear;
        @(posedge clkA) !rstA_n |-> (exec_count == 8'd0 && producer_pulse_count == 8'd0);
    endproperty
    assert property (p_rst_clear);

    property p_no_spurious_exec;
        @(posedge clkA) disable iff (!rstA_n)
        exec_count <= producer_pulse_count;
    endproperty
    assert property (p_no_spurious_exec);

    property p_exec_step;
        @(posedge clkA) disable iff (!rstA_n)
        (exec_count == $past(exec_count)) || (exec_count == $past(exec_count) + 8'd1);
    endproperty
    assert property (p_exec_step);

    initial begin
`ifdef DUMP_FSDB
        $fsdbDumpfile("sim.fsdb");
        $fsdbDumpvars(0, tb_cmd_trigger);
`else
        $dumpfile("sim.vcd");
        $dumpvars(0, tb_cmd_trigger);
`endif
    end

    initial begin
        rstA_n     = 1'b0;
        rstB_n     = 1'b0;
        trigger_en = 1'b0;
        burst_mode = 1'b0;

        #45 rstA_n = 1'b1;
        #38 rstB_n = 1'b1;

        repeat (5) @(posedge clkA);
        burst_mode = 1'b0;
        trigger_en = 1'b1;
        repeat (300) @(posedge clkA);
        trigger_en = 1'b0;
        repeat (40) @(posedge clkB);

        p_norm = producer_pulse_count;
        e_norm = exec_count;

        repeat (5) @(posedge clkA);
        burst_mode = 1'b1;
        trigger_en = 1'b1;
        repeat (500) @(posedge clkA);
        trigger_en = 1'b0;
        repeat (40) @(posedge clkB);

        p_burst = producer_pulse_count - p_norm;
        e_burst = exec_count - e_norm;

        $display("normal: prod=%0d exec=%0d", p_norm, e_norm);
        $display("burst:  prod=%0d exec=%0d", p_burst, e_burst);
        $display("total:  prod=%0d exec=%0d", producer_pulse_count, exec_count);

        assert (producer_pulse_count > 8'd0 && exec_count == producer_pulse_count)
            $display("PASS");
        else
            $display("FAIL");

        $finish;
    end
endmodule