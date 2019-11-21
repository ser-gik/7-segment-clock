`timescale 1ns / 100ps

module adjust_inc_control #(
    parameter SINGLE_TO_CONTINUOUS_DELAY_TICKS = 5
    )(
    input wire adjust_increment,
    input wire[2:0] adjust_mode,
    input wire clk,
    output wire increment_hours,
    output wire increment_minutes,
    output wire increment_seconds
);
    parameter TICKS_VAL_WIDTH = $clog2(SINGLE_TO_CONTINUOUS_DELAY_TICKS) + 1;
    reg[TICKS_VAL_WIDTH - 1:0] ticks_to_cont;
    reg[2:0] mode_latch;
    wire do_inc;

    assign {increment_hours, increment_minutes, increment_seconds} =
                mode_latch & {3{do_inc}};

    assign do_inc = adjust_increment
                    && (ticks_to_cont == SINGLE_TO_CONTINUOUS_DELAY_TICKS 
                        || ticks_to_cont == 1'b0);

    always @(posedge clk) begin
        mode_latch <= adjust_mode;
        if (!adjust_increment) begin
            ticks_to_cont <= SINGLE_TO_CONTINUOUS_DELAY_TICKS;
        end else begin
            if (mode_latch != adjust_mode) begin
                ticks_to_cont <= SINGLE_TO_CONTINUOUS_DELAY_TICKS + 1'b1;
            end else if (ticks_to_cont) begin
                ticks_to_cont <= ticks_to_cont - {{TICKS_VAL_WIDTH-1{1'b0}}, 1'b1};
            end
        end
    end
endmodule
