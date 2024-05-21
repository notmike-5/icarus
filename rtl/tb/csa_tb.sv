`timescale 1 us / 10 ps

module csa_tb #(parameter N = 5) ();
  reg [N-1:0] a, b, c;
  reg	      cin;
  wire [N:0]  sum;
  wire	      cout;

  csa #(.N(N)) csa0 (.a(a), .b(b), .c(c), .cin(cin), .sum(sum), .cout(cout));

  initial 
    begin
      $display();
      $display("TB: Carry-Save Adder\n#######################");
      
      $dumpfile("waves/csa.vcd");
      $dumpvars(0, csa_tb);
      
      $monitor("a = %d, b = %d, c = %d, sum = %d, cout = %d", 
	       a, b, c, sum, cout);
      
      cin = 1'b0;
      a = 5'd10; b = 5'd00; c = 5'd00; #1;
      a = 5'd10; b = 5'd10; c = 5'd00; #1;
      a = 5'd04; b = 5'd06; c = 5'd12; #1;
      a = 5'd11; b = 5'd02; c = 5'd04; #1;
      a = 5'd20; b = 5'd00; c = 5'd20; #1;
      a = 5'd12; b = 5'd05; c = 5'd10; #1;
      a = 5'd07; b = 5'd06; c = 5'd12; #1;
      a = 5'd15; b = 5'd15; c = 5'd15; #1;
   
      $finish();
    end
endmodule
