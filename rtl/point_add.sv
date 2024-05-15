// Module for EdDSA point addition
/*
 Point addition:
 A = (Y1-X1)*(Y2-X2)
 B = (Y1+X1)*(Y2+X2)
 C = T1*2*d*T2
 D = Z1*2*Z2
 E = B-A
 F = D-C
 G = D+C
 H = B+A
 X3 = E*F
 Y3 = G*H
 T3 = E*H
 Z3 = F*G
 
 Point Doubling:
 A = X1^2
 B = Y1^2
 C = 2*Z1^2
 H = A+B
 E = H-(X1+Y1)^2
 G = A-B
 F = C+G
 X3 = E*F
 Y3 = G*H
 T3 = E*H
 Z3 = F*G
 */

// Sketch:
/*
 Stage 1: A, B, C, D can be calculated together.
 Stage 2: E, F, G, H can be calculated together.
 */

module point_add #(N=256);
  (input	  clk, rst_n,
   input [N-1:0]  x1, y1,
   input [N-1:0]  x2, y2,
   output [N-1:0] x3, y3);

  wire [N-1:0] mult_st, div_st;
  
  reg [N-1:0]  P1[3:0], P2[3:0];  // P_n = (X/Z, Y/Z, Z, T=XY)
  
  // submodule instantiations
  divu256 U0 (.clk(clk), .rst(rst_n), 
	      .divd(divd), .dvsr(q), .val(val), .rem(r), 
	      .dbz(dbz), .state(div_st), .data_rdy(data_rdy));

  mult256 U1 (.clk(clk), .rst(rst_n), 
	      .a(a), .b(b), .prod(prod), .acc(acc),
	      .data_rdy(data_rdy), .state(mult_st));

  always @(posedge clk, negedge rst_n)
    if (!rst_n) begin
      A <= '0;
      B <= '0;
      C <= '0;
      D <= '0;
      E <= '0;
      F <= '0;
      G <= '0;
      H <= '0;
      
