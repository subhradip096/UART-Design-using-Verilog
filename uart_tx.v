`timescale 1ns / 1ps

module uart_tx(
    input clk,txbit,[7:0]txdata,
    output tx_active, tx_done,
    output reg tx_serial
    );
 
 parameter clks_per_bit = 87; //frequency of clk / frequency of uart
 
 parameter ready = 3'b000 , tx_start = 3'b001 , tx_data = 3'b010 , tx_stop = 3'b011 , tx_clean = 3'b100;
 
 reg [2:0] state = ready ;
 reg [7:0] clk_timer = 0;
 reg [2:0] bit_index = 0;
 reg [7:0] data;
 reg done;
 reg clk_done;
 reg active;
 
 
 always@(posedge clk) begin
    if (state == ready)
        clk_timer <= 0;
    else begin
        if (clk_timer == clks_per_bit) begin
            clk_timer <= 0;
            clk_done <= 1;
        end
        else begin
            clk_timer <= clk_timer + 1;
            clk_done <= 0;
        end     
    end
 end
 
 always@(posedge clk) begin
    case(state)
        ready: begin
            tx_serial <= 1'b1;
            done <= 1'b0;  
            bit_index <= 0;
            
            if (txbit == 1) begin
                active <= 1;
                data <= txdata;
                state <= tx_start;
            end
            else
                state <= ready;
        end
        
        tx_start: begin
            tx_serial <= 0;
            if(clk_done == 1)
                state <= tx_data;
            else
                state <= tx_start;
        end
    
        tx_data: begin
            tx_serial <= data[bit_index];
                if (bit_index < 7) begin
                    bit_index = bit_index +1 ;
                    state <= tx_data;
                end
                else begin
                    bit_index <= 0;
                    state <= tx_stop;
                end
            end   

        
        tx_stop: begin
                done <= 1'b1;
                active <= 1'b0;
                state <= tx_clean;   
        end
        
        tx_clean: begin
            done <= 1'b1;
            state <= ready;
        end
        
        default: state <= ready;
        
    endcase
 end  
 
 assign tx_active = active;
 assign tx_done = done;
   
endmodule
