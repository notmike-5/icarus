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

  // debug signal
  always @(Px, Py, Px, Pt)
    $strobe("Point P\n: %t: (%h, %h, %h, %h)\n", $time, Px, Py, Pz, Pt);

  initial begin
    $display();
    $display("TB: Point Doubling \n###########################################");

    $dumpfile("waves/point_dbl.vcd");
    $dumpvars(0, point_dbl_tb);

    $monitor("Result\n%t: (%h, %h, %h, %h)\n", $time, Rx, Ry, Rz, Rt);

    #10;
    rst_n = 1;

    // TEST 1: 1 + 1
    // Extended (projective) coordinates
    // (x, y, z, t) = (0, 1, 1, 0)

    // Affine coordinates
    // (0, 1)

    // Result
    // (0, k, k, 0) for some k
    en = 1; #20; en = 0;

    #15500;

    // Test 2: dbl(G) = 2G
    // Extended (projective) coordinates
    // (x, y, z, t) =
    // (31241ddb9a7c254aea224b87b7b0f909886ec1ddfa71625b7aba864c18300a57, 3324984c6cc933db69b782fc3ac951f60a47aa662bbe321c924b2cd95e2d7fd7, 6986c5796b577c574098d1fa3b426292ebd36100339299d16374a93d0278de6b, 18247dc974b59c9540e4564048a87e0fa362dabfedf0bb190eb34e071b4d4999)
    //
    // Affine coordinates
    // (0x36ab384c9f5a046c3d043b7d1833e7ac080d8e4515d7a45f83c5a14e2843ce0e, 0x2260cdf3092329c21da25ee8c9a21f5697390f51643851560e5f46ae6af8a3c9)
    Px = Gx; Py = Gy; Pz = Gz; Pt = Gt;
    en = 1; #20; en = 0;

    #15500;

    // Test 3: dbl(2G) = 4G
    //
    // Result in Extended (projective) coordinates
    // (x, y, z, t) =
    // (56e29092d19f95e93fbf3452f77fbbd83ee11b980130db05ada78ee90205a72f, 4983ae0090ad3539d81185ea9f484dbe643dd6c44c290f4c3c527980b308debf, 6e6b96320addb11548d0d8a0d8b8ffdc509ad64c77dcc2e2493c114415ebc9d0, 430719b03058261a6798750027274c42c2091071be2e4a6ea576e9e3bd92c0c3)
    //
    // Result in Affine coordinates
    // (0x203da8db56cff1468325d4b87a3520f91a739ec193ce1547493aa657c4c9f870,
    // 0x47d0e827cb1595e1470eb88580d5716c4cf22832ea2f0ff0df38ab61ca32112f)
    Px = 255'h3b6f8891960f6ad45776d1e1213c1bd9de44f888163a76921515e6cf9f3fd67e;
    Py = 255'h336d9ece4cdb30925921f40f14dab827d6e156675107378db6d34c9a874a007e;
    Pz = 255'h59e4ea1a52a20ea2fd9cb81712f675b450b27bff31b598ba722d5b0bf61c8608;
    Pt = 255'h1f6e08da2d298daafc6ea6fedd5e07c172749500483d139bc532c7e392cad989;
    en = 1; #20; en = 0;

    #17500;
    $finish;
  end
endmodule
