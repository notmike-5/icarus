`timescale 1 ns / 100 ps

// Testbench: Adder-Subtractor

module add_sub_tb #(parameter N = 8) ();
  reg ctrl;
  reg [N-1:0] a, b;
  wire [N-1:0] result;
  wire	       cout;
  
  //add_sub_rc #(.N(N)) addsub0 (ctrl, a, b, result, cout);  // Ripple-Carry based
  add_sub #(.N(N)) addsub0 (ctrl, a, b, result, cout);  // Carry-Lookahead based

  initial 
    begin
      $display();
      $display("TB: Adder-Subtractor\n#######################");

      $dumpfile("waves/add_sub.vcd");
      $dumpvars(0, add_sub_tb);

      
      // Addin’
      $monitor("\n%t:\n\t\t\ta: %b\n\t\t\tb: %b\n\t\t\tsum: %b\n\t\t\tcout: %b", 
	       $time, a, b, result, cout);

      $display("\n\t\tAdditions\n\t\t#########");
      ctrl = 0;
      a = 5; b = 3; #1;   //  regular, unsigned addition      
                          //    5 + 3 = 8 w/ carry_out 0
      
      a = '1 >> 1; b = 1; #1;  // Two’s Complement: overflow greatest to most negative              
                               // Unsigned: this is just more regular addition

      a = '1; b = 1; #1;  // Two’s Complement: -1 + 1 = 0
                          // Unsigned: overflow of greatest unsigned number to zero

      
      // Subtractin’
      $monitor("\n%t:\n\t\t\ta: %b\n\t\t\tb: %b\n\t\t\tdiff: %b\n\t\t\tbout: %b", 
	       $time, a, b, result, cout);
      
      $display("\n\t\tSubtractions\n\t\t############");
      ctrl = 1;
      a = 0; b = 1; #1;   // Two’s Complement: 0 - 1 = -1 (i.e. N’b1111....11)
                          // Unsigned: this is overflow of zero to greatest N-bit unsigned number

                          
      a = 5; b = 3; #1;   // regular, unisgned subtraction
                          //   5 - 3 = 2 w/ borrow_out 1 
                          // TODO: Should borrow_out be 1?
      
      a = 1'b1 << (N-1); b = 1; #1;   // Two’s Complement: overflow most negative to greatest
                                      // Unsigned: this is just regular subtraction      
      
      $finish();
    end
endmodule
