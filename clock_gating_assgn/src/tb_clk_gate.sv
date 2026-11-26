`timescale 1ns/1ps

module tb_clk_gate;
    logic       clk;
    logic       rst_n;
    logic       en;
    logic       gclk;
    logic [7:0] count;

    int         err_cnt;
    logic [7:0] exp_cnt;

    clk_gate_top dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .gclk  (gclk),
        .count (count)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    property p_rst_clear;
        @(posedge clk) !rst_n |-> (count == 8'd0);
    endproperty
    assert property (p_rst_clear) else err_cnt++;

    property p_gclk_low_when_clk_low;
        @(negedge clk) #1 (gclk == 1'b0);
    endproperty
    assert property (p_gclk_low_when_clk_low) else err_cnt++;

    initial begin
        err_cnt = 0;
        exp_cnt = 8'd0;
        rst_n   = 1'b0;
        en      = 1'b0;

        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        repeat (5) @(negedge clk);
        if (count !== 8'd0 || gclk !== 1'b0)
            err_cnt++;

        en = 1'b1;
        repeat (8) @(negedge clk);
        exp_cnt = 8'd8;
        if (count !== exp_cnt)
            err_cnt++;

        @(posedge clk);
        #2 en = 1'b0;
        #1 if (gclk !== 1'b1) err_cnt++;
        exp_cnt = exp_cnt + 8'd1;

        @(negedge clk);
        repeat (4) @(negedge clk);
        if (count !== exp_cnt)
            err_cnt++;

        @(posedge clk);
        #2 en = 1'b1;
        #1 if (gclk !== 1'b0) err_cnt++;

        repeat (4) @(negedge clk);
        exp_cnt = exp_cnt + 8'd4;
        if (count !== exp_cnt)
            err_cnt++;

        en = 1'b0;
        repeat (4) @(negedge clk);
        if (count !== exp_cnt)
            err_cnt++;

        $display("count=%0d exp=%0d errors=%0d", count, exp_cnt, err_cnt);
        if (err_cnt == 0)
            $display("PASS");
        else
            $display("FAIL");

        $finish;
    end
endmodule
