`timescale 1ns / 1ps

module tb_top_level();

reg         clk;
reg         reset;
reg [1:0]   i_sw;
parameter SEED   = `SEED;

initial begin
        clk = 1'b0;
        reset = 1'b1;
        i_sw = 2'b11;;
        #16 reset  = 1'b0;//16/8=2(pasaron 2 de clk_prbs) y 16/2=8(pasaron 8 del clk_tx)
        #5 reset  = 1'b1;
        #1000 $finish;
    end
    
    always #1 clk    = ~clk;
    
    
     top_level 
    #(
        .SEED(SEED)
    )
    u_top_level
    (
         .rst(reset),
         .CLK100MHZ(clk),
         .i_switch(i_sw)
     );
endmodule
