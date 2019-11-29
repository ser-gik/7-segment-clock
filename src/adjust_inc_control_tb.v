`timescale 1ns / 100ps


module adjust_inc_control_tb(
    );

    reg adjust_increment;
    reg[2:0] adjust_mode;
    reg clk;

    wire increment_hours;
    wire increment_minutes;
    wire increment_seconds;

    localparam CLK_PERIOD = 2;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    integer i;

    initial begin
        adjust_increment = 1'b0;
        adjust_mode = 3'b000;
        for (i = 0; i < 2; i= i + 1) @(posedge clk);
        adjust_mode = 3'b010;
        for (i = 0; i < 2; i= i + 1) @(posedge clk);
        adjust_increment = 1'b1;
        for (i = 0; i < 10; i= i + 1) @(posedge clk);
        adjust_mode = 3'b001;
        for (i = 0; i < 10; i= i + 1) @(posedge clk);
        adjust_mode = 3'b000;
        for (i = 0; i < 10; i= i + 1) @(posedge clk);
        adjust_increment = 1'b0;
        for (i = 0; i < 2; i= i + 1) @(posedge clk);
        $finish;
    end

    adjust_inc_control subject (
        .adjust_increment(adjust_increment), 
        .adjust_mode(adjust_mode), 
        .clk(clk), 
        .increment_hours(increment_hours), 
        .increment_minutes(increment_minutes), 
        .increment_seconds(increment_seconds)
        );

endmodule
