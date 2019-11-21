`timescale 1ns / 100ps

module blinker_tb();
    reg blink_pulse;
    reg[2:0] blink_control;

    wire[5:0] blink_out;

    localparam CLK_PERIOD = 2;
    initial blink_pulse = 1'b0;
    always #(CLK_PERIOD / 2) blink_pulse = ~blink_pulse;

    initial begin
        blink_control = 3'bxxx;
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        blink_control = 3'b001;
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        blink_control = 3'b010;
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        blink_control = 3'b100;
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        blink_control = 3'b000;
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        @(posedge blink_pulse);
        $finish;
    end

    blinker subject (
        .blink_pulse(blink_pulse), 
        .blink_control(blink_control), 
        .blink_out(blink_out)
        );

endmodule
