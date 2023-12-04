module sin_x( x, ketqua);
input wire [31:0]x;
output reg [31:0]ketqua;
reg [31:0]A0,A1,A,B1,B2,B3,C,C1,Y,Y1,hai,x1;
reg [4:0]i; 
reg sign_x;

always@(x) begin
x1 = x;
sign_x = x1[31];
x1[31]= 0;
x1=biendoi(x1);
A0 = x1;
A1 = nhan(x1,x1); 
A  = nhan(A1,x1);
hai= {32'b01000000000000000000000000000000}; // 2
B1 = {32'b00111111100000000000000000000000}; // 1
B2 = {32'b01000000000000000000000000000000}; // 2
B3 = {32'b01000000010000000000000000000000}; // 3:
C  = {32'b00111111100000000000000000000000}; // 1
C1 = {32'b10111111100000000000000000000000}; // -1
Y1 = 32'b0;
Y = 32'b0;
if(x1[30:23]<104) begin // từ x= 10^-8 -> 10^-vc thì out = 0
    ketqua = 0;
	 end
else if( x1[30:23] <= 125) begin  // từ x=10^-7 -> 0,49999..
     for(i=1;i<4;i=i+1) begin
         B1 = nhan(B1,B2);
		 B1 = nhan(B1,B3);
		 B2 = cong(B2,hai);
		 B3 = cong(B3,hai);
		 C = nhan(C,C1);
		 Y1 = nhan(A,C);
		 Y1 = chia(Y1,B1);
		 Y = cong(Y,Y1);
		 A = nhan(A,A1);
     end
     ketqua = cong(A0,Y);
     ketqua[31] = sign_x^ketqua[31];
end
else begin                     // từ x =0,5 -> vc
     for(i=1;i<14;i=i+1) begin //
         B1 = nhan(B1,B2);
		 B1 = nhan(B1,B3);
		 B2 = cong(B2,hai);
		 B3 = cong(B3,hai);
		 C = nhan(C,C1);
		 Y1 = nhan(A,C);
		 Y1 = chia(Y1,B1);
		 Y = cong(Y,Y1);
		 A = nhan(A,A1);
     end
     ketqua = cong(A0,Y);
     ketqua[31] = sign_x^ketqua[31];
end
end
/// 
function [31:0]biendoi; // hàm trừ x cho số nguyene lần 2pi
input [31:0]x;
reg [31:0]am_2pi,twopi;
begin
twopi =  {32'b01000000110010010000111111011010}; // 2pi
am_2pi = {32'b11000000110010010000111111011010}; // -2pi
while(x>twopi) begin
   x = cong(x,am_2pi);
   end
 biendoi = x;
end
endfunction

////
function [31:0]cong;
input [31:0]A,B;
reg [31:0]out;
reg [7:0]ex_a,ex_b;
reg [23:0]fractionA,fractionB;
reg [24:0]fraction_out;
reg [55:0]temp_1;
reg [32:0]temp_2;
begin
temp_1 = dichbit(A[30:23],B[30:23],{1'b1,A[22:0]},{1'b1,B[22:0]});
ex_b = temp_1[55:48];
ex_a = temp_1[55:48];
fractionA = temp_1[47:24];
fractionB = temp_1[23:0];
if(A[31]==1'b0 && B[31]==1'b0) begin
  out[31] = 1'b0;
  fraction_out = fractionA + fractionB ;
  if(fraction_out[24] == 1'b1) begin
     out[30:23] = ex_a + 1;
	 out[22:0] = fraction_out[23:1];
  end
  else begin
     out[30:23] = ex_a ;
	 out[22:0] = fraction_out[22:0];
  end
end
else if(A[31]==1'b0 && B[31]==1'b1) begin
   if(fractionA > fractionB) begin
     fraction_out = fractionA - fractionB ;
     out[31] = 1'b0;
	 temp_2 = layso(fraction_out,ex_a);
	 fraction_out=temp_2[24:0];
	 ex_a = temp_2[32:25];
	 out[30:23] = ex_a;
	 out[22:0] = fraction_out[22:0];
	end
   else begin // fra < fracb
     fraction_out = fractionB - fractionA ;
     out[31] = 1'b1;
	 temp_2 = layso(fraction_out,ex_a);
	 fraction_out=temp_2[24:0];
	 ex_a = temp_2[32:25];
	 out[30:23] = ex_a;
	 out[22:0] = fraction_out[22:0];
	end
end
else begin
    if(A[31]==1'b1 && B[31]==1'b0) begin
	     if(fractionA > fractionB) begin
             fraction_out = fractionA - fractionB ;
             out[31] = 1'b1;
	         temp_2 = layso(fraction_out,ex_a);
	         fraction_out=temp_2[24:0];
	         ex_a = temp_2[32:25];
	         out[30:23] = ex_a;
	         out[22:0] = fraction_out[22:0];
	     end
         else begin // fra < fracb
             fraction_out = fractionB - fractionA ;
             out[31] = 1'b0;
	         temp_2 = layso(fraction_out,ex_a);
	         fraction_out=temp_2[24:0];
	         ex_a = temp_2[32:25];
	         out[30:23] = ex_a;
	         out[22:0] = fraction_out[22:0];
	     end
	end
	else begin // A am va B am
         out[31] = 1'b1;
         fraction_out = fractionA + fractionB ;
          if(fraction_out[24] == 1'b1) begin
             out[30:23] = ex_a + 1;
	         out[22:0] = fraction_out[23:1];
          end
          else begin
             out[30:23] = ex_a ;
	         out[22:0] = fraction_out[22:0];
          end
    end
end
cong = out;
end
endfunction
///
function [32:0]layso; // {exa,fraction_out}
input [24:0]fraction_out;
input [7:0]ex_a;
reg [7:0]t1,t2;
begin
 t1 = 8'd0 ;
  for (t2 = 23; t2 > 0  ; t2 = t2 - 1) begin
     if( fraction_out[t2] == 1'b1) begin 
	      ex_a = ex_a - t1;
		   fraction_out = fraction_out << t1;
		   layso[24:0] =fraction_out[24:0];
         fraction_out = 25'd0 ; 
	 end
		  t1 = t1 + 1'b1 ;
   end 
 layso[32:25]  = ex_a ;
end
endfunction
///
function [55:0]dichbit; // {exa,exb,fra,frb)
input [7:0]ex_a,ex_b;
input [23:0]fractionA,fractionB;
reg [7:0] m;
reg [7:0]ex_t;
begin 
 if(ex_a>ex_b) begin 
     ex_t = ex_a - ex_b;
	 for(m =150;m>0;m=m-1) begin
         if(ex_t == m) begin
	     fractionB = fractionB >> m ;
		 ex_b = ex_a;
		 end
	 end
 end
 else if(ex_a == ex_b) begin
    fractionA = fractionA ;
	fractionB =fractionB ;
 end
 else begin // exa<exb
     ex_t =ex_b - ex_a;
	 for(m =150;m>0;m=m-1) begin
         if(ex_t == m) begin
	     fractionA = fractionA >> m ;
		 ex_a = ex_b;
		 end
	 end
 end
 dichbit[55:48] = ex_a;
 dichbit[47:24] = fractionA;
 dichbit[23:0] = fractionB;
end
endfunction
//
function [31:0]nhan;
input [31:0] A, B;
reg [31:0] out ;
reg bitdau_A , bitdau_B ;
reg [8:0]ex_A ,ex_B,ex_out;
reg [48:0] fraction_At,fraction_Bt ,fraction_t;
begin 
   ex_A = {1'b0,A[30:23]} ;
	ex_B = {1'b0,B[30:23]} ;
	bitdau_A = A[31];
	bitdau_B = B[31];
	fraction_At = {2'b01,A[22:0],24'd0};
	fraction_Bt = {25'd0,1'b1,B[22:0]};
	ex_out = ex_A - 9'd127 + ex_B ; 
	fraction_t = mux(fraction_At,fraction_Bt);
	if (fraction_t[47]==1'b1) begin
	    ex_out = ex_out + 1'd1;
		out[22:0]= fraction_t[46:24];
		out[30:23]= ex_out[7:0]; 
			out[31] = bitdau_A ^ bitdau_B ;
		end
	else begin 
	   out[22:0]= fraction_t[45:23];
		out[30:23]= ex_out[7:0];
		out[31] = bitdau_A ^ bitdau_B ;
		out[31] = bitdau_A ^ bitdau_B ;
		end
nhan = out;
	
end
endfunction

////////////	
function [48:0]mux;
input [48:0] A,B;
reg [5:0] n ;
begin
    n = 5'd24 ;
	while ( n > 0 ) begin 
	    if( B[0] == 1'b1) begin 
            B = B + A ;
				B = B >> 1 ;
				n = n - 5'd1 ;
				end
	    else begin
		        B = B >> 1 ; 
				n = n - 5'd1 ;
				end
	end
	mux = B ;
	end
endfunction
/////
function [31:0]chia ; 
input [31:0] A_in , B_in;
reg [31:0] ketqua ;
reg bitdau_A , bitdau_B;
reg [7:0] ex_A , ex_B;
reg [8:0] ex_out;
reg [23:0] fraction_A, fraction_B , fraction_out1;
begin
bitdau_A = A_in[31];
bitdau_B = B_in[31];
ex_A = A_in[30:23];
ex_B = B_in[30:23];
fraction_A = {1'b1,A_in[22:0]}; 
fraction_B = {1'b1,B_in[22:0]};
fraction_out1 = phepchia(fraction_A,fraction_B);
ex_out = ex_A + 8'd127 - ex_B;
if (fraction_out1[23] == 1'b0 ) begin
    ex_out = ex_out - 1'd1;
	fraction_out1 = fraction_out1 << 1;
end
else begin 
    ex_out = ex_out;
end
			ketqua[31] = bitdau_A^bitdau_B;
			ketqua[30:23] = ex_out[7:0];
			ketqua[22:0] = fraction_out1[22:0];
chia = ketqua;
end 

endfunction
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
		temp = temp - temp1 ;
		end
		else begin phepchia[0] = 0; end
		count = 8'd1;
		while(count <= 8'd23) begin
			temp = temp << 1 ;
			if(temp  >= temp1) begin
				phepchia[count] = 1'b1;
				temp = temp - temp1 ;
				count = count + 1'd1;
			end
			else begin
				phepchia[count] = 1'b0;
				count = count + 1'd1;
			end
		end
	end
endfunction	
 ///////////////////
///
endmodule
    