`timescale 1ns / 1ps
module appleLogic(
    input clk,             
    input rst,
    input eat_trigger,      
    input [9:0] head_x,     
    input [9:0] head_y,
    
    output reg [9:0] apple_x,
    output reg [9:0] apple_y
    );
    
    reg [15:0] random_x = 16'hACE1;
    reg [15:0] random_y = 16'h2409;
    
    always @(posedge clk) begin
        if (rst) begin
            apple_x <= 10'd100; 
            apple_y <= 10'd100;
            random_x <= 16'hACE1;
            random_y <= 16'h2409;
        end
        else begin
            random_x <= {random_x[14:0], random_x[15] ^ random_x[13] ^ random_x[12] ^ random_x[10]};
            random_y <= {random_y[14:0], random_y[15] ^ random_y[13] ^ random_y[12] ^ random_y[10]};
            
            if (eat_trigger) begin

                apple_x <= (random_x % 31) * 20; 
                apple_y <= (random_y % 23) * 20;
            end
        end
    end
endmodule