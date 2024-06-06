`timescale 1 ns / 100 ps

// Testbench: Point Doubling

module point_dbl_tb #(parameter N = 255) ();
  reg            clk, en, rst_n;

  wire [N-1:0]	 Gx = 255'h216936d3cd6e53fec0a4e231fdd6dc5c692cc7609525a7b2c9562d608f25d51a;
  wire [N-1:0]	 Gy = 255'h6666666666666666666666666666666666666666666666666666666666666658;
  wire [N-1:0]	 Gz = 255'b1;
  wire [N-1:0]	 Gt = 255'h67875f0fd78b766566ea4e8e64abe37d20f09f80775152f56dde8ab3a5b7dda3;  // Gx * Gy (mod p)
  
  reg [N-1:0]	 Px, Py, Pz, Pt;
  reg [N-1:0]	 Rx, Ry, Rz, Rt;
  
  wire		 data_rdy;
  
  point_dbl point_dbl0 (.clk(clk), .en(en), .rst_n(rst_n), 
			.x(Px), .y(Py), .z(Pz), .t(Pt), 
			.X(Rx), .Y(Ry), .Z(Rz), .T(Rt));

  initial 
    begin
      clk = 0; en = 0;
      rst_n = 0;
      Px = 0; Py = 1; Pz = 1; Pt = 0; // neutral point
    end
  
  always #10 clk = ~clk;
  
  initial begin
    $display();
    $display("TB: Point Doubling \n###########################################");

    $dumpfile("waves/point_dbl.vcd");
    $dumpvars(0, point_dbl_tb);

    $monitor("%t: (%h, %h, %h, %h)\n", $time, Rx, Ry, Rz, Rt);

    rst_n = 0; #10;
    rst_n = 1;
    
    // TEST 1: 1 + 1
    // Extended (projective) coordinates
    // (x, y, z, t)
    //
    // Affine coordinates
    // (0, 1)
    en = 1; #20; en = 0;
    
    #15500; 

    // Test 2: 2G
    // Extended (projective) coordinates
    // (x, y, z, t)
    //
    // Affine coordinates
    // (0x36ab384c9f5a046c3d043b7d1833e7ac080d8e4515d7a45f83c5a14e2843ce0e, 0x2260cdf3092329c21da25ee8c9a21f5697390f51643851560e5f46ae6af8a3c9)
    Px = Gx; Py = Gy; Pz = Gz; Pt = Gt;
    en = 1; #20; en = 0;
    
    #17500;
    $finish;
  end
endmodule
