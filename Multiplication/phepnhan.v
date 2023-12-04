
module phepnhan (A,B,out,underflow,overflow);
input [31:0] A, B;
output reg underflow,overflow;
output reg [31:0] out ;
reg bitdau_A , bitdau_B ;
reg [8:0]ex_A ,ex_B,ex_out;
reg [47:0] fraction_At,fraction_Bt ,fraction_t;
reg [23:0] fraction_out;
always@(A,B) begin 
    ex_A = {1'b0,A[30:23]} ;
	ex_B = {1'b0,B[30:23]} ;
	bitdau_A = A[31];
	bitdau_B = B[31];
	fraction_At = {24'd0,1'b1,A[22:0]};
	fraction_Bt = {24'd0,1'b1,B[22:0]};
	ex_out = sub9b(ex_A,9'd127,1'b0);
	ex_out = adder9b(ex_out,ex_B,1'b0);
	fraction_t = mux(fraction_At,fraction_Bt);
	if (fraction_t[47]==1'b1) begin
	    ex_out = adder9b(ex_out,9'd1,1'b0);
		out[22:0]= fraction_t[46:24];
		out[30:23]= ex_out[7:0]; 
		   overflow = 1'b0;
			underflow = 1'b0;
			out[31] = bitdau_A ^ bitdau_B ;
		end
	else begin 
	   out[22:0]= fraction_t[45:23];
		out[30:23]= ex_out[7:0];
		out[31] = bitdau_A ^ bitdau_B ;
		overflow = 1'b0;
		underflow = 1'b0;
		out[31] = bitdau_A ^ bitdau_B ;
		end
	if(ex_out == 9'd255 || (ex_out[8]==1'b1 && ex_out[7]==1'b0) ) begin
        out = 32'd0;
        overflow = 1'b1;
      end
   else if(ex_out[8]==1'b1 && ex_out[7]==1'b1) begin
	     out = 32'd0;
        underflow = 1'b1;
      end
	
	end

///
function [47:0]mux;
input [47:0] A,B;
reg [8:0] i,j;
reg [47:0] out0,out1;
begin
    if(B[0]==1) begin
	 out0 = A ;
	 end
	 else begin 
	 out0 = 48'd0;
	 end
	 i = 8'd1;
 while( i<24) begin
     if(B[i] == 1'b1) begin
	     j = i;
		  out1 = A ;
		 while(j>0) begin
		     out1 = dichtrai1b(out1);
			 j = sub9b(j,9'd1,1'b0);
			 end
		 out0 = adder48b(out0,out1,1'b0);	 
         end
	i = adder9b(i,9'd1,1'b0);
       end
    mux = out0;	   
end
endfunction

////
function [1:0]sub1b;// a-b-cin
		input a, b, cin;
		begin
		sub1b[0] = a ^ b ^cin;
		sub1b[1] = (~a)&b | cin&(~(a^b));
		end
endfunction 
function [8:0]sub9b;
	input [8:0]A ,B;
	input cin;
	reg z, z1;
	begin
	{z,sub9b[0]} = sub1b(A[0], B[0], cin);
	{z1,sub9b[1]} = sub1b(A[1], B[1], z);
	{z,sub9b[2]} = sub1b(A[2], B[2], z1);
	{z1,sub9b[3]} = sub1b(A[3], B[3], z);
	{z,sub9b[4]} = sub1b(A[4], B[4], z1);
	{z1,sub9b[5]} = sub1b(A[5], B[5], z);
	{z,sub9b[6]} = sub1b(A[6], B[6], z1);
	{z1,sub9b[7]} = sub1b(A[7], B[7], z);
	{z, sub9b[8]} = sub1b(A[8], B[8], z1);
	end
endfunction
//// 
function [1:0]adder1b;// bit thu 1 la co nho// a+b+cin
	input a, b, cin;
		begin
		adder1b[0] = a ^ b ^ cin;
		adder1b[1] = a&b | (a^b)&cin;
		end
endfunction

function [8:0]adder9b;
input [8:0]A ,B;
	input cin;
	reg z, z1;
	begin
	{z,adder9b[0]} = adder1b(A[0], B[0], cin);
	{z1,adder9b[1]} = adder1b(A[1], B[1], z);
	{z,adder9b[2]} = adder1b(A[2], B[2], z1);
	{z1,adder9b[3]} = adder1b(A[3], B[3], z);
	{z,adder9b[4]} = adder1b(A[4], B[4], z1);
	{z1,adder9b[5]} = adder1b(A[5], B[5], z);
	{z,adder9b[6]} = adder1b(A[6], B[6], z1);
	{z1,adder9b[7]} = adder1b(A[7], B[7], z);
	{z, adder9b[8]} = adder1b(A[8], B[8], z1);
	end
endfunction

function [8:0]adder8b;
input [7:0] A,B;
input cin;
reg z, z1;
	begin
	{z,adder8b[0]} = adder1b(A[0], B[0], cin);
	{z1,adder8b[1]} = adder1b(A[1], B[1], z);
	{z,adder8b[2]} = adder1b(A[2], B[2], z1);
	{z1,adder8b[3]} = adder1b(A[3], B[3], z);
	{z,adder8b[4]} = adder1b(A[4], B[4], z1);
	{z1,adder8b[5]} = adder1b(A[5], B[5], z);
	{z,adder8b[6]} = adder1b(A[6], B[6], z1);
	{z1,adder8b[7]} = adder1b(A[7], B[7], z);
	adder8b[8] = z1;
	end
endfunction
// cong 48bit
function [47:0] adder48b;
input [47:0] X,Y;
input cin;
reg t1,t2;
begin
    {t1,adder48b[7:0]}=adder8b(X[7:0],Y[7:0],cin);
	{t2,adder48b[15:8]}=adder8b(X[15:8],Y[15:8],t1);
	{t1,adder48b[23:16]}=adder8b(X[23:16],Y[23:16],t2);
	{t2,adder48b[31:24]}=adder8b(X[31:24],Y[31:24],t1);
	{t1,adder48b[39:32]}=adder8b(X[39:32],Y[39:32],t2);
	{t2,adder48b[47:40]}=adder8b(X[47:40],Y[47:40],t1);
	end
endfunction
	
////
function [47:0]dichtrai1b;
input [47:0] X;
begin 
    dichtrai1b[0] = 1'b0;
	dichtrai1b[47:1]=X[46:0] ;
	end
	endfunction
endmodule























































































































































