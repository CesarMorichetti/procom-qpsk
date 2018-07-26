`define SEED 9'b010101011

`timescale 1ns / 1ps

module tb_prbs9();

parameter SEED   = `SEED;

wire o_bit;
reg reset;
reg clk;


initial begin
    clk = 1'b0;
    reset = 1'b1;
    
    #10 reset  = 1'b0;
    #10 reset = 1'b1;
    #100000 $finish;
end

always #1 clk = ~clk;

prbs9 
    #(
        .SEED(SEED)
    )
u_prbs9 
    (
        .o_bit(o_bit),
        .rst(reset),
        .clk(clk)
     );

endmodule