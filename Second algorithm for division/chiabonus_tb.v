module chiabonus_tb;
reg  [31:0] A,B;
wire [31:0] out;
wire underflow;
wire overflow;
chiabonus u1(A,B,out,underflow,overflow);
initial begin
A={1'b0,8'd126,23'b11100000000000000000000}; // cùng dau ,kq= 
B={1'b0,8'd124,23'b01100000000000000000000};
#400
A={1'b0,8'd126,23'b10100000000000000000000}; // khac dau ,kq =
B={1'b1,8'd125,23'b10100000000000000000000};
#400
A={1'b0,8'd127,23'b00100000000000000000000}; // kq  phần chia float cần chuyển về dạng chuẩn
B={1'b1,8'd126,23'b10100000000000000000000};   //kq  
#500
A={1'b0,8'd254,23'b10100000000000000000000}; // tràn trên 
B={1'b1,8'd126,23'b10000000000000000000000};
#500
A={1'b0,8'd0,23'b10100000000000000000000}; // tran duoi
B={1'b1,8'd128,23'b10100000000000000000000};   
#400 $finish;
end
endmodule