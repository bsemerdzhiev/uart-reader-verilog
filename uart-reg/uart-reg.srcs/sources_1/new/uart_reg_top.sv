module uart_reg_top import uart_helper::*; (
  input  logic                         clk_i,
  input  logic                         rst_n,

  input  logic                         rx_i,
  output logic                         tx_o
);

  // signal driven by the baudrate tick gen
  logic                  tick_i;

  // signals for RX
  logic                  valid_rx;
  logic [MSG_LENGTH-1:0] read_byte;

  // signals for TX
  logic [MSG_LENGTH-1:0] write_byte;
  logic                  we;
  logic                  tx_done;

  baud_tick_generator     tick_gen_i(.clk_i(clk_i), .rst_n(rst_n), .tick_o(tick_i));

  uart_rx      uart_rx_i(.clk_i(clk_i), 
    .rst_n(rst_n), .tick_i(tick_i), 
    .rx_i(rx_i), .valid_o(valid_rx), .word_o(read_byte));

  uart_tx      uart_tx_i(.clk_i(clk_i), 
    .rst_n(rst_n), .tick_i(tick_i), 
    .tx_o(tx_o), .word_i(write_byte), .we_i(we), .tx_done_o(tx_done));

  protocol_logic protocol_logic_i(.clk_i(clk_i), .rst_n(rst_n), 
    .valid_rx_i(valid_rx), .read_byte_i(read_byte), 
    .write_byte_o(write_byte), .we_o(we), 
    .tx_done_i(tx_done));
    
endmodule
