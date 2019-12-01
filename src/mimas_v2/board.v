`timescale 1ns / 1ps

module board(
    input wire CLK_100MHz,
    input wire[2:0] Switch,
    output wire[7:0] IO_P6,
    output wire[7:0] IO_P7
);
    assign reset = ~Switch[2];
    assign adjustment_next = ~Switch[1];
    assign adjustment_increment = ~Switch[0];
    wire[7:0] display_led_segments;
    wire[5:0] display_led_enable_mask;

    wall_clock #(.CLK_RATE_HZ(100_000_000)) wc (
        .display_led_segments(display_led_segments), 
        .display_led_enable_mask(display_led_enable_mask), 
        .adjustment_next(adjustment_next), 
        .adjustment_increment(adjustment_increment),
        .clk(CLK_100MHz),
		  .reset(reset)
        );

/*
    led_display_driver #(.CLK_RATE_HZ(100_000_000)) leds (
        .data(24'h098765), 
        .digit_enable_mask(6'b111111), 
        .display_led_segments(display_led_segments), 
        .display_led_enable_mask(display_led_enable_mask), 
        .reset(1'b0), 
        .clk(CLK_100MHz)
        );
*/

    assign IO_P6 = ~display_led_segments;
    assign IO_P7 = {2'b0, ~display_led_enable_mask};

endmodule
