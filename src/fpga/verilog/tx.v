`timescale 1ns / 1ps

module tx(
            i_tx,
            o_tx,
            clk,
            rst
    );
    
    
    localparam COEF = {8'h0, 8'hfe, 8'hff, 8'h0, 8'h2, 8'h0, 8'hfb, 8'hf5,
                       8'hf9, 8'ha, 8'h25, 8'h3e, 8'h48, 8'h3e, 8'h25, 8'ha, 
                       8'hf9, 8'hf5,8'hfb, 8'h0, 8'h2, 8'h0, 8'hff, 8'hfe};
    
    // Ports
    output  o_tx;
    input   i_tx;
    input   clk;
    input   rst;
    
    wire      reset;
    reg [5:0] buffer_in;
    reg signed [15:0] o_tx;
    reg [1:0] up_count;
    reg signed [7:0] coef [23:0];
    reg signed [10:0] suma;//porque el log en base 2 de 6 que son seis sumas me da 3 entonces yo nunca voy a necesitar mas de 10 bits    
    integer i;
    assign reset    = ~rst;
    initial begin
    //    for (i=0; i<24; i = i + 1)begin
    //        coef[i] = i;
    //    end 
          for (i=0; i<24; i=i+1)begin
            coef[i] <= COEF[191-(i*8) -:8];
           end
    end
    
    
    //Este es el buffer de entrada que cada 4 clk tomo una muestra 
    always@(posedge clk)
    begin
        if(reset)begin
            up_count <= 0;
            buffer_in <= 0;
        end
        else begin
            if(up_count == 2'b11)begin
                buffer_in <= {i_tx, buffer_in[5:1]};
            end
            up_count <= up_count + 1'b1;
            o_tx <= suma;
        end
    end
    
    //SUMA
    always@*
    begin
        suma = {16{1'b0}};
        for (i=0; i<6; i=i+1)
        begin
            if(buffer_in[i] == 1'b1)begin
                suma = suma + coef[(i*4)+up_count];
            end
            else begin
                suma = suma - coef[(i*4)+up_count];
            end
        end
    end
endmodule
