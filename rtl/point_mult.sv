//
module point_mult
  #(parameter N = 256)
  (
   input wire P,
   input 
   );

  // Montgomery Ladder
  //
  // R0 ← 0
  // R1 ← P
  // for i from m downto 0 do
  //     if di = 0 then
  //         R1 ← point_add(R0, R1)
  //         R0 ← point_double(R0)
  //     else
  //         R0 ← point_add(R0, R1)
  //         R1 ← point_double(R1)

  //     // invariant property to maintain correctness
  //     assert R1 == point_add(R0, P)
  // return R0
