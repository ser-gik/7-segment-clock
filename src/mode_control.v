`timescale 1ns / 100ps

module mode_control(
    input wire next_mode,
    input wire reset,
    input wire timer_clk,
    input wire adjuster_clk,
    input wire clk,
    output reg timer_load,
    output reg adjuster_load,
    output wire reg_select,
    output reg[2:0] adjust_mode
);
    assign reg_select = |adjust_mode;

    reg prev_next_mode;
    reg prev_timer_clk;
    reg prev_adjuster_clk;

    always @(posedge clk) begin
        if (reset) begin
            timer_load <= 1'b0;
            adjuster_load <= 1'b0;
            adjust_mode <= 3'b000;

            prev_next_mode <= 1'b0;
            prev_timer_clk <= 1'b0;
            prev_adjuster_clk <= 1'b0;
        end else begin
            prev_next_mode <= next_mode;
            if (!prev_next_mode && next_mode && !adjuster_load && !timer_load) begin
                case (adjust_mode)
                    3'b000: adjuster_load <= 1'b1;
                    3'b100: adjust_mode <= 3'b010;
                    3'b010: adjust_mode <= 3'b001;
                    3'b001: timer_load <= 1'b1;
                endcase
            end
            prev_timer_clk <= timer_clk;
            if (!prev_timer_clk && timer_clk && timer_load) begin
                timer_load <= 1'b0;
                adjust_mode <= 3'b000;
            end
            prev_adjuster_clk <= adjuster_clk;
            if (!prev_adjuster_clk && adjuster_clk && adjuster_load) begin
                adjuster_load <= 1'b0;
                adjust_mode <= 3'b100;
            end
        end
    end
endmodule

