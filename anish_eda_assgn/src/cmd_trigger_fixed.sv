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
    typedef enum logic [1:0] {
        P_IDLE,
        P_WAIT_ACK,
        P_WAIT_ACK_LOW,
        P_BURST_GAP
    } p_state_t;

    typedef enum logic [2:0] {
        E_IDLE,
        E_EXEC1,
        E_EXEC2,
        E_EXEC3,
        E_DONE_ACK,
        E_DONE_CLR,
        E_CMD_CLR
    } e_state_t;

    typedef enum logic {
        L_IDLE,
        L_WAIT_LOW
    } l_state_t;

    p_state_t   p_state;
    logic [4:0] gap_cnt;
    logic       burst_pending;
    logic       cmd_req;
    logic [7:0] prod_cnt;

    logic       cmd_req_sync;
    logic       cmd_ack_sync;

    e_state_t   e_state;
    logic       cmd_ack;
    logic       done_req;

    logic       done_req_sync;
    logic       done_ack_sync;

    l_state_t   l_state;
    logic       done_ack;
    logic [7:0] exec_cnt;

    always_ff @(posedge clkA or negedge rstA_n) begin
        if (!rstA_n) begin
            p_state       <= P_IDLE;
            gap_cnt       <= 5'd0;
            burst_pending <= 1'b0;
            cmd_req       <= 1'b0;
            prod_cnt      <= 8'd0;
        end else begin
            unique case (p_state)
                P_IDLE: begin
                    cmd_req <= 1'b0;
                    if (trigger_en) begin
                        if (gap_cnt == 5'd0) begin
                            cmd_req       <= 1'b1;
                            prod_cnt      <= prod_cnt + 8'd1;
                            burst_pending <= burst_mode;
                            p_state       <= P_WAIT_ACK;
                        end else begin
                            gap_cnt <= gap_cnt - 5'd1;
                        end
                    end else begin
                        gap_cnt <= 5'd0;
                    end
                end
                P_WAIT_ACK: begin
                    if (cmd_ack_sync) begin
                        cmd_req <= 1'b0;
                        p_state <= P_WAIT_ACK_LOW;
                    end
                end
                P_WAIT_ACK_LOW: begin
                    if (!cmd_ack_sync) begin
                        if (burst_pending) begin
                            burst_pending <= 1'b0;
                            gap_cnt       <= 5'd1;
                            p_state       <= P_BURST_GAP;
                        end else begin
                            gap_cnt <= 5'd24;
                            p_state <= P_IDLE;
                        end
                    end
                end
                P_BURST_GAP: begin
                    if (gap_cnt == 5'd0) begin
                        cmd_req  <= 1'b1;
                        prod_cnt <= prod_cnt + 8'd1;
                        p_state  <= P_WAIT_ACK;
                    end else begin
                        gap_cnt <= gap_cnt - 5'd1;
                    end
                end
                default: begin
                    cmd_req <= 1'b0;
                    p_state <= P_IDLE;
                end
            endcase
        end
    end

    sync_2ff u_sync_cmd_req (
        .clk   (clkB),
        .rst_n (rstB_n),
        .d_in  (cmd_req),
        .d_out (cmd_req_sync)
    );

    sync_2ff u_sync_cmd_ack (
        .clk   (clkA),
        .rst_n (rstA_n),
        .d_in  (cmd_ack),
        .d_out (cmd_ack_sync)
    );

    always_ff @(posedge clkB or negedge rstB_n) begin
        if (!rstB_n) begin
            e_state  <= E_IDLE;
            cmd_ack  <= 1'b0;
            done_req <= 1'b0;
        end else begin
            case (e_state)
                E_IDLE: begin
                    cmd_ack  <= 1'b0;
                    done_req <= 1'b0;
                    if (cmd_req_sync)
                        e_state <= E_EXEC1;
                end
                E_EXEC1: e_state <= E_EXEC2;
                E_EXEC2: e_state <= E_EXEC3;
                E_EXEC3: begin
                    done_req <= 1'b1;
                    e_state  <= E_DONE_ACK;
                end
                E_DONE_ACK: begin
                    if (done_ack_sync) begin
                        done_req <= 1'b0;
                        e_state  <= E_DONE_CLR;
                    end
                end
                E_DONE_CLR: begin
                    if (!done_ack_sync) begin
                        cmd_ack <= 1'b1;
                        e_state <= E_CMD_CLR;
                    end
                end
                E_CMD_CLR: begin
                    if (!cmd_req_sync) begin
                        cmd_ack <= 1'b0;
                        e_state <= E_IDLE;
                    end
                end
                default: begin
                    cmd_ack  <= 1'b0;
                    done_req <= 1'b0;
                    e_state  <= E_IDLE;
                end
            endcase
        end
    end

    sync_2ff u_sync_done_req (
        .clk   (clkA),
        .rst_n (rstA_n),
        .d_in  (done_req),
        .d_out (done_req_sync)
    );

    sync_2ff u_sync_done_ack (
        .clk   (clkB),
        .rst_n (rstB_n),
        .d_in  (done_ack),
        .d_out (done_ack_sync)
    );

    always_ff @(posedge clkA or negedge rstA_n) begin
        if (!rstA_n) begin
            l_state  <= L_IDLE;
            done_ack <= 1'b0;
            exec_cnt <= 8'd0;
        end else begin
            unique case (l_state)
                L_IDLE: begin
                    done_ack <= 1'b0;
                    if (done_req_sync) begin
                        exec_cnt <= exec_cnt + 8'd1;
                        done_ack <= 1'b1;
                        l_state  <= L_WAIT_LOW;
                    end
                end
                L_WAIT_LOW: begin
                    if (!done_req_sync) begin
                        done_ack <= 1'b0;
                        l_state  <= L_IDLE;
                    end
                end
                default: begin
                    done_ack <= 1'b0;
                    l_state  <= L_IDLE;
                end
            endcase
        end
    end

    assign exec_count           = exec_cnt;
    assign producer_pulse_count = prod_cnt;
endmodule