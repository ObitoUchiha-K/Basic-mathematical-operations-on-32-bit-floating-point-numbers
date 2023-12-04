module chiabonus (A,B,out,underflow,overflow);
input  [31:0] A, B;
output reg underflow,overflow;
output reg [31:0] out ;
reg bitdau_A , bitdau_B ;
reg [8:0]ex_A ,ex_B,ex_out,k;
reg [31:0]temp, C , D, A_temp, B_temp;
reg [32:0] out_temp;
always@( B) begin   //< A\B > /// Xn+1= Xn(2-Xn.B)
A_temp = A; 
B_temp = B;
 	bitdau_A = A[31];
	bitdau_B = B[31];
	A_temp[31] = 1'b0;  // 
	B_temp[31] = 1'b0;
	/////// 1/ex_B
	ex_B = {1'b0,B[30:23]} ;
	if (ex_B >= 9'd127) begin
	ex_B = ex_B - 9'd127 ;
	ex_B = 9'd127 - ex_B ; 
	          end
		else begin 
		ex_B =  9'd127 - ex_B ;
	    ex_B = 9'd127 + ex_B ; 
		end
	B_temp[30:23] = 8'd127 ; // dùng để đưa B về dạng 1.xxx .2^0	
	/////
	
////////// // temp = temp.(C - B.temp)
      C = {1'b0,1'b1,30'd0}; /// = 2
      temp ={1'b0,8'h7e,23'd0}; // x(n=0) = 0,5
	    k = 9'd4 ;
       while(k>0) begin  
	      D = nhan_1(temp,B_temp) ;     
		  D = tru_1(C,D);
		  temp = nhan_1(temp,D) ;
		  k = k - 1'b1 ;
		 end
////// out = A.temp
       temp[30:23] = temp[30:23] + ex_B - 8'd127;
     	 out_temp = nhan(temp,A_temp) ;
		 ex_out= {out_temp[32],out_temp[30:23]};
		 out[31:0] = out_temp[31:0];
   if(ex_out == 9'd255 || (ex_out[8]==1'b1 && ex_out[7]==1'b0) ) begin
        out = 32'd0;
        overflow = 1'b1;
		underflow = 1'b0;
      end
   else if(ex_out[8]==1'b1 && ex_out[7]==1'b1) begin
	    out = 32'd0;
        underflow = 1'b1;
		overflow = 1'b0;
	  end
	  else begin
	    out[31] = bitdau_A ^ bitdau_B;
		underflow = 1'b0;
	    overflow = 1'b0;
		   end
	  end
	  ///////  modun_tru
function [31:0]tru_1;
input [31:0] A_in , B_in;
reg bitdau_A , bitdau_B;
reg [8:0] ex_A , ex_B,temp1, n ,m;
reg [8:0] ex_out;
reg [23:0] fraction_A, fraction_B,fraction_out ;
 begin
   ex_A = {1'b0,A_in[30:23]} ;
	ex_B = {1'b0,B_in[30:23]} ;
  fraction_A = {1'b1,A_in[22:0]}; 
  fraction_B = {1'b1,B_in[22:0]};
  temp1 = ex_A - ex_B ;
  if (temp1 == 9'd2 ) begin
     fraction_B = fraction_B >> 2 ;
	 ex_B = ex_B + 9'd2;
	 end
else if(temp1 == 9'd3 ) begin 
     fraction_B = fraction_B >> 3 ;
	 ex_B = ex_B + 9'd3;
	 end
  else begin 
	  fraction_B = fraction_B  ;
	 end
  fraction_out = fraction_A - fraction_B;
  
  m = 9'd0 ;
 for (n = 23; n > 0  ; n = n - 1) begin
     if( fraction_out[n] == 1'b1) begin 
	      ex_A = ex_A - m;
			fraction_out = fraction_out << m;
		   tru_1[22:0] = fraction_out[22:0];
         fraction_out = 23'd0 ; 
		  end
		  m = m + 1'b1 ;
   end
	tru_1[30:23] = ex_A[7:0];
	end
endfunction
//////////
 ///////  modun_nhan
function [31:0]nhan_1;
input [31:0] A, B;
reg bitdau_A , bitdau_B ;
reg [8:0]ex_A ,ex_B,ex_out;
reg [48:0] fraction_At,fraction_Bt ,fraction_t;
reg [23:0] fraction_out;
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
		nhan_1[22:0]= fraction_t[46:24];
		nhan_1[30:23]= ex_out[7:0]; 
			nhan_1[31] = bitdau_A ^ bitdau_B ;
		end
	else begin 
	  nhan_1[22:0]= fraction_t[45:23];
		nhan_1[30:23]= ex_out[7:0];
		nhan_1[31] = bitdau_A ^ bitdau_B ;
		end	
end
endfunction
////////////	
 ///////  modun_nhan ở phép nhân cuối
function [32:0]nhan;
input [31:0] A, B;
reg bitdau_A , bitdau_B ;
reg [8:0]ex_A ,ex_B,ex_out;
reg [48:0] fraction_At,fraction_Bt ,fraction_t;
reg [23:0] fraction_out;
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
		nhan[22:0]= fraction_t[46:24];
		nhan[30:23]= ex_out[7:0]; 
			nhan[31] = bitdau_A ^ bitdau_B ;
		end
	else begin 
	  nhan[22:0]= fraction_t[45:23];
		nhan[30:23]= ex_out[7:0];
		nhan[31] = bitdau_A ^ bitdau_B ;
		end
	nhan[32] = ex_out[8];
end
endfunction
/////
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
 
endmodule