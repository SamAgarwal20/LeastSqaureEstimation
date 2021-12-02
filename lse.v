`timescale 1ns/1ns

//Converting 2 dimensional data in 1 dimensional data since verilog does not support two dimensional data inputs
module Ainput (
    input signed [7:0] A00,A01,A10,A11,A20,A21,A30,A31,
    output [63:0] A 
);
    assign A = {A00,A01,A10,A11,A20,A21,A30,A31};  
endmodule

//computing the transpose of the matrix
module matrans (
    input [63:0] A,
    output [63:0] AT
);
    reg signed [7:0] AM [4-1:0][2-1:0];
    reg signed [7:0] ATM [2-1:0][4-1:0];
    integer i,j;
    always @(*) begin
        i=0;
        j=0;
        for (i =0 ;i<4 ;i=i+1 ) begin
            for (j=0 ;j<2 ;j=j+1 ) begin
                ATM[j][i]=AM[i][j];
            end
        end
    end    
endmodule

//computing AT*A (matrix product)
module matmul1  (
    input [2*4*8-1:0]  A ,
    input [2*4*8-1:0] AT ,
    output [2*2*8-1:0] ATA
);
    
    reg signed [7:0] productM[2-1:0][2-1:0];
    reg signed [7:0] AM [4-1:0][2-1:0];
    reg signed [7:0] ATM [2-1:0][4-1:0];
    reg [31:0] product;
    integer i,j,k;
    
    always@(A)
    begin
        {AM[0][0],AM[0][1],AM[1][0],AM[1][1],AM[2][0],AM[2][1],AM[3][0],AM[3][1]}=A;
        {ATM[0][0],ATM[0][1],ATM[0][2],ATM[0][3],ATM[1][0],ATM[1][1],ATM[1][2],ATM[1][3]}=AT;
        i=0;
        j=0;
        k=0;
        for(i=0;i<2;i=i+1)begin
            for(j=0;j<2;j=j+1)begin
                productM[i][j] = 0;
                for(k=0;k<4;k=k+1) begin
                   productM[i][j]=productM[i][j]+ATM[i][k]*AM[k][j]; 
                end
            end
        end
    product = {productM[0][0],productM[0][1],productM[1][0],productM[1][1]};
    end  
    assign ATA=product;
endmodule

//Computing the inverse of the 2X2 matrix formed by multiplying AT and A
module matinverse (
    input [31:0] A,
    output [31:0] Ainv
);
reg signed [7:0] AM [1:0][1:0];
reg signed [7:0] AinvM [1:0][1:0];
reg signed [7:0] det;
reg [31:0] temp;
always @(A) begin
    {AM[0][0],AM[0][1],AM[1][0],AM[1][1]}=A;
    assign det = AM[0][0]*AM[1][1]-AM[0][1]*AM[1][0];
    AinvM[0][0]=AM[1][1]/det;
    AinvM[0][1]=-1*AM[0][1]/det;
    AinvM[1][0]=-1*AM[1][0]/det;
    AinvM[1][1]=AM[0][0]/det;
    temp = {AinvM[0][0],AinvM[0][1],AinvM[1][0],AinvM[1][1]};
end    
    assign Ainv=temp;
endmodule


//Computing ATb, which is the RHS
module matmul2 (
    input [63:0] Atrans,
    input [31:0] B,
    output [15:0] ATB
);
    reg signed [7:0] ATBM[2-1:0];
    reg signed [7:0] BM [4-1:0];
    reg signed [7:0] ATM [2-1:0][4-1:0];
    reg [15:0] product;
    integer i,j,k;
    
    always@(Atrans or B)
    begin
        {BM[0],BM[1],BM[2],BM[3]}=B;
        {ATM[0][0],ATM[0][1],ATM[0][2],ATM[0][3],ATM[1][0],ATM[1][1],ATM[1][2],ATM[1][3]}=Atrans;
        i=0;
        j=0;
        for(i=0;i<2;i=i+1)begin
            ATBM[i]=0;
            for(j=0;j<4;j=j+1)begin
                ATBM[i] = ATBM[i] + ATM[i][k]*BM[k];
            end
        end
    product = {ATBM[0],ATBM[1]};    
    end  
    assign ATB=product;
    
endmodule


//Multiplying everything together to find vx and vy
module matmul3 (
    input [15:0] ATB,
    input [31:0] ATAI,
    output [7:0] vx,
    output [7:0] vy
);
    reg signed [7:0] ATBM[2-1:0];
    reg signed [7:0] ATAIM [2-1:0][2-1:0];
    reg signed [7:0] vels [2-1:0];
    integer i,j,k;
    
    always@(ATB or ATAI)
    begin
        {ATBM[0],ATBM[1]}=ATB;
        {ATAIM[0][0],ATAIM[0][1],ATAIM[1][0],ATAIM[1][1]}=ATAI;
        i=0;
        j=0;
        for(i=0;i<2;i=i+1)begin
            vels[i]=0;
            for(j=0;j<2;j=j+1)begin
                vels[i] = vels[i] + ATAIM[i][k]*ATBM[k];
            end
        end    
    end  
    assign vx=vels[0];
    assign vy=vels[1];
    
endmodule
