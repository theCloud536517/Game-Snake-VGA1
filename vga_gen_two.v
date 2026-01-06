`timescale 1ns / 1ps

module vga_gen_two(
    input clk,          // Clock 25MHz
    
    output reg [9:0] x, // Pixel Counter X
    output reg [9:0] y, // Pixel Counter Y
    output v_sync,      // Vertical Sync
    output h_sync,      // Horizontal Sync
    output display,     // Active Video Area
    output animate      // Frame Tick
    );
    
    initial begin
        x = 0;
        y = 0;
    end

    // Horizontal timings (640x480 @ 60Hz)
    parameter HA_END = 639;          // end of active pixels
    parameter HS_STA = HA_END + 16;  // sync starts after front porch
    parameter HS_END = HS_STA + 96;  // sync ends
    parameter LINE   = 799;          // last pixel on line (Total width - 1)

    // Vertical timings
    parameter VA_END = 479;          // end of active pixels
    parameter VS_STA = VA_END + 10;  // sync starts after front porch
    parameter VS_END = VS_STA + 2;   // sync ends
    parameter SCREEN = 524;          // last line on screen (Total height - 1)

 
    assign h_sync = ~(x >= HS_STA && x < HS_END); 
    assign v_sync = ~(y >= VS_STA && y < VS_END); 
    
    assign display = (x <= HA_END && y <= VA_END);
    
    assign animate = (x >= HA_END);
    
    always @(posedge clk)
    begin
        if(x == LINE) begin
            x <= 0;
            y <= (y == SCREEN) ? 0 : y + 1;
        end
        else begin
            x <= x + 1;
        end
    end
    
endmodule