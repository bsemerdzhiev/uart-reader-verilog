module registry import uart_helper::*; (
  input  logic                             clk_i,
  input  logic                             rst_n,

  // used for both r/w
  input  logic [ADDRESS_WIDTH       -1:0]  reg_address_i,
  input  logic [REGISTER_VALUE_WIDTH-1:0]  reg_value_write_i,

  output logic [REGISTER_VALUE_WIDTH-1:0]  reg_value_read_o,

  input  logic                             we_i
);

  logic [REGISTER_VALUE_WIDTH-1:0] memory[MEMORY_ROWS-1:0];

  // registry is inialized and handled (1 cc read/write latency)
  // with BRAM inference in mind
  always_ff @(posedge clk_i) begin
    if (!rst_n) begin
      reg_value_read_o          <= '0;
    end else begin
      if (we_i) begin
        memory[reg_address_i]   <= reg_value_write_i;
      end
      reg_value_read_o          <= memory[reg_address_i];
    end
  end
  
endmodule
