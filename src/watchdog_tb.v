`timescale 1ns / 100ps

module watchdog_tb();
    reg clk;
    localparam CLK_PERIOD = 2;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;
    
    reg[2:0] sense_inputs;
    reg reset;

    integer i; 

    initial begin
        reset <= 1'b1;
        sense_inputs <= 3'b111;
        @(posedge clk);
        reset <= 1'b0;
        for (i = 0; i < 10; i = i + 1) @(posedge clk);
        sense_inputs <= 3'b011;
        for (i = 0; i < 10; i = i + 1) @(posedge clk);
        sense_inputs <= 3'b010;
        for (i = 0; i < 4; i = i + 1) @(posedge clk);
        sense_inputs <= 3'b111;
        for (i = 0; i < 10; i = i + 1) @(posedge clk);
        $finish;
    end

    wire bark;

    watchdog #(
        .NUM_SENSE_INPUTS(3),
        .TICK_TO_BARK(7)
        )subject (
        .sense_inputs(sense_inputs), 
        .clk(clk), 
        .reset(reset), 
        .bark(bark)
        );

endmodule

