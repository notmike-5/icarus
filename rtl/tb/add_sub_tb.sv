`timescale 1 ns / 100 ps

// Testbench: Ripple-Carry Adder-Subtractor

module add_sub_tb #(parameter N = 8) ();
  reg ctrl;
  reg [N-1:0] a, b;
  wire [N-1:0] result;
  wire	       cout;
  
  add_sub #(.N(N)) addsub0 (ctrl, a, b, result, cout);

  initial 
    begin
      $display();
      $display("TB: Ripple-Carry Adder-Subtractor\n#######################");

      $dumpfile("waves/sum_add.vcd");
      $dumpvars(0, add_sub_tb);

      // Addin’
      $monitor("\n%t:\n\t\t\ta: %b\n\t\t\tb: %b\n\t\t\tsum: %b\n\t\t\tcout: %b", 
	       $time, a, b, result, cout);

      $display("\n\t\tAdditions\n\t\t#########");
      ctrl = 0;
      a = 5; b = 3; #1;                     //  0: regular, unsigned addition      
                                                // 5 + 3 = 8 w/ carry_out 0
      
      a = '1 >> 1; b = 1; #1;               // 10: Two’s Complement: overflow of the greatest number to the most negative (i.e. 1000....00)
                                                // Unsigned: this is just more regular addition

      a = '1; b = 1; #1;                    // 20: Two’s Complement: -1 + 1 = 0
                                                // Unsigned: this is overflow of the greatest unsigned number (i.e. N’b1111...11) to zero

      
      // Subtractin’
      $monitor("\n%t:\n\t\t\ta: %b\n\t\t\tb: %b\n\t\t\tdiff: %b\n\t\t\tbout: %b", 
	       $time, a, b, result, cout);
      
      $display("\n\t\tSubtractions\n\t\t############");
      ctrl = 1;
      a = 0; b = 1; #1;                     // 30: Two’s Complement: 0 - 1 = -1 (i.e. N’b1111....11)
                                                // Unsigned: this is overflow of zero to the greatest N-bit unsigned number

      a = 5; b = 3; #1;                     // 40: regular, unisgned subtraction
                                                // 5 - 3 = 2 w/ borrow_out 1 # TODO: Should borrow_out be 1?

      a = 1'b1 << (N-1); b = 1; #1;         // 60: Two’s Complement: overflow of the most negative number to the greatest positive number
                                                // Unsigned: this is just regular subtraction      
      
      $finish();
    end
endmodule
