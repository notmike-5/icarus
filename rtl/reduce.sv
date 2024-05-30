// reduction modules modulo p = 2^255 - 19 

// fast reduction modulo p of a 510-bit product ab
module reduce #(parameter N = 255)
  (
   input [2*N-1:0] n,  // 510-bit product,   ab = a x b
   output [N-1:0] r    // 255-bit remainder, ab = r  (mod p)
   );
  
  wire [255:0] p = 2**255 - 19;
  
  wire [N-1:0] n_hi, n_lo, m_hi, m_lo; 
  wire [N+4:0] n1, n4, m; 
  wire [N-1:0] m1, m4;
  wire [N:0]   r0, r1;
  wire [N+4:0] s0, s1, s2, s3;
  wire	       c0, c1, c2, c3;
  
  assign n_hi = n >> N;
  assign n_lo = n[N-1:0];
  
  assign n1 = (n_hi << 1);
  assign n4 = (n_hi << 4);  // (19 * n_hi) == n_hi + (n_hi << 1) + (n_hi << 4)
  
  csa #(.N(N+4)) csa0 (.a(n_hi), .b(n1), .c(n4), .sum(s0), .cout(c0));
  cla_add #(.N(N+5)) cla0 (.a(n_lo), .b(s0), .cin(c0), .sum(s1), .cout(c1));
  
  assign m = c1 ? {c1, s1} : {s1};  // m < 20 * 2^255
  
  assign m_lo = m[N-1:0];
  assign m_hi = m >> N;
  
  assign m1 = 256'(m_hi << 1);
  assign m4 = 256'(m_hi << 4);  // (19 * m_hi) == m_hi + (m_hi << 1) + (m_hi << 4)
  
  csa #(.N(N+4)) csa1 (.a(m_hi), .b(m1), .c(m4), .sum(s2), .cout(c2));
  cla_add #(.N(N+5)) cla1 (.a(m_lo), .b(s2), .cin(c2), .sum(s3), .cout(c3));
  
  assign r0 = c3 ? {c3, s3} : {s3};  // r0 < 2 * p
  
  add_sub addsub0 (.ctrl(1'b1), .a(r0), .b(p), .sum(r1), .cout()); // r1 < p
  
  assign r = (r0 > p) ? r1 : r0;
endmodule
