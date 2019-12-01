`timescale 1ns / 100ps

module watchdog #(
    parameter NUM_SENSE_INPUTS = 4,
    parameter TICK_TO_BARK = 10
    )(
    input wire[NUM_SENSE_INPUTS-1:0] sense_inputs,
    input clk,
    input wire reset,
    output wire bark
);
    parameter COUNTER_WIDTH = $clog2(TICK_TO_BARK) + 1;
    reg[COUNTER_WIDTH-1:0] counter;
    reg out_enable;

    assign bark = out_enable && counter == TICK_TO_BARK;

    always @(posedge clk) begin
        if (reset) begin
            counter <= 1'b1;
            out_enable <= 1'b1;
        end else begin
            if (sense_inputs) begin
                counter <= 1'b1;
                out_enable <= 1'b1;
            end else if (counter != TICK_TO_BARK) begin
                counter <= counter + 1'b1;
            end else begin
                out_enable <= 1'b0;
            end
        end
    end
endmodule
