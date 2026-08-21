`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Borislav Semerdzhiev
// 
// Create Date: 08/19/2026 02:54:19 PM
// Design Name: 
// Module Name: uart_register
// Project Name: 
// Target Devices: PYNQ Z2 7020
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_register(
  input wire clk_i,
  input wire rst_n,

  input wire rx_i,
  output wire tx_o,

  output wire [1:0] led
);

  uart_reg_top uart_reg_i(.clk_i(clk_i), 
    .rst_n(rst_n), .rx_i(rx_i), .tx_o(tx_o));

  assign led[0] = rx_i;
  assign led[1] = tx_o;
endmodule
