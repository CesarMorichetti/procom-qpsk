`define SEED 9'b010101011

`timescale 1ns / 1ps

module tb_tx();

reg clk_tx;
reg clk_prbs;
reg reset;
wire o_prbs;
wire [15:0] o_tx;
parameter SEED   = `SEED;

initial begin
        clk_tx = 1'b0;
        reset = 1'b1;
        clk_prbs = 1'b1;
        //i_tx = 1'b0;
        #16 reset  = 1'b0;//16/8=2(pasaron 2 de clk_prbs) y 16/2=8(pasaron 8 del clk_tx)
        #16 reset  = 1'b1;
        //#8 i_tx = 1'b1;
        //#8 i_tx = 1'b0;
        //#8 i_tx = 1'b0;
        //#8 i_tx = 1'b1;
        //#8 i_tx = 1'b1;
        #1000 $finish;
    end
    
    always #1 clk_tx    = ~clk_tx;
    always #4 clk_prbs  = ~clk_prbs;
    
    
     prbs9 
    #(
        .SEED(SEED)
    )
    u_prbs9 
    (
        .o_bit(o_prbs),
        .rst(reset),
        .clk(clk_prbs)
     );
      
    tx 
        #(
        )
    u_tx 
        (
            .i_tx(o_prbs),
            .o_tx(o_tx),
            .rst(reset),
            .clk(clk_tx)
         );
         
endmodule