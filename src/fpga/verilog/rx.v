`timescale 1ns / 1ps


module rx(
          clk,
          rst,
          enable,
          i_rx,
          i_sw,
          o_rx
);
    input clk;
    input rst;
    input enable;
    input signed [7:0] i_rx;
    input [1:0] i_sw;
    output reg o_rx;
    
    localparam COEF = {8'h0, 8'hfe, 8'hff, 8'h0, 8'h2, 8'h0, 8'hfb, 8'hf5,
                           8'hf9, 8'ha, 8'h25, 8'h3e, 8'h48, 8'h3e, 8'h25, 8'ha, 
                           8'hf9, 8'hf5,8'hfb, 8'h0, 8'h2, 8'h0, 8'hff, 8'hfe};
    wire      reset;
    reg signed [7:0] coef [23:0];
    reg signed [13:0] mult [23:0];//la multiplicacion duplica la resolucion por eso coef y input tiene 7 bits quedan de 14 bits en la parte fraccionaria
    reg signed [18:0] suma [23:0]; // luego sobre donde guarde la multiplicacion tengo que sumarlos y son 24 sumas entronces log2(24) es 5 quedando 14+5=19
                            //5 enteros y 14 fraccionarios    
    reg [1:0] down_counter;
    integer i;
    
    initial begin
      for (i=0; i<24; i=i+1)begin
        coef[i] <= COEF[191-(i*8) -:8];
       end
    end
    always@(posedge clk)begin
        if(rst)begin
            for(i=0; i<24; i=i+1) begin
                suma[i] <= {18{1'b0}};
            end
            for(i=0; i<24; i=i+1) begin
                mult[i] <= {18{1'b0}};
            end
            o_rx <= 0;
            down_counter <= 0;
        end
        else begin
            if(enable) begin
                if (down_counter == 3)begin 
                    down_counter <= 0;
                end
                else begin
                    down_counter <= down_counter+1;
                end
                for (i=0; i<24; i=i+1)begin
                    mult[i] = coef[i]*i_rx;
                end
                suma[0] <= mult[23];
                for (i=1; i<24; i=i+1)begin
                    suma[i] <= mult[23-i] + suma[i-1]; 
                end
                if (down_counter == i_sw)begin
                    o_rx = ~suma[23][17];
                end
            end
            else begin
                down_counter <= down_counter;
                o_rx <= o_rx;
                for (i=0; i<24; i=i+1) begin
                    mult[i] <= mult[i];
                    suma[i] <= suma[i];
                end
            end
        end
    end 

    
endmodule
