`timescale 1ns / 1ps
`define SEED 0
module prbs9(
                o_bit,
                rst,
                clk
    );
    // Ports
    output  o_bit;
    input   clk;
    input   rst;
    // Parameters
    parameter SEED = `SEED;
    // Vars
    wire    reset;
    reg     [8:0]buffer;
    
    assign reset    = ~rst;
    assign o_bit    = buffer[0];
    
    always@(posedge clk) begin
          if(reset) begin
             buffer <= SEED;
          end
          else begin
            buffer <= {buffer[7]^buffer[4]^ 1'b1 , buffer[8:1]};
          end
    end
endmodule