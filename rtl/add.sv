// Adder/Subtractor Modules

module half_adder
  (
    input  a, b,
    output sum, cout
   );
  
  assign sum = a ^ b;
  assign cout = a & b;
endmodule // half_adder


module full_adder
  (
    input	a, b, cin,
    output wire	sum, cout
   );

  assign sum = a ^ b ^ cin;
  assign cout = (a & b) | (a ^ b) & cin;
endmodule // full_adder


module half_subtractor
  (
   input a, b,
   output diff, bout
   );

  assign diff = a ^ b;
  assign bout = ~a & b;
endmodule // half_subtractor


module full_subtractor
  (
    input	a, b, bin,
    output wire	diff, bout
   );

  assign diff = a ^ b ^ bin;
  assign bout = (~a & b) | (~(a ^ b) & bin);
endmodule // full_subtractor


// Ripple-Carry Adder (Parallel Adder)
//  - smaller footprint, less complex
//  - adds propogation delay that can compound
module rca_add #(parameter N = 256)
  (
    input [N-1:0]  a, b,
    input	   cin,
    output [N-1:0] sum,
    output cout	  
   );

  wire [N:0] C;
  
  genvar     ii;
  generate
    full_adder FA0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(C[0]));
    for (ii = 1; ii < N; ii++)
      full_adder FA (.a(a[ii]), .b(b[ii]), .cin(C[ii-1]), .sum(sum[ii]), .cout(C[ii]));
  endgenerate
  
  assign cout = C[N-1];
endmodule // rca_add


// Carry-Lookahead Adder
//  - reduces carry propegation delay
//  - costs larger footprint and more complex hardware
module cla_add #(parameter N = 256)
  (
    input [N-1:0]	a, b,
    input		cin,
    output wire [N-1:0]	sum,
    output wire	cout
   );

  wire [N:0] C;
  wire [N-1:0] G, P, S;
  
  assign C[0] = cin;
  
  // adders
  genvar       ii;
  generate
    for(ii = 0; ii < N; ii++)
      full_adder FA (.a(a[ii]), .b(b[ii]), .cin(C[ii]), .sum(S[ii]), .cout());
  endgenerate

  genvar jj;
  generate
    for (jj = 0; jj < N; jj++) begin
      assign G[jj] = a[jj] & b[jj];              // (G)enerate  Gi = Ai * Bi
      assign P[jj] = a[jj] | b[jj];              // (P)ropogate Pi = A + B
      assign C[jj+1] = G[jj] | (P[jj] & C[jj]);  // (C)arry     Ci = Gi + [Pi * C_i-1]
    end
  endgenerate

  assign sum = S;
  assign cout = C[N];
endmodule // cla_add


// Adder-Subtractor (Ripple-Carry based)
//  - uses ctrl signal to select add or subtract
module add_sub_rc #(parameter N = 256)
  (
   input	  ctrl,
   input [N-1:0]  a, b,
   output [N-1:0] sum,
   output	  cout
   );
  
  wire [N-1:0] bmod;
  assign bmod = {N{ctrl}} ^ b;
  
  rca_add #(.N(N)) rca0 (.a(a), .b(bmod), .cin(ctrl), .sum(sum), .cout(cout));
endmodule // add_sub_rc


// Adder-subtractor (Carry-Lookahead based)
//  - uses ctrl signal to select add or subtract
//  - faster than Ripple-carry based but larger footprint, more complex
module add_sub #(parameter N = 256)
  (
   input	  ctrl,
   input [N-1:0]  a, b,
   output [N-1:0] sum,
   output	  cout
   );

  wire [N-1:0] bmod;
  assign bmod = {N{ctrl}} ^ b;

  cla_add #(.N(N)) cla0 (.a(a), .b(bmod), .cin(ctrl), .sum(sum), .cout(cout));
endmodule // add_sub


//TODO: combine Adder and Subtractor modulo p.
// Adder modulo p = 2^255 - 19
module add_modp #(parameter N = 255)
  (
   input [N-1:0]  x, y,
   output [N-1:0] sum
   );
  
  wire [N-1:0] p = 2**255 - 19;
  
  wire [N:0]   r0, r1, r2;
  wire [N-1:0] s0; 
  wire	       c0;
  
  add_sub #(.N(N)) add0 (.ctrl(1'b0), .a(x), .b(y), .sum(s0), .cout(c0));

  // Case 1: 0 <= r0 < p
  assign r0 = {c0, s0};
  
  // Case 2: r0 >= p
  add_sub #(.N(N+1)) sub0 (.ctrl(1'b1), .a(r0), .b({1'b0, p}), .sum(r1), .cout());
  
  // Case 3: r1 = (r0 - p) >= p
  add_sub #(.N(N+1)) sub1 (.ctrl(1'b1), .a(r1), .b({1'b0, p}), .sum(r2), .cout());
  
  assign sum = (0 <= r0) && (r0 < p) ? r0 :
		    (0 <= r1) && (r1 < p) ? r1 :
		    (0 <= r2) && (r2 < p) ? r2 : {N{1'b0}};
endmodule 


// Subtractor modulo p = 2^255 - 19
// - there is a heavy assumption made here
//   that a, b ∈ [0, p − 1]. All bets are off otherwise.
module sub_modp #(parameter N = 255)
  (
   input [N-1:0]  x, y,
   output [N-1:0] diff
   );
  
  wire [N-1:0] p = 2**255 - 19;
  
  wire [N-1:0] r0, r1;
  wire	       b0, b1;	       
  
  // Case 1: 0 <= r0 < p
  add_sub #(.N(N)) sub0 (.ctrl(1'b1), .a(x), .b(y), .sum(r0), .cout(b0));
  
  // Case 2: r0 < 0  -->  r1 = p - r0
  add_sub #(.N(N)) sub1 (.ctrl(1'b0), .a(r0), .b(p), .sum(r1), .cout(b1));

  assign diff = b0 ? r0 : r1;
endmodule


// Carry-Save Adder (3-input)
module csa #(parameter N = 256)
  (
    input [N-1:0] a, b, c,
    output [N:0] sum,
    output cout
   );

  wire [N-1:0] co, S;
  
  genvar       ii;
  generate
    for (ii = 0; ii < N; ii++)
      full_adder csa (.a(a[ii]), .b(b[ii]), .cin(c[ii]), 
		      .sum(S[ii]), .cout(co[ii]));
  endgenerate

  rca_add #(.N(N)) rca (.a({1'b0, S[N-1:1]}), .b(co), .cin(1'b0), 
			.sum(sum[N:1]), .cout(cout));

  assign sum[0] = S[0];
endmodule  
