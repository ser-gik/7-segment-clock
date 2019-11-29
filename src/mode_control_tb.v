`timescale 1ns / 100ps

module mode_control_tb();
    reg clk;
    localparam CLK_PERIOD = 2;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg timer_clk;
    localparam TIMER_CLK_PERIOD = 10;
    initial timer_clk = 1'b0;
    always #(TIMER_CLK_PERIOD / 2) timer_clk = ~timer_clk;

    reg adjuster_clk;
    localparam ADJUSTER_CLK_PERIOD = 20;
    initial adjuster_clk = 1'b0;
    always #(ADJUSTER_CLK_PERIOD / 2) adjuster_clk = ~adjuster_clk;

    reg next_mode;
    reg reset;

    integer i;

    initial begin
        next_mode = 1'b0;
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        for (i = 0; i < 5; i = i + 1) @(posedge clk);
        next_mode = 1'b1;
        @(posedge clk);
        next_mode = 1'b0;
        for (i = 0; i < 30; i = i + 1) @(posedge clk);
        next_mode = 1'b1;
        @(posedge clk);
        next_mode = 1'b0;
        for (i = 0; i < 30; i = i + 1) @(posedge clk);
        next_mode = 1'b1;
        @(posedge clk);
        next_mode = 1'b0;
        for (i = 0; i < 30; i = i + 1) @(posedge clk);
        next_mode = 1'b1;
        @(posedge clk);
        next_mode = 1'b0;
        for (i = 0; i < 30; i = i + 1) @(posedge clk);
        next_mode = 1'b1;
        @(posedge clk);
        next_mode = 1'b0;
        for (i = 0; i < 30; i = i + 1) @(posedge clk);
        next_mode = 1'b1;
        @(posedge clk);
        next_mode = 1'b0;
        for (i = 0; i < 30; i = i + 1) @(posedge clk);
        $finish;
    end

    wire timer_load;
    wire adjuster_load;
    wire reg_select;
    wire[2:0] adjust_mode;

    mode_control subject (
        .next_mode(next_mode), 
        .reset(reset), 
        .timer_clk(timer_clk), 
        .adjuster_clk(adjuster_clk), 
        .clk(clk), 
        .timer_load(timer_load), 
        .adjuster_load(adjuster_load), 
        .reg_select(reg_select), 
        .adjust_mode(adjust_mode)
        );

endmodule

