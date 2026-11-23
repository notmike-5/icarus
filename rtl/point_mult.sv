//
module point_mult
  #(parameter N = 255)
  (
   input wire clk, en, rst_n,
   input wire x, y, z, t,
   input wire n
   );

  reg [N-1:0] R0, R1;
  reg [N-1:0] x1, x2, x3, x4;
  reg [N-1:0] y1, y2, y3, y4;
  reg [N-1:0] z1, z2, z3, z4;
  reg [N-1:0] t1, t2, t3, t4;
  reg [N-1:0] X, Y, Z, T;
  wire        dr_add, dr_dbl;

  wire [N-1:0] P = 255'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed;

  assign R0 = (!rst_n) ? 255'b0 : R0;
  assign R1 = (!rst_n) ? P : R1;


  point_add add0 (.clk(clk), .en(en), .rst_n(rst_n),
                  .x1(x1), .y1(y1), .z1(z1), .t1(t1),
                  .x2(x2), .y2(y2), .z2(z2), .t2(t2),
                  .x3(x3), .y3(y3), .z3(z3), .t3(t3),
                  .data_rdy(dr_add));

  point_dbl dbl0 (.clk(clk), .en(en), .rst_n(rst_n),
                  .x(x4), .y(y4), .z(z4), .t(t4),
                  .X(X), .Y(Y), .Z(Z), .T(T),
                  .data_rdy(dr_dbl));

  always_ff @(posedge clk) begin
  // Modular Exponentiation by Montgomery Ladder
  //
  // R0 ← 0
  // R1 ← P
  // for i from m down to 0 do
  //     if di = 0 then
  //         R1 ← point_add(R0, R1)
  //         R0 ← point_double(R0)
  //     else
  //         R0 ← point_add(R0, R1)
  //         R1 ← point_double(R1)

  //     // invariant property to maintain correctness
  //     assert R1 == point_add(R0, P)
  // return R0
  end
endmodule
