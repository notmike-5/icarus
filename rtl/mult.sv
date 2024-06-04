// Sequential, N-bit x N-bit multiplier
//  - Shift-and-Add-based
module seq_mult #(parameter N = 256)
  (
   input wire		  clk, en,
   input wire		  rst_n,
   input wire [N-1:0]	  a, b, 
   
   output reg [(2*N)-1:0] prod, acc,
   output wire		  data_rdy
   );

  // states
  localparam reset = 2'h0; 
  localparam mult = 2'h1;
  localparam done = 2'h2;
  
  reg [1:0]  state, n_state;
  reg [$clog2(N):0] cnt;

  // interrupted mult recovery
  reg [N-1:0]	      a_cur, b_cur;
  reg		      interrupt, interrupt_d;

  always @(posedge clk or negedge rst_n, a, b)
    if (!rst_n) begin
      interrupt <= '0;
      interrupt_d <= '0;
    end else begin
      interrupt <= (a_cur != a) || (b_cur != b);
      interrupt_d <= interrupt;
    end
  
  always @(posedge clk or negedge rst_n, a, b)    
    if (!rst_n) begin
      a_cur <= '0;
      b_cur <= '0;
    end
    else if (interrupt) begin
      a_cur <= a;
      b_cur <= b;
    end else begin
      a_cur <= a_cur;
      b_cur <= b_cur;
    end
  
  always @(posedge clk or negedge rst_n, a, b)
    begin
      if (!rst_n)
	cnt <= '0;
      else if (state == reset || state == done || interrupt)
	cnt <= '0;
      else if (state != done && cnt < N)
	cnt <= cnt + 1'b1;
      else
	cnt <= cnt;  
    end

  // n_state
  assign n_state = (!rst_n) ? reset :
		   (interrupt) || (state == done) ? reset :
		   (state == reset) && interrupt_d && en ? mult :
		   (state == mult) && (cnt == N) || ((a_cur >> cnt) == '0) ? done : 
		   (state == mult) && (cnt < N) && en ? mult : reset;

  assign data_rdy = en && (state == done);
    
  always @(posedge clk or negedge rst_n, a, b)
    begin
      if (!rst_n)
	state <= reset;
      if (interrupt)
	state <= reset;
      else
	state <= n_state;
    end

  always @(posedge clk, negedge rst_n) 
    begin
      if (!rst_n) 
	acc <= '0;
      else if (interrupt)
	acc <= '0;
      else
	case(state)
	  reset:
	    acc <= '0;

	  mult:
	    acc <= (a_cur[cnt-1]) ? acc + (512'(b_cur) << (cnt-1)) : acc;

	  default: // done
	    acc <= acc;
	endcase
    end

  assign prod = (!rst_n) ? 'z :
		(state == done) ? acc : prod;
endmodule // seq_mult


// multiplication modulo p = 2^255 - 19
module mult_modp #(parameter N = 255)
  (
   input	  clk, en, 
   input	  rst_n,
   input [N-1:0]  x, y,
   output [N-1:0] prod,
   output	  dr
   );

  wire [2*N-1:0] p;
  
  seq_mult #(.N(N)) mult0 (.clk(clk), .en(en), .rst_n(rst_n), .a(x), .b(y),
			   .prod(p), .acc(), .data_rdy(dr));

  reduce redc0 (.n(p), .r(prod));
endmodule // mult_modp


// modular exponentiation modulo p = 2^255 - 19
// - Montgomery Ladder is utilized to avoid
// (simple) side-channel attacks based on timing.
// - the same number of operations (squares and 
// multiplications) are performed in each iteration.
module mod_exp #(parameter N = 255)
  (
   input	  clk, rst_n,
   input [N-1:0]  g, 
   input [N-1:0]  k,
   output [N-1:0] r
   );

  reg [N-1:0]	       X, Y, P0, P1;
  reg [N-1:0]	       R0, R1;
  reg [N-1:0]	       g_cur, k_cur;
  reg [$clog2(N)-1:0]  idx, i;
  
  wire		       dr0, dr1; 
  reg		       en, en_d;

  wire		       data_valid, done;
  reg		       done_d; 
  reg		       interrupt, interrupt_d, interrupt_dd;
  
  priority_encode priority_encode0 (.en(rst_n), .n(k), .i(idx));

  mult_modp square (.clk(clk), .en(en_d), .rst_n(rst_n), .x(X), .y(X), .prod(P0), .dr(dr0));
  mult_modp multiply (.clk(clk), .en(en_d), .rst_n(rst_n), .x(X), .y(Y), .prod(P1), .dr(dr1));

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      en <= '0;
      en_d <= '0;
    end else begin
      en <= rst_n && (i < 8'hFF);
      en_d <= en;
    end
  end   
    
  assign data_valid = (dr0 && dr1);
  
  assign done = data_valid && (i == 0);
  always @(posedge clk or negedge rst_n)
    done_d <= done;
  
  assign interrupt = interrupt_d ^ interrupt_dd;
  
  always @(posedge clk or negedge rst_n, g, k)
    if (!rst_n) begin
      interrupt_d <= '0;
      interrupt_dd <= '0;
    end else begin
      interrupt_d <= (g_cur != g) || (k_cur != k);
      interrupt_dd <= interrupt_d;
    end

  always_comb 
    if (!rst_n) begin
      g_cur = '0;
      k_cur = '0;
    end
    else if (interrupt) begin
      g_cur = g;
      k_cur = k;
    end else begin
      g_cur = g_cur;
      k_cur = k_cur;
    end
  
  always @(posedge clk or negedge rst_n, idx) begin
    if (!rst_n)
      i <= idx;
    else if (interrupt)
      i <= idx; 
    else if (data_valid && i < 8'hFF)
      i <= i - 1;
    else 
      i <= i;
    end
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      R0 <= 'z;
      R1 <= 'z;
    end 
    else if (interrupt) begin
      R0 <= 1;
      R1 <= g;
    end 
    else if (data_valid) begin
      if (k[i] == 0) begin
	R0 <= P0;
	R1 <= P1;
      end 
      else begin
	R0 <= P1;
	R1 <= P0;
      end
    end 
    else begin
      R0 <= R0;
      R1 <= R1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      X <= 'z;
      Y <= 'z;
    end
    else if (!done) begin
      if (k[i] == 0) begin
	X <= R0;
	Y <= R1;
      end 
      else begin
	X <= R1;
	Y <= R0;
      end
    end else begin
      X <= X;
      Y <= Y;
    end
  end

assign r = (!rst_n) ? 'z : 
	   (done_d) ? R0 : r;
endmodule // mod_exp
