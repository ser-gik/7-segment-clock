`timescale 1ns / 100ps

module blinker(
    input wire blink_pulse,
    input wire[2:0] blink_control,
    output wire[5:0] blink_out
);
    assign blink_out = {
        blink_control[2] ? {2{blink_pulse}} : 2'b11,
        blink_control[1] ? {2{blink_pulse}} : 2'b11,
        blink_control[0] ? {2{blink_pulse}} : 2'b11
    };
endmodule

