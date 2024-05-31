// N-bit x N-bit divider (unsigned int)

module divu256 #(parameter N = 256)  
 (
   input wire	      clk,
   input wire	      rst,
   input wire [N-1:0] divd, dvsr,
 
   output reg [N-1:0] val, rem, 
   output wire	    dbz,
   output reg [2:0] state,
   output reg data_rdy
  );

 localparam reset = 2'h0;
 localparam active = 2'h1;
 localparam done = 2'h2;

 reg [$clog2(N):0] cnt;
 reg [2:0]	   n_state;
 
 reg [N:0]	   acc;
 reg [N-1:0]	   quo;
 
 always @(posedge clk or negedge rst) begin: counter    
  if (!rst)
    cnt <= '0;
  else if (state == done)
    cnt <= cnt;
  else
    cnt <= cnt + 1'b1;
 end // block: counter

 assign n_state = (state == reset) ? active :
		  (cnt >= N) ? done :
		  (dbz) ? done : n_state;
 
 always @(posedge clk or negedge rst) begin: state_logic
  if (!rst)
    state <= reset;
  else
    state <= n_state;
 end // block: state_logic
 
 always @(posedge clk or negedge rst)
   data_rdy <= (!rst) ? '0 : (state == done && !dbz);  // data ready
 
 assign dbz = (rst) && (dvsr == 0);  // flag div by zero
 
 // division algorithm
 always @(posedge clk or negedge rst) begin: division_alg
  if (!rst)
    {acc, quo} <= '0;
  else if (dbz)
    {acc, quo} <= '0;
  else if (state == active) begin
   acc <= {(acc << 1) | divd[N-cnt +: 1]} >= dvsr ? {(acc << 1) | divd[N-cnt +: 1]} - dvsr : {(acc << 1) | divd[N-cnt +: 1]};
   
   quo <= {(acc << 1) | divd[N-cnt +: 1]} >= dvsr ? {(quo << 1) | 1'b1} : (quo << 1);
  end 
  else begin
   acc <= acc;
   quo <= quo;
  end 
 end // block: division_alg	     
 
 // quotient and remainder
 always @(posedge clk or negedge rst) begin
  if (!rst)
    {val, rem} <= '0;
  else if (dbz)
    {val, rem} <= '0;
  else if (state == done) begin
   val <= quo;
   rem <= acc;
  end else
    {val, rem} <= {val, rem};
 end // val_rem
endmodule // divu256
