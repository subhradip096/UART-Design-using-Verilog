`timescale 1ns / 1ps



module uart_tb();
   parameter clock_period = 100;
   parameter bit_period = 8600;
   
   reg clk = 0;
   reg tx_bit =0;
   reg t =0;
   wire tx_done;
   reg [7:0] tx_data = 0;
   reg rx_serial = 0;
   wire [7:0] rx_data;
   
   
   task write;
   input [7:0] data;
   integer i;
   begin
    rx_serial <= 1'b0;
    #(clock_period);
    #1000;
    
    for ( i = 0; i<8; i = i+1) begin
        rx_serial <= data[i];
        #(bit_period);
    end
    
    rx_serial <= 1'b1 ;
    #(bit_period);
   
    end
   endtask
   
   
   uart_rv  UART_RX_INST
    (.clk(clk),
     .rx_serial(rx_serial),
     .rx_bit(),
     .rx_data(rx_data)
     );
   
  uart_tx  UART_TX_INST
    (.clk(clk),
     .txbit(tx_bit),
     .txdata(tx_data),
     .tx_active(),
     .tx_done(tx_done),
     .tx_serial()
     );
 
   always
    #(clock_period/2) clk <= ~ clk;
    
    
   initial begin
   
    @(posedge clk);
    @(posedge clk);
    tx_bit <= 1'b1;
    tx_data <= 8'hAB;
    @(posedge clk);
    tx_bit <= 1'b0;
    @(posedge tx_done);
    
    
    @(posedge clk);
    t = 1'b1;
    write(8'h3F);
    @(posedge clk);
    
    if(rx_data == 8'h3F)
        $display("Test Passed");
    else
        $display("Test Failed");
   end

endmodule
