`timescale 1ns/100ps

//
// Driver for 7-segment LED block that realises output
// strobe and digit blanking.
//
module led_display_driver #(
    parameter CLK_RATE_HZ = 390625
    )(
    input wire[23:0] data,
    input wire[5:0] digit_enable_mask,

    output reg[7:0] display_led_segments,
    output wire[5:0] display_led_enable_mask,

    input wire reset,
    input wire clk
);
    // Divide input clock frequency to get something suitable for
    // refreshing LED digits.
    localparam DISPLAY_REFRESH_RATE_HZ = 60;
    localparam DIGIT_REFRESH_RATE_HZ = DISPLAY_REFRESH_RATE_HZ * 6;
    // ISE doesn't allow clog2() for localparams
    parameter CLK_DIVIDER_STAGES = $clog2(CLK_RATE_HZ / DIGIT_REFRESH_RATE_HZ) - 1;

    reg[CLK_DIVIDER_STAGES-1:0] div_stages;
    always @(posedge clk) begin
        if (reset) begin
            div_stages <= {CLK_DIVIDER_STAGES{1'b0}};
        end else begin
            div_stages <= div_stages + 1'b1;
        end
    end
    assign digit_refresh_clk = div_stages[CLK_DIVIDER_STAGES-1];

    function[7:0] bcd_to_7seg;
        input[3:0] bcd;
        begin
                                        // abcdefg  
            bcd_to_7seg = bcd == 4'h0 ? 8'b11111100 :
                          bcd == 4'h1 ? 8'b01100000 :
                          bcd == 4'h2 ? 8'b11011010 :
                          bcd == 4'h3 ? 8'b11110010 :
                          bcd == 4'h4 ? 8'b01100110 :
                          bcd == 4'h5 ? 8'b10110110 :
                          bcd == 4'h6 ? 8'b10111110 :
                          bcd == 4'h7 ? 8'b11100000 :
                          bcd == 4'h8 ? 8'b11111110 :
                          bcd == 4'h9 ? 8'b11110110 :
                                        8'bxxxxxxxx;
        end
    endfunction

    reg[5:0] current_active;

    assign display_led_enable_mask = current_active & digit_enable_mask;

    always @(posedge digit_refresh_clk) begin
        case (current_active)
            6'b1 << 0 : begin
                current_active <= 6'b1 << 1;
                display_led_segments <= bcd_to_7seg(data[7:4]);
            end
            6'b1 << 1 : begin
                current_active <= 6'b1 << 2;
                display_led_segments <= bcd_to_7seg(data[11:8]);
            end
            6'b1 << 2 : begin
                current_active <= 6'b1 << 3;
                display_led_segments <= bcd_to_7seg(data[15:12]);
            end
            6'b1 << 3 : begin
                current_active <= 6'b1 << 4;
                display_led_segments <= bcd_to_7seg(data[19:16]);
            end
            6'b1 << 4 : begin
                current_active <= 6'b1 << 5;
                display_led_segments <= bcd_to_7seg(data[23:20]);
            end
            default : begin
                current_active <= 6'b1 << 0;
                display_led_segments <= bcd_to_7seg(data[3:0]);
            end
        endcase
    end
endmodule
