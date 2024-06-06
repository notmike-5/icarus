// Module for EdDSA point addition

 // Point addition:
 // A = (Y1-X1)*(Y2-X2)
 // B = (Y1+X1)*(Y2+X2)
 // C = T1*2*d*T2
 // D = Z1*2*Z2
 // E = B-A
 // F = D-C
 // G = D+C
 // H = B+A
 // X3 = E*F
 // Y3 = G*H
 // T3 = E*H
 // Z3 = F*G
 
// Sketch:

// Stage 1: A, B, C, D can be calculated together.
// Stage 2: E, F, G, H can be calculated together.

module point_add #(parameter N = 255)
  (
   input wire	  clk, en, rst_n,
   input [N-1:0]  x1, y1, z1, t1,
   input [N-1:0]  x2, y2, z2, t2,
   output [N-1:0] x3, y3, z3, t3,
   output	  data_rdy
   );

  wire [N-1:0] two_d = 255'h2406d9dc56dffce7198e80f2eef3d13000e0149a8283b156ebd69b9426b2f159;

  reg [N-1:0]  A, B, C, D, E, F, G, H;
  reg [N-1:0]  r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12;
  wire	       dr0, dr1, dr2, dr3, dr4, dr5, dr6, dr7, dr8;
  reg	       dr3_d, en1, en2;

  
  //////////
  // Stage 1a
  
  // A = (Y1-X1) * (Y2-X2)
  sub_modp #(.N(N)) sub0 (.x(y1), .y(x1), .diff(r0));
  sub_modp #(.N(N)) sub1 (.x(y2), .y(x2), .diff(r1));

  mult_modp #(.N(N)) mult0 (.clk(clk), .en(en), .rst_n(rst_n), .x(r0), .y(r1), .prod(r2), .dr(dr0));

  assign A = (!rst_n) ? 'z :
	     (dr0) ? r2 : A;
	     
  // B = (Y1 + X1) * (Y2 + X2)
  add_modp #(.N(N)) add0 (.x(y1), .y(x1), .sum(r3));
  add_modp #(.N(N)) add1 (.x(y2), .y(x2), .sum(r4));
  
  mult_modp #(.N(N)) mult1 (.clk(clk), .en(en), .rst_n(rst_n), .x(r3), .y(r4), .prod(r5), .dr(dr1));

  assign B = (!rst_n) ? 'z :
	     (dr1) ? r5 : B;
  
  // C = (T1 * T2) * two_d
  mult_modp #(.N(N)) mult2 (.clk(clk), .en(en), .rst_n(rst_n), .x(t1), .y(t2), .prod(r6), .dr(dr2));
  mult_modp #(.N(N)) mult3 (.clk(clk), .en(dr2), .rst_n(rst_n), .x(r6), .y(two_d), .prod(r7), .dr(dr3));		    

  assign C = (!rst_n) ? 'z :
	     (dr3) ? r7 : C;
  
  // D = 2 * (Z1*Z2)
  mult_modp #(.N(N)) mult4 (.clk(clk), .en(en), .rst_n(rst_n), .x(z1), .y(z2), .prod(r8), .dr(dr4));
  
  assign D = (!rst_n) ? 'z :
	     (dr4) ? (r8 << 1) : D;

  
  //////////
  // Stage 1b
  
  // E = B - A
  sub_modp #(.N(N)) sub2 (.x(B), .y(A), .diff(E));
  
  // F = D - C
  sub_modp #(.N(N)) sub3 (.x(D), .y(C), .diff(F));
  
  // G = D + C
  add_modp #(.N(N)) add2 (.x(D), .y(C), .sum(G));
  
  // H = B + A
  add_modp #(.N(N)) add3 (.x(B), .y(A), .sum(H));

  always @(posedge clk or negedge rst_n)
    if(!rst_n)
      en2 <= '0;
    else 
      en2 <= (dr3);
  
  //////////
  // Stage 2

  // X3 = E * F
  mult_modp #(.N(N)) mult5 (.clk(clk), .en(en2), .rst_n(rst_n), .x(E), .y(F), .prod(r9), .dr(dr5));
  
  // Y3 = G * H
  mult_modp #(.N(N)) mult6 (.clk(clk), .en(en2), .rst_n(rst_n), .x(G), .y(H), .prod(r10), .dr(dr6));
  
  // Z3 = F * G
  mult_modp #(.N(N)) mult7 (.clk(clk), .en(en2), .rst_n(rst_n), .x(F), .y(G), .prod(r11), .dr(dr7));
  
  // T3 = E * H
  mult_modp #(.N(N)) mult8 (.clk(clk), .en(en2), .rst_n(rst_n), .x(E), .y(H), .prod(r12), .dr(dr8));

  assign data_rdy = (dr5 & dr6 & dr7 & dr8);

  assign x3 = (!rst_n) ? 'z :
	      (data_rdy) ? r9 : x3;
  assign y3 = (!rst_n) ? 'z :
	      (data_rdy) ? r10 : y3;
  assign z3 = (!rst_n) ? 'z :
	      (data_rdy) ? r11 : z3;
  assign t3 = (!rst_n) ? 'z :
	      (data_rdy) ? r12 : t3;

  
  // state logic
  localparam [4:0] RESET = 4'h0;
  localparam [4:0] STAGE1 = 4'h1;
  localparam [4:0] STAGE2 = 4'h2;
  localparam [4:0] DONE = 4'h3;
  
  reg [4:0] state, n_state;

  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      state <= RESET;
    else
      state <= n_state;
  
  assign n_state =        (!rst_n) ? RESET :
		          (en) ? STAGE1 :
			  (state == STAGE1 && en2) ? STAGE2 :
			  (state == STAGE2 && data_rdy) ? DONE : n_state;
