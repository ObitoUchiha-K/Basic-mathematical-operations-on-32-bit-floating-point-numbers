module canbac_n(y,n, ketqua);
input wire [31:0]y,n;
output reg [31:0]ketqua;
reg [31:0]one,n1,y1;
always@(y,n) begin
n1 = n;
y1 = y;
one = {32'b00111111100000000000000000000000};
n1 = chia(one,n);
y1 = ln_y(y);
ketqua = result(n1,y1);
end
/// 
function [31:0]result;
input [31:0]m,ln_y;
reg [31:0]one,T1,T2,M1;
reg [4:0]i;
begin
one = {32'b00111111100000000000000000000000};
M1 =  {32'b00111111100000000000000000000000};
T1 =  {32'b00111111100000000000000000000000};
T2 =  {32'b00111111100000000000000000000000};
m = nhan(m,ln_y);
result = 32'd0;
for(i=1;i<11;i=i+1) begin
M1 = nhan(M1,m);
T1 = nhan(T1,T2);
M1 = chia(M1,T1);
result = cong(result,M1);
T2 =cong(T2,one);
end

result = cong(one,result);
end
endfunction
///
function [31:0]ln_y;
input [31:0]y;
reg [31:0]out,A,B,C,D,am_y,temp;
reg [31:0]one,two,am_one,am_two,A1,B1,D1;
reg [4:0]i,j,k;
begin
one = {32'b00111111100000000000000000000000}; // one = 1
am_one = {32'b10111111100000000000000000000000};
am_y = y;
am_two = {32'b11000000000000000000000000000000} ; // -2
am_y[31] = ~ y[31] ; 
if(y[30:23] <= 8'd127) begin // y 0,5 - >2 
    A = cong(one,am_y);
	D = one;
	B = one;
	C = 32'd0;
	
	for(i=1;i<30;i=i+1) begin
	    D = nhan(A,D);
		temp = chia(D,B);
		C = cong(temp,C);
	    B = cong(B,one);
	end
out = C;
out[31] = ~ C[31] ;
end

else begin // y = 2 -> vc 
     A1 = one;
	 B1 = one;
	 D = am_one;
	 C = one;
	 temp = 32'd0;
	 A = cong(y,am_two);
	 B = cong(y,am_one);

	 for(i=1;i<30;i=i+1) begin
	    A1 = nhan(A,A1);
        B1 = nhan(B,B1);
		D = nhan(D,am_one);
		D1 = cong(A1,D);
		D1 = chia(D1,B1);
		D1 = chia(D1,C);
		temp = cong(temp,D1);
		C = cong(C,one);
	 end 
	  for(i=1;i<30;i=i+1) begin
	    A1 = nhan(A,A1);
        B1 = nhan(B,B1);
		D = nhan(D,am_one);
		D1 = cong(A1,D);
		D1 = chia(D1,B1);
		D1 = chia(D1,C);
		temp = cong(temp,D1);
		C = cong(C,one);
	 end 

out = temp;
end
 ln_y = out;
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
    