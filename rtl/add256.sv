module add256 ();
endmodule // add256


module full_adder
  (
   input       a, b, cin,
   output wire sum, cout
   );

 assign sum = a ^ b ^ cin;
 assign cout = (a & b) | (a ^ b) & cin;
endmodule // full_adder


module full_subtractor
  (
   input       a, b, bin,
   output wire diff, bout
   );

 assign diff = a ^ b ^ bin;
 assign bout = (~a & b) | (~(a ^ b) & bin);
endmodule // full_subtractor


// Ripple-Carry Adder (Parallel Adder)
//  - smaller footprint
//  - adds propogation delay that can compound
module rca_add #(parameter N = 256)
 (
  input [N-1:0] a, b,
  input cin,
  output [N-1:0] sum,
  output cout
  );

 wire [N:0] C;
 
 genvar	    ii;
 generate
  full_adder FA0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(C[0]));
  for (ii = 1; ii < N; ii++)
    full_adder FA (.a(a[ii]), .b(b[ii]), .cin(C[ii-1]), .sum(sum[ii]), .cout(C[ii]));
  assign cout = C[N-1];
 endgenerate
endmodule // rca_add


// Carry Look-ahead Adder
//  - reduces carry propegation delay
//  - costs larger footprint and more complex hardware
module cla_add #(parameter N = 256)
 (
  input [N-1:0]     a, b,
  input             cin,
  output wire [N:0] sum
  );

 wire [N:0] C;
 wire [N-1:0] G, P, S;

 // adders
 genvar       ii;
 generate
  for(ii = 0; ii < N; ii++)
    full_adder FA (.a(a[ii]), .b(b[ii]), .cin(C[ii]), 
                   .sum(S[ii]), .cout());
 endgenerate

 // (G)enerate Gi=Ai*Bi, (P)ropogate Pi=A+B, and (C)arry Ci=Gi+[Pi * C_i-1] terms
 genvar jj;
 generate
  for (jj = 0; jj < N; jj++) begin
   assign G[jj] = a[jj] & b[jj];
   assign P[jj] = a[jj] | b[jj];
   assign C[jj+1] = G[jj] | (P[jj] & C[jj]);
  end
 endgenerate

 assign C[0] = 1'b0;
 assign sum = {C[N], S};
endmodule // cla_add

module add_sub #(parameter N = 4)
 (
  input ctrl,
  input [N-1:0] a, b,
  output [N-1:0] result,
  output cb_bit
  );

 wire [N-1:0] bmod;

 assign bmod = {N{ctrl}} ^ b;

 rca_add #(.N(N)) rca0 (.a(a), .b(bmod), .cin(ctrl), .sum(result), .cout(cb_bit));
 endmodule
