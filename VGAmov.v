`timescale 1ns / 1ps
module VGAmov(
    input animate,
    input [2:0] inmove,
    input [9:0] x, y,       
    input clk,              // Clock 25MHz
    input de,               
    input rst,              // Reset t? Switch
    input palette,
    input vsync_in,         // Tín hi?u Vsync
    
    input [9:0] apple_x,
    input [9:0] apple_y,
    output reg eat_trigger, 
    output [9:0] head_x_out,
    output [9:0] head_y_out,
    
    output reg [3:0] r, g, b
    );
    
    // --- KHAI BÁO BI?N ---
    reg [9:0] snakex, snakey;
    reg [2:0] current_dir;
    
    reg [9:0] body_x [63:0]; 
    reg [9:0] body_y [63:0];
    reg [5:0] length; 
    
    reg game_over_state;
    
    reg vsync_prev;
    wire vsync_negedge;
    
    reg [5:0] speed_counter;
    
    assign head_x_out = snakex;
    assign head_y_out = snakey;

    always @(posedge clk) begin
        vsync_prev <= vsync_in;
    end
    assign vsync_negedge = (vsync_prev == 1'b1 && vsync_in == 1'b0);

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            snakex <= 10'd320;
            snakey <= 10'd240;
            current_dir <= 3'b000; 
            length <= 6'd3;        
            game_over_state <= 0; 
            eat_trigger <= 0;
            speed_counter <= 0;
            
            body_x[0] <= 10'd300; body_y[0] <= 10'd240;
            body_x[1] <= 10'd280; body_y[1] <= 10'd240;
            body_x[2] <= 10'd260; body_y[2] <= 10'd240;
            

            for (i = 3; i < 64; i = i + 1) begin
                body_x[i] <= 10'd1000;
                body_y[i] <= 10'd1000;
            end
        end
        else if (vsync_negedge) begin 
            if (!game_over_state) begin
                eat_trigger <= 0; 
                
                if (speed_counter >= 15) begin
                    speed_counter <= 0; 
                    
                    case (inmove)
                        3'b000: if (current_dir != 3'b010) current_dir <= 3'b000; 
                        3'b001: if (current_dir != 3'b011) current_dir <= 3'b001; 
                        3'b010: if (current_dir != 3'b000) current_dir <= 3'b010; 
                        3'b011: if (current_dir != 3'b001) current_dir <= 3'b011; 
                    endcase
                    
                    for(i=63; i>0; i=i-1) begin
                        body_x[i] <= body_x[i-1];
                        body_y[i] <= body_y[i-1];
                    end
                    body_x[0] <= snakex;
                    body_y[0] <= snakey;
                    
                    case(current_dir)
                        3'b000: snakex <= (snakex >= 620) ? 0 : snakex + 20;   
                        3'b001: snakey <= (snakey < 20) ? 460 : snakey - 20;   
                        3'b010: snakex <= (snakex < 20) ? 620 : snakex - 20;   
                        3'b011: snakey <= (snakey >= 460) ? 0 : snakey + 20;   
                    endcase
                    
                    if (snakex == apple_x && snakey == apple_y) begin
                        eat_trigger <= 1; 
                        if (length < 63) length <= length + 1; 
                    end
                    
                    for(i=1; i<63; i=i+1) begin
                        if (i < length) begin 
                            if (snakex == body_x[i] && snakey == body_y[i]) begin
                                game_over_state <= 1;
                            end
                        end
                    end
                end 
                else begin
                    speed_counter <= speed_counter + 1;
                end
            end
        end
    end
    
    reg is_snake_body;
    always @(*) begin
        is_snake_body = 0;
        for(i=0; i<64; i=i+1) begin
            if (i < length) begin
                if (x >= body_x[i] && x < body_x[i]+21 && y >= body_y[i] && y < body_y[i]+21)
                    is_snake_body = 1;
            end
        end
    end

    wire G, A, M, E1;
    wire G_L, G_T, G_B, G_R_bot, G_Mid; 
    
    assign G_L = (x>=240 && x<242 && y>=200 && y<240); 
    assign G_T = (x>=240 && x<270 && y>=200 && y<202); 
    assign G_B = (x>=240 && x<270 && y>=238 && y<240); 
    assign G_R_bot = (x>=268 && x<270 && y>=220 && y<240); 
    assign G_Mid = (x>=255 && x<270 && y>=220 && y<222); 
    assign G = G_L || G_T || G_B || G_R_bot || G_Mid;

    assign A = (x>=280 && x<282 && y>=200 && y<240) || 
               (x>=308 && x<310 && y>=200 && y<240) || 
               (x>=280 && x<310 && y>=200 && y<202) || 
               (x>=280 && x<310 && y>=220 && y<222);   

    assign M = (x>=320 && x<322 && y>=200 && y<240) || 
               (x>=348 && x<350 && y>=200 && y<240) || 
               (x>=320 && x<350 && y>=200 && y<202) || 
               (x>=334 && x<336 && y>=200 && y<225);   

    assign E1 = (x>=360 && x<362 && y>=200 && y<240) || 
                (x>=360 && x<390 && y>=200 && y<202) || 
                (x>=360 && x<390 && y>=219 && y<221) || 
                (x>=360 && x<390 && y>=238 && y<240);   

    wire O, V, E2, R;
    
    assign O = (x>=240 && x<242 && y>=250 && y<290) || 
               (x>=268 && x<270 && y>=250 && y<290) || 
               (x>=240 && x<270 && y>=250 && y<252) || 
               (x>=240 && x<270 && y>=288 && y<290);   

    assign V = (x>=280 && x<282 && y>=250 && y<290) || 
               (x>=308 && x<310 && y>=250 && y<290) || 
               (x>=280 && x<310 && y>=288 && y<290);  

    assign E2 = (x>=320 && x<322 && y>=250 && y<290) || 
                (x>=320 && x<350 && y>=250 && y<252) || 
                (x>=320 && x<350 && y>=269 && y<271) || 
                (x>=320 && x<350 && y>=288 && y<290);   

    assign R = (x>=360 && x<362 && y>=250 && y<290) || 
               (x>=360 && x<390 && y>=250 && y<252) || 
               (x>=360 && x<390 && y>=269 && y<271) || 
               (x>=388 && x<390 && y>=250 && y<271) || 
               (x>=388 && x<390 && y>=271 && y<290) || 
               (x>=360 && x<390 && y>=271 && y<273);   

    wire is_text;
    assign is_text = (game_over_state) && (G || A || M || E1 || O || V || E2 || R);

    always @(posedge clk) begin
        if (de) begin
            if (game_over_state) begin
                if (is_text) begin
                    r <= 4'hF; g <= 4'h0; b <= 4'h0; 
                end else begin
                    r <= 4'h0; g <= 4'h0; b <= 4'h0; 
                end
            end
            else begin
                if (x >= apple_x && x < apple_x+21 && y >= apple_y && y < apple_y+21) begin
                    r <= 4'hF; g <= 4'h0; b <= 4'h0; 
                end
                else if (x >= snakex && x < snakex+21 && y >= snakey && y < snakey+21) begin
                    r <= 4'h0; g <= 4'hF; b <= 4'h0; 
                end
                else if (is_snake_body) begin
                    r <= 4'h0; g <= 4'hA; b <= 4'h0; 
                end
                else begin
                    r <= 4'h0; g <= 4'h0; b <= 4'h0; 
                end
            end
        end else begin
            r <= 0; g <= 0; b <= 0;
        end
    end

endmodule