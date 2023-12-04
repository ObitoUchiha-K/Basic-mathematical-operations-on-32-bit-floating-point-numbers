module nhan_bonus (A,B,out,underflow,overflow);
input [31:0] A, B;
output reg underflow,overflow;
output reg [31:0] out ;
reg bitdau_A , bitdau_B ;
reg [8:0]ex_A ,ex_B,ex_out;
reg [48:0] fraction_At,fraction_Bt ,fraction_t;
reg [23:0] fraction_out;
always@(A,B) begin 
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
endmodule