module cmd_trigger_top (
    input  logic       clkA,
    input  logic       rstA_n,
    input  logic       clkB,
    input  logic       rstB_n,
    input  logic       trigger_en,
    input  logic       burst_mode,
    output logic [7:0] exec_count,
    output logic [7:0] producer_pulse_count
);
    typedef enum logic {
        P_IDLE,
        P_BURST_GAP
    } p_state_t;

    typedef enum logic [1:0] {
        E_IDLE,
        E_EXEC1,
        E_EXEC2,
        E_EXEC3
    } e_state_t;

    typedef enum logic {
        L_IDLE,
        L_WAIT_LOW
    } l_state_t;

    p_state_t   p_state;
    logic [4:0] gap_cnt;
    logic       cmd_pulse;
    logic [7:0] prod_cnt;

    logic       cmd_sync;

    e_state_t   e_state;
    logic       done_pulse;

    logic       done_sync;

    l_state_t   l_state;
    logic [7:0] exec_cnt;

    always_ff @(posedge clkA or negedge rstA_n) begin
        if (!rstA_n) begin
            p_state   <= P_IDLE;
            gap_cnt   <= 5'd0;
            cmd_pulse <= 1'b0;
            prod_cnt  <= 8'd0;
        end else begin
            cmd_pulse <= 1'b0;
            unique case (p_state)
                P_IDLE: begin
                    if (trigger_en) begin
                        if (gap_cnt == 5'd0) begin
                            cmd_pulse <= 1'b1;
                            prod_cnt  <= prod_cnt + 8'd1;
                            if (burst_mode) begin
                                gap_cnt <= 5'd1;
                                p_state <= P_BURST_GAP;
                            end else begin
                                gap_cnt <= 5'd24;
                            end
                        end else begin
                            gap_cnt <= gap_cnt - 5'd1;
                        end
                    end else begin
                        gap_cnt <= 5'd0;
                    end
                end
                P_BURST_GAP: begin
                    if (gap_cnt == 5'd0) begin
                        cmd_pulse <= 1'b1;
                        prod_cnt  <= prod_cnt + 8'd1;
                        gap_cnt   <= 5'd24;
                        p_state   <= P_IDLE;
                    end else begin
                        gap_cnt <= gap_cnt - 5'd1;
                    end
                end
                default: p_state <= P_IDLE;
            endcase
        end
    end

    sync_2ff u_sync_cmd (
        .clk   (clkB),
        .rst_n (rstB_n),
        .d_in  (cmd_pulse),
        .d_out (cmd_sync)
    );

    always_ff @(posedge clkB or negedge rstB_n) begin
        if (!rstB_n) begin
            e_state    <= E_IDLE;
            done_pulse <= 1'b0;
        end else begin
            done_pulse <= 1'b0;
            unique case (e_state)
                E_IDLE: begin
                    if (cmd_sync)
                        e_state <= E_EXEC1;
                end
                E_EXEC1: e_state <= E_EXEC2;
                E_EXEC2: e_state <= E_EXEC3;
                E_EXEC3: begin
                    done_pulse <= 1'b1;
                    e_state    <= E_IDLE;
                end
                default: e_state <= E_IDLE;
            endcase
        end
    end

    sync_2ff u_sync_done (
        .clk   (clkA),
        .rst_n (rstA_n),
        .d_in  (done_pulse),
        .d_out (done_sync)
    );

    always_ff @(posedge clkA or negedge rstA_n) begin
        if (!rstA_n) begin
            l_state  <= L_IDLE;
            exec_cnt <= 8'd0;
        end else begin
            unique case (l_state)
                L_IDLE: begin
                    if (done_sync) begin
                        exec_cnt <= exec_cnt + 8'd1;
                        l_state  <= L_WAIT_LOW;
                    end
                end
                L_WAIT_LOW: begin
                    if (!done_sync)
                        l_state <= L_IDLE;
                end
                default: l_state <= L_IDLE;
            endcase
        end
    end

    assign exec_count           = exec_cnt;
    assign producer_pulse_count = prod_cnt;
endmodule