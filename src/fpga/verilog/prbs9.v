`timescale 1ns / 1ps
`define SEED 0
module prbs9(   enable,
                o_bit,
                rst,
                clk
    );
    // Ports
    output  o_bit;
    input enable;
    input   clk;
    input   rst;
    // Parameters
    parameter SEED = `SEED;
    // Vars
    wire    reset;
    reg     [8:0]buffer;
    

    
    always@(posedge clk) begin
          if(rst) begin
             buffer <= SEED;
          end
          else begin
            if(enable)begin
                buffer <= {buffer[8]^buffer[4]^ 1'b1 , buffer[8:1]};
            end
          end
    end
    //assign reset    = rst;
    assign o_bit    = buffer[0];
endmodule