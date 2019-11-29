`timescale 1ns / 100ps

module tick_gen_tb();
    reg clk_in;
    localparam CLK_PERIOD = 2;
    initial clk_in = 1'b0;
    always #(CLK_PERIOD / 2) clk_in = ~clk_in;

    reg reset;
    integer i;
    initial begin
        reset = 1'b1;
        @(posedge clk_in);
        reset = 1'b0;
        for (i = 0; i < 300; i = i + 1) @(posedge clk_in);
        $finish;
    end

    wire clk_out_5Hz;
    wire clk_out_1Hz;

    tick_gen #(
        .CLK_IN_RATE_HZ(100)
        ) subject (
        .clk_in(clk_in), 
        .reset(reset), 
        .clk_out_1Hz(clk_out_1Hz), 
        .clk_out_5Hz(clk_out_5Hz)
        );

endmodule

