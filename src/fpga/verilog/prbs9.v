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
                //buffer <= {buffer[8]^buffer[4]^ 1'b1 , buffer[8:1]};
                buffer <= {buffer[0]^buffer[4] , buffer[8:1]};
            end
          end
    end
    //assign reset    = rst;
    assign o_bit    = buffer[0];
endmodule


/*
module prbs(
            clk,
            rst,
            enable,
            bit_out
            );
    parameter SEED = `SEED;
    
    output bit_out;
    input rst;
    input clk;
    input enable;

    reg [8 : 0] buffer;
    wire        reset;

    assign reset = ~rst;


    always@(posedge clk or posedge reset) begin
        if(reset) begin
            buffer <= SEED;
        end
        else begin
            if (enable) begin
                buffer <= {buffer[0]^buffer[4] , buffer[8:1]};
            end
        end
        
        
    end

    assign bit_out = buffer[0];

endmodule
*/