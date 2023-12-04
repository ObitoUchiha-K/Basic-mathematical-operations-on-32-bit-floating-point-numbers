module division (A_in , B_in , ketqua, underflow,overflow);
input [31:0] A_in , B_in;
output reg [31:0] ketqua ;
output reg underflow,overflow;
reg bitdau_A , bitdau_B;
reg [7:0] ex_A , ex_B;
reg [8:0] ex_out;
reg [23:0] fraction_A, fraction_B , fraction_out;
always @ (A_in,B_in) begin
bitdau_A = A_in[31];
bitdau_B = B_in[31];
ex_A = A_in[30:23];
ex_B = B_in[30:23];
fraction_A = {1'b1,A_in[22:0]}; 
fraction_B = {1'b1,B_in[22:0]};
fraction_out = phepchia(fraction_A,fraction_B);
ex_out = adder8b(ex_A,8'd127,1'b0);
if (fraction_out[23] == 1'b0 ) begin
    ex_out =sub9b(ex_out,{1'b0,ex_B},1'b1);
	 fraction_out = dichtrai(fraction_out);
	 end
else begin 
    ex_out =sub9b(ex_out,{1'b0,ex_B},1'b0);
	 end
if(ex_out == 9'd255 || (ex_out[8]==1'b1 && ex_out[7]==1'b0)) begin
 overflow = 1'b1 ;
 underflow = 1'b0;
 ketqua = 32'b0 ;
 end
 else if(ex_out[8]==1'b1 && ex_out[7]==1'b1 )  begin 
				underflow = 1'b1;
				overflow = 1'b0; 
				ketqua[31:0] = 32'b0;
			end
else begin
			overflow = 1'b0;
			underflow = 1'b0;
			ketqua[31] = bitdau_A^bitdau_B;
			ketqua[30:23] = ex_out[7:0];
			ketqua[22:0] = fraction_out[22:0];
			end
end 
/////////
function [0:23] phepchia;
input [23:0] Ain,Bin;
reg [7:0] count;
reg [24:0] temp, temp1;
reg t1;
begin
     temp = {1'b0, Ain};
	 temp1 = {1'b0, Bin};
		if(temp >= temp1) begin
		phepchia[0] = 1; 
		temp = sub25b(temp,temp1,1'b0);
		end
		else begin phepchia[0] = 0; end
		count = 8'd1;
		while(count <= 8'd23) begin
			temp = dichtrai(temp);
			if(temp  >= temp1) begin
				phepchia[count] = 1'b1;
				temp = sub25b(temp,temp1,1'b0);
				{t1,count} = adder8b(count, 8'b00000001,1'b0); // tang bien dem count
			end
			else begin
				phepchia[count] = 1'b0;
				{t1,count} = adder8b(count, 8'b00000000,1'b1);  // tang bien dem count
			end
		end
	end
endfunction	
 ///////////////////
function [24:0] sub25b;
	input [24:0]A, B;
	input cin;
	reg z, z1;
		begin
		{z,sub25b[7:0]} = sub8b(A[7:0], B[7:0], cin);
		{z1,sub25b[15:8]} = sub8b(A[15:8], B[15:8], z);
		{z,sub25b[23:16]} = sub8b(A[23:16], B[23:16], z1);
		{z1,sub25b[24]}  = sub1b(A[24], B[24], z);
		end
endfunction
function [8:0]sub8b;
	input [7:0]A ,B;
	input cin;
	reg z, z1;
	begin
	{z,sub8b[0]} = sub1b(A[0], B[0], cin);
	{z1,sub8b[1]} = sub1b(A[1], B[1], z);
	{z,sub8b[2]} = sub1b(A[2], B[2], z1);
	{z1,sub8b[3]} = sub1b(A[3], B[3], z);
	{z,sub8b[4]} = sub1b(A[4], B[4], z1);
	{z1,sub8b[5]} = sub1b(A[5], B[5], z);
	{z,sub8b[6]} = sub1b(A[6], B[6], z1);
	sub8b[8:7] = sub1b(A[7], B[7], z);
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
function [1:0]sub1b;// a-b-cin
		input a, b, cin;
		begin
		sub1b[0] = a ^ b ^cin;
		sub1b[1] = (~a)&b | cin&(~(a^b));
		end
endfunction 
////////////////
function [8:0] adder8b;// bit thu 8 là co nho
	input [7:0]A, B;
	input cin;
	reg z, z1;
		begin
		{z,adder8b[0]} = adder1b(A[0], B[0],cin);
		{z1,adder8b[1]} = adder1b(A[1], B[1],z);
		{z,adder8b[2]} = adder1b(A[2], B[2],z1);
		{z1,adder8b[3]} = adder1b(A[3], B[3],z);
		{z,adder8b[4]} = adder1b(A[4], B[4],z1);
		{z1,adder8b[5]} = adder1b(A[5], B[5],z);
		{z,adder8b[6]} = adder1b(A[6], B[6],z1);
		adder8b[8:7] = adder1b(A[7], B[7],z);
		end
endfunction
function [1:0]adder1b;// bit thu 1 la co nho// a+b+cin
	input a, b, cin;
		begin
		adder1b[0] = a ^ b ^ cin;
		adder1b[1] = a&b | (a^b)&cin;
		end
endfunction
/////////
function [24:0] dichtrai;
	input [24:0] in;
	begin
		dichtrai[0] = 1'b0;
		dichtrai[24:1] = in[23:0];
	end
endfunction
endmodule

 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	