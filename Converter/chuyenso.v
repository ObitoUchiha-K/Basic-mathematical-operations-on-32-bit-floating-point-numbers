module chuyenso(A,phan_nguyen,phan_thapphan,phan_mu,sign_phanmu,sign_out);
input  [31:0]A; 
output [3:0]phan_nguyen;
output [6:0]phan_mu;
output [9:0]phan_thapphan;
output sign_phanmu,sign_out; // =1 dau am , =0 dau duon
wire [63:0]B ;
wire [7:0]ex_a;
wire [1:0]nhanbiet; // = 2 fraction lon hon 127 , = 1 fraction = 127 , =0 fraction < 127
assign sign_out = A[31]; 
dichbit u1(A,B,ex_a,nhanbiet);
xulyso u2(phan_nguyen,phan_thapphan,phan_mu,nhanbiet,B,sign_phanmu);
endmodule
///
///
module xulyso(phan_nguyen,phan_thapphan,phan_mu,nhanbiet,B,sign_phanmu);
input [63:0]B;
input [1:0]nhanbiet;
output reg [3:0]phan_nguyen;
output reg [6:0]phan_mu;
output reg [9:0]phan_thapphan;
output reg sign_phanmu;
reg [63:0] i,k ;
reg [59:0] phanng_t;
reg [3:0] phantp_t;
reg tam_1;
reg [13:0]tam_2;
reg [13:0] hangtram_tp;
reg [13:0] hangchuc_tp;
reg [13:0] hangdonv_tp;
//
reg [26:0]n;
reg [26:0]phanthapphan_t,x;
reg temp2;

//
always@(B,nhanbiet) begin 
if(nhanbiet == 2) begin
    sign_phanmu = 1'b0; 
	phanng_t = B[63:4] ;
    phantp_t = B[3:0] ; 
	if(phantp_t == 0) begin  /// ngia la so mu >= 4
	     phan_mu = 6'd19;
		 i = 64'd1000000 ;
         i = i*i*i;
         i=i*4'd10 ;///  i = 10^19
		 tam_1 = 1'd1;
	     for(i=i;i>0;i = i/10)  begin
	        if(phanng_t >= i) begin
		        phan_nguyen = phanng_t/i;
		        phanng_t = phanng_t%i; /// lấy phần thap phan
                     if(phanng_t>= 10'd1000)begin
                         k = i/10'd1000;	
                         phan_thapphan= phanng_t/k ;
                     end
                     else if(phanng_t >= 8'd100) begin
					     phan_thapphan= phanng_t;
					 end
                     else begin
					    phan_thapphan= phanng_t*4'd10 ;
                     end
			tam_1 =1'd0;
			phanng_t = 60'd0;
            end
            else begin 
            phan_mu = phan_mu - tam_1;
            end			
	    end	 
    end
	else begin // so mu nho hon 4 lon hon 0
	     tam_2 =phantp_t*14'd625;
		 if(phanng_t >= 10) begin
		     phan_nguyen = phanng_t/4'd10 ;
			 hangtram_tp = phanng_t%4'd10 ;
			 hangchuc_tp = tam_2/10'd1000;
			 hangdonv_tp = tam_2%10'd1000;
			 hangdonv_tp = hangdonv_tp/10'd100;
			 phan_mu = 7'd1;
		 end
		 else begin
		     phan_nguyen = phanng_t;
			 hangtram_tp = tam_2/10'd1000;
			 hangchuc_tp = tam_2%10'd1000;
			 hangchuc_tp = hangchuc_tp/10'd100;
			 hangdonv_tp = tam_2%10'd100;
			 hangdonv_tp = hangdonv_tp/10'd10;
			 phan_mu = 7'd0;
		 end
		 phan_thapphan = hangtram_tp*10'd100 + hangchuc_tp*4'd10 + hangdonv_tp;
	end
end

else if(nhanbiet == 1) begin
phan_nguyen = 4'd1;
phantp_t = B[3:0] ; 
tam_2 = phantp_t*14'd625;
phan_thapphan = tam_2/4'd10;
sign_phanmu = 0;
phan_mu = 0;
end
else begin
phanthapphan_t = B[62:50]*14'd12207; 
sign_phanmu = 1;
phan_mu = 7'd1;
temp2 = 1'd1;
x = 27'd10000000;
    if(phanthapphan_t == 0) begin
	         sign_phanmu = 0;
                 phan_mu = 0;
		 phan_nguyen = 0;
		 phan_thapphan = 0;
    end
    else begin
 for(x = x ; x>0 ; x=x/10 ) begin
     if(phanthapphan_t < x) begin
         phan_mu= phan_mu + temp2;
     end
	 else begin
         phan_nguyen = phanthapphan_t/x ;
		 phanthapphan_t = phanthapphan_t%x; /// lấy phần thap phan
                     if(phanthapphan_t>= 10'd1000)begin
                         n = x/10'd1000;	
                         phan_thapphan= phanthapphan_t/n ;
                     end
                     else if(phanthapphan_t >= 8'd100) begin
					     phan_thapphan= phanthapphan_t;
					 end
                     else begin
					    phan_thapphan= phanthapphan_t*4'd10 ;
                     end
		 temp2 = 1'd0;
		 phanthapphan_t = 27'd0;
     end 
end	
    end 
end
//// 
end
endmodule	 

////// modue dichbit
module dichbit(A,B,ex_a,nhanbiet);
input [31:0]A;
output reg [63:0]B;
output reg [7:0]ex_a;
output reg [1:0]nhanbiet;
reg [9:0] m;
always@(A) begin 
ex_a= A[30:23];
 if(ex_a>127) begin // s? m? t?i ?a l� 59
     ex_a=ex_a - 8'd127 ;
	 B= {59'd0,1'b1,A[22:19]};
	 nhanbiet = 2'd2;
	 for(m =59;m>0;m=m-1) begin
         if(ex_a == m) begin
	     B = B << m ;
		 end
	 end
 end
 else if(ex_a == 127) begin
    ex_a=ex_a - 8'd127 ;
    B= {59'd0,1'b1,A[22:19]};	
	 nhanbiet = 2'd1;
	end
 else begin
    ex_a = 8'd127-ex_a;
	B = {1'b1,A[22:19],59'd0};
	nhanbiet = 2'd0;
	for(m =59;m>0;m=m-1) begin
         if(ex_a == m) begin
	     B = B >> m ;
		 end
	 end
 end
end
endmodule