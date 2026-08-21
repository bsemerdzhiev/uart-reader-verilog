module baud_tick_generator  import uart_helper::*;
(
  input  logic                           clk_i,
  input  logic                           rst_n,

  // set to high when a new sample should be read
  output logic                           tick_o
);

  // used for the counter
  logic [COUNTER_BITS_CLOCK-1:0] counter_q;
  /*
  *   _______ _____ _____ _  __      _____ ______ _   _ 
  *  |__   __|_   _/ ____| |/ /     / ____|  ____| \ | |
  *     | |    | || |    | ' /_____| |  __| |__  |  \| |
  *     | |    | || |    |  <______| | |_ |  __| | . ` |
  *     | |   _| || |____| . \     | |__| | |____| |\  |
  *     |_|  |_____\_____|_|\_\     \_____|______|_| \_|
  * 
  */
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
