`timescale 1ns / 1ps


module ber( clk,
            rst,
            enable,
            i_prbs,
            i_rx,
            o_err
);

input   clk;
input   rst;
input   enable;
input   i_prbs;
input   i_rx;
output  o_err;
/*
reg [511:0] buffer_in;
reg adaptation;
reg [8:0] ber_shift;
reg [8:0] min_ber_shift;
reg [8:0] count;
reg [31:0]error;
reg [31:0]min_error;
*/
reg [511:0] buffer_in;
reg o_error;
reg [8:0] count;
reg [31:0]error;
reg [8:0] ber_shift;

assign o_err = o_error;

always@(posedge clk)
begin
    if(rst)begin
        buffer_in <= 0;
        o_error <= 0;
        count <= 0;
        error <= 0;
        ber_shift <= 0;  
    end
    else begin
        if (enable) begin
            buffer_in <= {i_rx, buffer_in[511:1]};
            error <= error + (buffer_in[511-ber_shift] ^ i_prbs);
            count <= count + 1;
            if (count == 511-ber_shift)begin
                if (error == 0) begin
                    o_error <= 1;
                end
                else begin
                    ber_shift <= ber_shift + 1;
                    error <= 0;
                    o_error <= 0;
                end
            end
        end
    end
            
end

endmodule
/*
`define SEQ_LEN 511
`define REG_LEN 32


module ber(
           clk,
           rst,
           enable,
           sx,
           dx,
           error_flag
           );

    parameter SEQ_LEN = `SEQ_LEN;

    localparam REG_LEN = `REG_LEN;
    localparam SHIFT_LEN = $clog2(SEQ_LEN);

    input clk;
    input rst;
    input enable;
    input sx;
    input dx;
    output error_flag;

    reg [REG_LEN-1:0] error_count;
    reg [REG_LEN-1:0] min_error_count;
    reg [SHIFT_LEN-1:0] shift;
    reg [SHIFT_LEN-1:0] min_shift;
    reg [SHIFT_LEN-1:0] counter;
    reg [SEQ_LEN-1:0] buffer_in;
    reg adapt_flag;

    assign reset = ~rst;

    assign error_flag = (error_count != 0);

    always@(posedge clk or posedge reset)
    begin
        if (reset) begin
            error_count <= {REG_LEN{1'b0}};
            min_error_count <= {REG_LEN{1'b1}};
            shift <= {SHIFT_LEN{1'b0}};
            min_shift <= {SHIFT_LEN{1'b0}};
            counter <= {SHIFT_LEN{1'b0}};
            buffer_in <= {SEQ_LEN{1'b0}};
            adapt_flag <= 1;
        end
        else begin
            if (enable) begin
                buffer_in <= {sx, buffer_in[SEQ_LEN-1:1]};
                if (adapt_flag) begin
                    if (counter < SEQ_LEN) begin
                        error_count <= error_count + (buffer_in[SEQ_LEN-1-shift] ^ dx);
                        counter <= counter + 1;
                    end
                    else begin
                        if (error_count < min_error_count) begin
                            min_error_count <= error_count;
                            min_shift <= shift;
                        end
                        counter <= 0;
                        error_count <= 0;
                        shift <= shift + 1;
                    end
                    if (shift == SEQ_LEN) begin
                        adapt_flag <= 0;
                        error_count <= 0;
                    end
                end
                else begin
                    error_count <= error_count + buffer_in[SEQ_LEN-1-min_shift] ^ dx;
                end
            end
        end
    end
endmodule
*/

/*
    if(rst)begin
    buffer_in <= 0;
    adaptation <= 1;
    ber_shift <= 0;
    min_ber_shift <= 0;
    count <= 0;
    error <= 0;
    min_error <= {511{1'b1}};;
end
else begin
   if(enable) begin
        buffer_in <= {i_rx, buffer_in[511:1]};
        if (adaptation) begin
            if (count < 511) begin
                error <= error + (buffer_in[511-ber_shift] ^ i_prbs);
                count <= count + 1;
            end 
            else begin
                if (error < min_error) begin
                    min_error <= error;
                    min_ber_shift <= ber_shift;
                end
                    count <= 0;
                    error <= 0;
                    ber_shift <= ber_shift + 1;
             end
             if (ber_shift == 511)begin
                 ber_shift <= 0;
                 adaptation <= 0;
             end
        end
        else begin
             error <= error + buffer_in[1023-min_ber_shift] ^ i_prbs;
        end
   end 
end
end
*/