module icg_cell (
    input  logic clk,
    input  logic en,
    output logic gclk
);
    logic en_latched;

    always_latch begin
        if (!clk)
            en_latched <= en;
    end

    assign gclk = clk & en_latched;
endmodule

module clk_gate_top (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic       gclk,
    output logic [7:0] count
);
    icg_cell u_icg (
        .clk  (clk),
        .en   (en),
        .gclk (gclk)
    );

    always_ff @(posedge gclk or negedge rst_n) begin
        if (!rst_n)
            count <= 8'd0;
        else
            count <= count + 8'd1;
    end
endmodule