endmodule


// Point Doubling:
// A = X1^2
// B = Y1^2
// C = 2*Z1^2
// H = A+B
// E = H-(X1+Y1)^2
// G = A-B
// F = C+G
// X3 = E*F
// Y3 = G*H
// T3 = E*H
// Z3 = F*G

module point_dbl #(parameter N = 255)
  (
   input wire	  clk, en, rst_n,
   input [N-1:0]  x, y, z, t,
   output [N-1:0] X, Y, Z, T,
   output	  data_rdy
   );

  reg [N-1:0]  A, B, C, E, F, G, H;
  reg [N-1:0]  r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12;
  wire	       dr0, dr1, dr2, dr3, dr4, dr5, dr6, dr7, dr8;
  reg	       en1, en2;

  assign en1 = en;
  
  // A = X^2
  mult_modp #(.N(N)) mult0 (.clk(clk), .en(en1), .rst_n(rst_n), .x(x), .y(x), .prod(r0), .dr(d0));

  assign A = (!rst_n) ? 'z :
	     (d0) ? r0 : A;

  // B = Y^2
  mult_modp #(.N(N)) mult1 (.clk(clk), .en(en1), .rst_n(rst_n), .x(y), .y(y), .prod(r1), .dr(d1));

  assign B = (!rst_n) ? 'z :
	     (d1) ? r1 : B;

  // C = 2 * Z^2
  mult_modp #(.N(N)) mult2 (.clk(clk), .en(en1), .rst_n(rst_n), .x(z), .y(z), .prod(r2), .dr(d2));

  assign C = (!rst_n) ? 'z :
	     (d2) ? (r2 << 1) : C;

  // H = A + B
  add_modp #(.N(N)) add0 (.x(A), .y(B), .sum(r3));

  assign H = (!rst_n) ? 'z :
	     (d0 & d1) ? r3 : H;
  
  // E = H - (X1 + Y1)^2
  add_modp #(.N(N)) add1 (.x(x), .y(y), .sum(r4));
  
  mult_modp #(.N(N)) mult3 (.clk(clk), .en(en1), .rst_n(rst_n), .x(r4), .y(r4), .prod(r5), .dr(d3));

  sub_modp #(.N(N)) sub0 (.x(H), .y(r5), .diff(r6));

  assign E = (!rst_n) ? 'z :
	     (d3) ? r6 : E;
  
  // G = A-B
  sub_modp #(.N(N)) sub1 (.x(A), .y(B), .diff(r7));

  assign G = (!rst_n) ? 'z :
	     (d0 & d1) ? r7 : G;
  
  // F = C+G
  add_modp #(.N(N)) add2 (.x(C), .y(G), .sum(r8));

  assign F = (!rst_n) ? 'z :
	     (d0 & d1 & d2) ? r8 : F;


  assign en2 = (d0 & d1 & d2 & d3);
  
  // X3 = E*F
  mult_modp #(.N(N)) mult4 (.clk(clk), .en(en2), .rst_n(rst_n), .x(E), .y(F), .prod(r9), .dr(d4));

  assign X = (!rst_n) ? 'z :
	     (d4) ? r9 : X;
  
  // Y3 = G*H
  mult_modp #(.N(N)) mult5 (.clk(clk), .en(en2), .rst_n(rst_n), .x(G), .y(H), .prod(r10), .dr(d5));

  assign Y = (!rst_n) ? 'z :
	     (d5) ? r10 : Y;
  
  // T3 = E*H
  mult_modp #(.N(N)) mult6 (.clk(clk), .en(en2), .rst_n(rst_n), .x(E), .y(H), .prod(r11), .dr(d6));

  assign T = (!rst_n) ? 'z :
	     (d6) ? r11 : T;
  
  // Z3 = F*G
  mult_modp #(.N(N)) mult7 (.clk(clk), .en(en2), .rst_n(rst_n), .x(F), .y(G), .prod(r12), .dr(d7));

  assign Z = (!rst_n) ? 'z :
	     (d7) ? r12 : Z;
endmodule
