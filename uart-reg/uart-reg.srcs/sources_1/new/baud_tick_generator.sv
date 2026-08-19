module baud_tick_generator  import uart_package::*;
(
  input  logic                           clk_i,
  input  logic                           rst_n,
  output logic                           tick_o
);

  // used for the counter
  logic [BITS_FOR_COUNTER-1:0] counter_q;

  always_ff @(posedge clk_i) begin
    if (!rst_n) begin
      counter_q <= 'b0;
      tick_o    <= 'b0;
    end else if (counter_q == TICKS_PER_SAMPLE - 1) begin
      counter_q <= 'b0;
      tick_o    <= 'b1;
    end else begin
      counter_q <= counter_q + 'b1;
      tick_o    <= 'b0;
    end
  end

endmodule
