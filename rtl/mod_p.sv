// reduction modulo q = 2^255 - 19
//  - returns b in  a == b  (mod q) 
module mod_q 
  #(parameter N = 256)
  (
   input wire	      clk, rst_n,
   input wire [N-1:0] a, 
   
   output reg [N-1:0]  b
   );

  reg [N-1:0] q = 256'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  
  reg [N-1:0] divd, val;
  
  wire [N-1:0] r;
  
  wire [2:0]  st;
  wire	      dbz;
  reg	      busy;
  wire	      data_rdy;
	      
  divu256 U0 (.clk(clk), .rst(rst_n), 
	      .divd(divd), .dvsr(q), .val(val), .rem(r), 
	      .dbz(dbz), .state(st), .data_rdy(data_rdy));
	      
  always_comb
    if (!rst_n) begin
      busy = 0;
      divd = 0;
    end
    else if (!busy) begin
      busy = 1;
      divd = a;
    end else begin
      busy = busy;
      divd = divd;
    end 
 
  // result
  always_comb
    if (!rst_n)
      b = 0;
    else if (!busy || (st != 2 && !data_rdy))
      b = 0;
    else
      b = val; 

endmodule 
