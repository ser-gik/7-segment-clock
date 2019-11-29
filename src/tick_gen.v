`timescale 1ns / 100ps

module tick_gen #(
    parameter CLK_IN_RATE_HZ = 1_000_000
    )(
    input wire clk_in,
    input wire reset,
    output reg clk_out_1Hz,
    output reg clk_out_5Hz
);
    localparam SRC_CYCLES_PER_5HZ_CYCLE = CLK_IN_RATE_HZ / 5;
    parameter COUNTER_WIDTH = $clog2(SRC_CYCLES_PER_5HZ_CYCLE) + 1;

    reg[COUNTER_WIDTH-1:0] counter;
    reg[2:0] counter_1Hz;

    always @(posedge clk_in) begin
        if (reset) begin
            counter <= 1'b0;
            counter_1Hz <= 1'b0;
            clk_out_1Hz <= 1'b0;
            clk_out_5Hz <= 1'b0;
        end else begin
            if (counter == SRC_CYCLES_PER_5HZ_CYCLE / 2 - 1) begin
                counter <= 1'b0;
                clk_out_5Hz <= ~clk_out_5Hz;
                if (counter_1Hz == 3'd4) begin
                    counter_1Hz <= 1'b0;
                    clk_out_1Hz <= ~clk_out_1Hz;
                end else begin
                    counter_1Hz <= counter_1Hz + 1'b1;
                end
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule

