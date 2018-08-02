`define SEED 0
`timescale 1ns / 1ps


module top_level(
                rst,
                CLK100MHZ,
                i_switch
                );
                
                
    // Ports
    input       rst;
    input       CLK100MHZ;
    input [3:0] i_switch;
    
    parameter SEED   = `SEED;
    
    wire        o_prbs;
    wire [7:0]  o_tx;
    wire        o_rx;
    wire        reset;
    wire        enable_tx;
    wire        enable_rx;
    reg         enable;
    reg [1:0]   clk_count;

    
    
    assign reset    = ~rst;
    assign enable_tx = i_switch[0];
    assign enable_rx = i_switch[1];
    
    always@(posedge CLK100MHZ)
    begin
    if(reset)begin
        clk_count = 0;
        enable = 0;
    end
    else begin
        clk_count <= clk_count + 1;
        if (clk_count==0)begin
            enable = 1;
        end
        else begin
            enable = 0;
        end
    end
    end
    
        
     prbs9
         #(
         .SEED (SEED)
         )
     prbs_r(
         .clk (CLK100MHZ),
         .enable(enable),
         .rst (reset),
         .o_bit (o_prbs)
         );
     tx
         #(
         )
     tx_r(
         .clk (CLK100MHZ),
         .rst (reset),
         .enable (enable_tx),
         .i_tx (o_prbs),
         .o_tx (o_tx)
    );
     rx
     #(
     )
     rx_r(
     .clk(CLK100MHZ),
     .rst(reset),
     .enable(enable_rx),
     .i_rx(o_tx),
     .i_sw(i_switch[3:1]),
     .o_rx(o_rx)
     );
    
endmodule
