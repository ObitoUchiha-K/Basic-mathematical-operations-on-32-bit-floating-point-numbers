
module chuyenso_tb;
reg  [31:0] A;
wire [3:0]phan_nguyen;
wire [9:0]phan_thapphan;
wire [5:0]phan_mu;
wire sign_phanmu,sign_out;
chuyenso u4(A,phan_nguyen,phan_thapphan,phan_mu,sign_phanmu,sign_out);
initial begin

A={32'b00111000110110000000000000000000};	// so mu  = -13
#500
A={32'b00111111010110000000000000000000};	// so mu  = -1
#500
A={32'b01000001000110000000000000000000};	// so mu  = +3
#500
A={32'b01010011100110000000000000000000};	// so mu  = +40
#1000 $finish;
end 
endmodule
//10000010
//01111110