`timescale 1 ns / 100 ps

// Testbench: Point Addition

module point_add_tb #(parameter N = 255) ();
  reg            clk, en, rst_n;

  wire [N-1:0]	 Gx = 255'h216936d3cd6e53fec0a4e231fdd6dc5c692cc7609525a7b2c9562d608f25d51a;
  wire [N-1:0]	 Gy = 255'h6666666666666666666666666666666666666666666666666666666666666658;
  wire [N-1:0]	 Gz = 255'b1;
  wire [N-1:0]	 Gt = 255'h67875f0fd78b766566ea4e8e64abe37d20f09f80775152f56dde8ab3a5b7dda3;  // Gx * Gy (mod p)
  
  reg [N-1:0]	 Px, Py, Pz, Pt;
  reg [N-1:0]	 Qx, Qy, Qz, Qt;
  reg [N-1:0]	 Rx, Ry, Rz, Rt;
  
  wire		 data_rdy;
  
  point_add point_add0 (.clk(clk), .en(en), .rst_n(rst_n), 
			.x1(Px), .y1(Py), .z1(Pz), .t1(Pt), 
			.x2(Qx), .y2(Qy), .z2(Qz), .t2(Qt),
			.x3(Rx), .y3(Ry), .z3(Rz), .t3(Rt));

  initial 
    begin
      clk = 0; en = 0;
      rst_n = 0;
      Px = 0; Py = 1; Pz = 1; Pt = 0; // neutral point
      Qx = 0; Qy = 1; Qz = 1; Qt = 0;
    end
  
  always #10 clk = ~clk;
  
  initial begin
    $display();
    $display("TB: Point Addition\n###########################################");

    $dumpfile("waves/point_add.vcd");
    $dumpvars(0, point_add_tb);

    $monitor("%t: (%h, %h, %h, %h)\n", $time, Rx, Ry, Rz, Rt);

    rst_n = 0; #10;
    rst_n = 1;
    
    // TEST 1: 1 + 1
    // Extended (projective) coordinates
    // (0, 4, 4, 0)
    //
    // Affine coordinates
    // (0, 1)
    en = 1; #20; en = 0;
    
    #15500; 

    // Test 2: 2G
    // Extended (projective) coordinates
    // (0x3b6f8891960f6ad45776d1e1213c1bd9de44f888163a76921515e6cf9f3fd67e, 0x336d9ece4cdb30925921f40f14dab827d6e156675107378db6d34c9a874a007e, 0x59e4ea1a52a20ea2fd9cb81712f675b450b27bff31b598ba722d5b0bf61c8608, 0x1f6e08da2d298daafc6ea6fedd5e07c172749500483d139bc532c7e392cad989)
    //
    // Affine coordinates
    // (0x36ab384c9f5a046c3d043b7d1833e7ac080d8e4515d7a45f83c5a14e2843ce0e, 0x2260cdf3092329c21da25ee8c9a21f5697390f51643851560e5f46ae6af8a3c9)
    en = 1; #20; en = 0;
    
    Px = Gx; Py = Gy; Pz = Gz; Pt = Gt;
    Qx = Gx; Qy = Gy; Qz = Gz; Qt = Gt;
    
    #17500;
    $finish;
  end
endmodule
