// reduction modulo p
//  - p = 2^255 - 19
//  - returns r in  n == r  (mod p) 
module mod_p 
  #(parameter N = 256)
  (
   input wire [N-1:0] n, 
   input wire	      clk, rst_n,
   
   output reg [255:0] rem
   );
  
  reg [N-1:0] p = {{(N-255){1'b0}}, 255'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed};  // p padded (as needed)
  
  wire [2:0]  div_st;
  wire	      div_dr;
  wire	      dbz;
  
  reg [N-1:0] divd, val, r;

  // TODO: can avoid division delay by identifying numbers already smaller than p
  
  divu256 #(.N(N)) U0 (.clk(clk), .rst(rst_n), 
		       .divd(divd), .dvsr(p), .val(val), .rem(r), 
		       .dbz(dbz), .state(div_st), .data_rdy(div_dr));
  
  assign divd = (rst_n) ? n : 256'b0;
  assign rem = (rst_n && div_dr) ? r : '0;
endmodule 
