`timescale 1ns/100ps

//
// Wall clock that displays current time via 6-digit 7-segment LED display.
// Displayed time can be adjusted manually via adjust buttons.
//
// See port list for more details.
//
module wall_clock #(
    parameter CLK_RATE_HZ = 1_000_000,
    parameter HOURS_STYLE_AMERICAN = 0
    )(
    //
    // LED display is expected to have common segment bus for all digits
    // and separate "enable" lines for every digit.
    // Segment word bits assignment is next: a-b-c-d-e-f-g-dp, where 'a' is a bit 7
    // and 'dp' is a bit 0, assuming that display segment layout is next:
    //
    //       /-a-/
    //      f   b
    //     /-g-/
    //    e   c
    //   /-d-/  dp
    //
    // Any bit set to '1' corresponds to related segment to be turned on and vice versa.
    //
    // Enable mask bits corresponds to natural digit positions: HH-MM-SS.
    // Hours are bits 5-4, minutes are 3-2, seconds are 1-0.
    // Any bit set to '1' must enable related digit.
    //
    output wire[7:0] display_led_segments,
    output wire[5:0] display_led_enable_mask,

    //
    // Adjustment is done via two pins interface.
    // Positive edge at 'next' port activates adjustment mode for hour value. Subsequent
    // posedges will move adjustment focus to the next digits. Posedge after adjusting
    // seconds value will immediately apply new values and turn device to normal mode.
    // When some digits are in adjustment focus, their values can be incremented via
    // 'increment' port. Posedge will add '1' to current value. Keeping high level
    // for more than one second will continuously increment value until transition
    // to low level.
    // After 10 seconds of adjustment mode with no activity on adjust ports device
    // will cancel any updated values and go back to normal mode.
    //
    input wire adjustment_next,
    input wire adjustment_increment,
    
    input wire clk
);
    wire clk_1Hz;
    wire clk_adjust_reg;

    tick_gen #(
        .CLK_IN_RATE_HZ(100)
        ) tick_generator (
        .clk_in(clk), 
        .reset(1'b0), 
        .clk_out_1Hz(clk_1Hz), 
        .clk_out_5Hz(clk_adjust_reg)
        );

    wire[23:0] timer_out;
    wire timer_load;
    wire timer_will_wraparound_minutes;
    wire timer_will_wraparound_seconds;

    wire[23:0] adjust_out;
    wire adjust_load;
    wire adjust_increment_hours;
    wire adjust_increment_minutes;
    wire adjust_increment_seconds;

    wire select_reg;

    wire[2:0] adjust_mode;
    wire[5:0] blink_out;
    
    wire mode_ctrl_reset;

    time_register #(.HOURS_STYLE_AMERICAN(HOURS_STYLE_AMERICAN)) timer_reg (
        .time_bcd(timer_out), 
        .time_to_load_bcd(adjust_out), 
        .clk(clk_1Hz), 
        .load_new(timer_load), 
        .increment_hours(timer_will_wraparound_minutes && timer_will_wraparound_seconds), 
        .increment_minutes(timer_will_wraparound_seconds), 
        .increment_seconds(1'b1), 
        .will_wraparound_hours(), 
        .will_wraparound_minutes(timer_will_wraparound_minutes), 
        .will_wraparound_seconds(timer_will_wraparound_seconds)
        );

    time_register #(.HOURS_STYLE_AMERICAN(HOURS_STYLE_AMERICAN)) adjust_reg (
        .time_bcd(adjust_out), 
        .time_to_load_bcd(timer_out), 
        .clk(clk_adjust_reg), 
        .load_new(adjust_load), 
        .increment_hours(adjust_increment_hours), 
        .increment_minutes(adjust_increment_minutes), 
        .increment_seconds(adjust_increment_seconds), 
        .will_wraparound_hours(), 
        .will_wraparound_minutes(), 
        .will_wraparound_seconds()
        );

    blinker led_blinker (
        .blink_pulse(clk_1Hz), 
        .blink_control(adjust_mode), 
        .blink_out(blink_out)
        );

    led_display_driver #(.CLK_RATE_HZ(CLK_RATE_HZ)) leds (
        .data(select_reg ? adjust_out : timer_out), 
        .digit_enable_mask(blink_out), 
        .display_led_segments(display_led_segments), 
        .display_led_enable_mask(display_led_enable_mask), 
        .reset(1'b0), 
        .clk(clk)
        );

    adjust_inc_control #(.SINGLE_TO_CONTINUOUS_DELAY_TICKS(5)) adjust_pulse_gen (
        .adjust_increment(adjustment_increment), 
        .adjust_mode(adjust_mode), 
        .clk(clk_adjust_reg), 
        .increment_hours(adjust_increment_hours), 
        .increment_minutes(adjust_increment_minutes), 
        .increment_seconds(adjust_increment_seconds)
        );

    mode_control mode_ctrl (
        .next_mode(adjustment_next), 
        .reset(mode_ctrl_reset), 
        .timer_clk(clk_1Hz), 
        .adjuster_clk(clk_adjust_reg), 
        .clk(clk), 
        .timer_load(timer_load), 
        .adjuster_load(adjust_load), 
        .reg_select(select_reg), 
        .adjust_mode(adjust_mode)
        );

    watchdog #(
        .NUM_SENSE_INPUTS(2),
        .TICK_TO_BARK(10)
        ) mode_watchdog (
        .sense_inputs({adjustment_next, adjustment_increment}), 
        .clk(clk_1Hz), 
        .reset(1'b0), 
        .bark(mode_ctrl_reset)
        );

endmodule

