// Modular Exponentiation (x, n)
//  - returns b in  x^n == b  (mod p)
//  - p = 2^255 - 19

module mod_exp  
  #(parameter N = 256)
  (
   input wire	      clk, rst_n,
   input wire [N-1:0] x, n,
   output reg [N-1:0] result,
   output wire	      data_rdy
   );
  
  localparam p = 2^255 - 19;

  reg[2:0] state, next_state;
  reg [N-1:0]	acc;
  
  reg [2*N-1:0]	prod, mult_acc;
  wire [1:0]	mult_state;
  wire		mult_data_rdy;
  
  reg [N-1:0]	divd, rem, val;
  wire [2:0]	div_state;
  wire		dbz;  // div by zero
  wire		div_data_rdy;

  wire [N-1:0]	a, b;

  // Submodules
  mult256 U0 (.clk(clk), .rst(rst_n), .data_rdy(mult_data_rdy),
	      .a(a), .b(b), .prod(prod), .acc(mult_acc),
	      .state(mult_state));

  divu256 U1 (.clk(clk), .rst(rst_n), .data_rdy(div_data_rdy),
	      .divd(divd), .dvsr(p), .val(val), .rem(rem), 
	      .state(div_state), .dbz(dbz));

  always @ (posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      acc <= '0;
    end
      
endmodule 
