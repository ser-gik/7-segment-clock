`timescale 1ns / 100ps

module time_register_tb();
    wire[23:0] time_bcd;
    reg clk;
    reg load_new;

    localparam CLK_PERIOD = 4;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        load_new = 1'b0;
        @(posedge clk);
        @(posedge clk);
        load_new = 1'b1;
        @(posedge clk);
        load_new = 1'b0;
    end

    initial #(CLK_PERIOD * 86400 + 50) $finish;

    wire will_wraparound_hours;
    wire will_wraparound_minutes;
    wire will_wraparound_seconds;

    time_register #(.HOURS_STYLE_AMERICAN(0)) subject (
        .time_bcd(time_bcd), 
        .time_to_load_bcd(24'hba_ad_ff), 
        .clk(clk), 
        .load_new(load_new), 
        .increment_hours(will_wraparound_minutes && will_wraparound_seconds), 
        .increment_minutes(will_wraparound_seconds), 
        .increment_seconds(1'b1), 
        .will_wraparound_hours(will_wraparound_hours), 
        .will_wraparound_minutes(will_wraparound_minutes), 
        .will_wraparound_seconds(will_wraparound_seconds)
        );
endmodule
