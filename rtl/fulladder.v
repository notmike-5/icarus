module fulladder(
   input       a,
   input       b,
   input       cin,
   output wire cout,
   output wire sum);
  
  assign sum = a ^ b ^ cin;
  assign cout = ((a ^ b) & cin) | (a & b);
endmodule
