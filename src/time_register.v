`timescale 1ns / 100ps

module time_register #(
    parameter HOURS_STYLE_AMERICAN = 1
    )(
    output wire[23:0] time_bcd,
    input wire[23:0] time_to_load_bcd,
    input wire clk,
    input wire load_new,
    input wire increment_hours,
    input wire increment_minutes,
    input wire increment_seconds,
    output wire will_wraparound_hours,
    output wire will_wraparound_minutes,
    output wire will_wraparound_seconds
);
    reg[7:0] hours;
    reg[7:0] minutes;
    reg[7:0] seconds;

    function [7:0] inc_bcd;
        input[7:0] bcd_value;
        begin
            inc_bcd = bcd_value[3:0] >= 4'd9
                        ? {bcd_value[7:4] + 4'b1, 4'b0}
                        : bcd_value + 8'b1;
        end
    endfunction

    function should_wrap;
        input[7:0] bcd_value;
        input[7:0] threshold;
        begin
            should_wrap = bcd_value[7:4] > threshold[7:4]
                            || (bcd_value[7:4] == threshold[7:4] && bcd_value[3:0] >= threshold[3:0]); 
        end
    endfunction

    assign time_bcd = {hours, minutes, seconds};
    assign will_wraparound_hours = should_wrap(hours, (HOURS_STYLE_AMERICAN ? 8'h12 : 8'h23));
    assign will_wraparound_minutes = should_wrap(minutes, 8'h59);
    assign will_wraparound_seconds = should_wrap(seconds, 8'h59);

    always @(posedge clk) begin
        if (load_new) begin
            {hours, minutes, seconds} <= time_to_load_bcd;
        end else begin
            if (increment_hours) begin
                hours <= will_wraparound_hours ? (HOURS_STYLE_AMERICAN ? 8'h1 : 8'h0) : inc_bcd(hours);
            end
            if (increment_minutes) begin
                minutes <= will_wraparound_minutes ? 8'h0 : inc_bcd(minutes);
            end
            if (increment_seconds) begin
                seconds <= will_wraparound_seconds ? 8'h0 : inc_bcd(seconds);
            end
        end
    end
endmodule

