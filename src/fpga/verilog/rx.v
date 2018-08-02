`timescale 1ns / 1ps


module rx(
          clk,
          rst,
          enable,
          i_rx,
          i_phase,
          o_rx
);
    input clk;
    input rst;
    input enable;
    input signed [9:0] i_rx;
    input [1:0] i_phase;
    output reg o_rx;
    
    localparam COEF = {8'h0, 8'hfe, 8'hff, 8'h0, 8'h2, 8'h0, 8'hfb, 8'hf5,
                           8'hf9, 8'ha, 8'h25, 8'h3e, 8'h48, 8'h3e, 8'h25, 8'ha, 
                           8'hf9, 8'hf5,8'hfb, 8'h0, 8'h2, 8'h0, 8'hff, 8'hfe};
    wire      reset;
    reg signed [7:0] coef [23:0];
    reg [13:0] mult [23:0];//la multiplicacion duplica la resolucion por eso coef y input tiene 7 bits quedan de 14 bits en la parte fraccionaria
    reg [18:0] suma [23:0]; // luego sobre donde guarde la multiplicacion tengo que sumarlos y son 24 sumas entronces log2(24) es 5 quedando 14+5=19
                            //5 enteros y 14 fraccionarios    
    integer i;
    
    initial begin
      for (i=0; i<24; i=i+1)begin
        coef[i] <= COEF[191-(i*8) -:8];
       end
    end
    always@(posedge clk)begin
        if(reset)begin
            for(i=0; i<24; i=i+1) begin
                suma[i] <= {18{1'b0}};
            end
            for(i=0; i<24; i=i+1) begin
                mult[i] <= {18{1'b0}};
            end
            o_rx <= 0;
        end
        else begin
            
        
        end
    
    end 

    
endmodule
