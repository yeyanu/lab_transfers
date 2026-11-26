module sync_2ff (
    input  logic clk,
    input  logic rst_n,
    input  logic d_in,
    output logic d_out
);
    logic ff1;
    logic ff2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ff1 <= 1'b0;
            ff2 <= 1'b0;
        end else begin
            ff1 <= d_in;
            ff2 <= ff1;
        end
    end

    assign d_out = ff2;
endmodule