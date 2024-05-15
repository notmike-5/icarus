module add256 ();
endmodule // add256

module full_adder
  (
   input       a, b, cin,
   output wire sum, cout
   );

 assign sum = a ^ b ^ cin;
 assign cout = ((a ^ b) & cin) | (a & b);
endmodule // full_adder


module full_subtractor
  (
   input       a, b, bin,
   output wire diff, bout
   );

 assign diff = a ^ b ^ bin;
 assign bout = (~a & b) | (~(a ^ b) & bin);
endmodule // full_subtractor


// Ripple-Carry Adder-Subtractor
module rca_add #(parameter N = 256)
 (
  input [N-1:0]	    a, b,
  input [N-1:0]	    S, C,
  output wire [N:0] sum
  );

 bit [N-1:0] bc;

 full_adder fa0 (a[0], b[0], ctrl, S[0], C[0]);
 genvar      ii;
 generate
  for (ii = 0; ii < N; ii++) begin
   assign bc[ii] = b[ii] ^ ctrl;
   full_adder fa (a[ii], b[ii], C[ii-1], S[ii], C[ii]);
  end
 endgenerate
endmodule // rca_add


// Carry Look-ahead Adder
//  - reduces carry propegation delay
//  - costs larger footprint and more complex hardware
module cla_add #(parameter N = 256)
 (
  input [N-1:0]	    a, b,
  input		    cin,
  output wire [N:0] sum
  );

 wire [N:0] C;
 wire [N-1:0] G, P, S;

 // adders
 genvar	      ii;
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
