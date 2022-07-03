`timescale 1ns / 1ps

module uart_rv
(
    input clk, rx_serial,
    output rx_bit,
    output [7:0] rx_data
    );
    
 parameter clks_pet_bit = 87;
 
 parameter ready = 3'b000 , rx_start = 3'b001 , rx_data_bit = 3'b010 , rx_stop = 3'b011 , rx_clean = 3'b100; 
 
 reg Rx_data_r = 1'b1;
 reg Rx_data = 1'b1;
 
 reg [7:0] clock_count =0;
 reg [2:0] state = 0;
 reg [2:0] bit_index = 0;
 reg [7:0] data = 0;
 reg ibit = 0;
 
 always@(posedge clk) begin
     Rx_data_r <= rx_serial;
     Rx_data <= Rx_data_r;
     
     case(state)
        ready: begin
            ibit <= 0;
            clock_count <= 0;
            bit_index <= 0;
            
            if(Rx_data == 1'b0) //start bit
                state <= rx_start;
            else
                state <= ready;
        end
        
        rx_start: begin
            if(clock_count == (clks_pet_bit -1)/2) begin
                if(Rx_data == 0) begin
                    clock_count <= 0;
                    state <= rx_data_bit;
                end
                else
                    state <= ready;
            end
            else begin
                clock_count <= clock_count +1 ;
                state <= rx_start;
            end
        end
        
        rx_data_bit: begin
            if(clock_count < clks_pet_bit -1) begin
                clock_count <= clock_count +1 ;
                state <= rx_data_bit;
            end
            else begin
                clock_count <= 0;
                data[bit_index] = Rx_data;
                if(bit_index < 7) begin
                    bit_index <= bit_index + 1;
                    state <= rx_data_bit;
                end
                else begin
                    bit_index <= 0;
                    state <= rx_stop;
                end
            end
        end
        
        rx_stop: begin
            if(clock_count < clks_pet_bit -1) begin
                clock_count <= clock_count +1 ;
                state <= rx_stop;
            end
            else begin
                clock_count <= 0;
                ibit <= 1'b1;
                state <= rx_clean;
            end
        end
        
        rx_clean: begin
            ibit = 1'b0;
            state <= ready;
        end
        
        default: state <= ready;
     
     endcase
    
 end  
 
 assign rx_bit = ibit;
 assign rx_data = data;
   
endmodule
