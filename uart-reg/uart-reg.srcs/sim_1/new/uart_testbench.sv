`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2026 11:43:24 AM
// Design Name: 
// Module Name: uart_testbench
// Project Name: 
// Target Devices: 
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


module uart_testbench();
  logic clk;
  logic rst_n;
  logic rx;
  logic tx;

  initial clk = 1;
  always #5 clk = ~clk;

  uart_reg_top uart_reg(.clk_i(clk), .rst_n(rst_n), .rx_i(rx), .tx_o(tx));

  task send_byte(logic [7:0] byte_to_send);
    repeat (83333) @(posedge clk);
    rx = 0;
    for (integer i = 0; i < 8; i++) begin
      repeat (83333) @(posedge clk);
      rx = byte_to_send[i];
    end
    repeat (83333) @(posedge clk);
    rx = 1;
  endtask

  task receive_byte(logic [7:0] expected_byte);
    repeat (83333) @(posedge clk);
    for (integer i = 0; i < 8; i++) begin
      repeat (83333) @(posedge clk);

      assert (expected_byte[i] == tx);
    end
    repeat (83333) @(posedge clk);
  endtask


  logic [7:0] to_send[7:0];


  initial begin
    to_send[0] = 'h01;
    to_send[1] = 'h01;
    to_send[2] = 'h02;
    to_send[3] = 'h03;
    to_send[4] = 'h04;
    to_send[5] = 'h12;
    to_send[6] = 'h15;
    to_send[7] = 'h71;
    to_send[8] = 'ha1;

    rst_n = 'b0;
    rx    = 1;
    @(posedge clk);
    #1;
    rst_n = 1;

    // ---- WRITE: address 0, value = 0xFFFFFFFFFFFFFFFF ----
    send_byte(8'h01);   // type = WRITE_REQUEST
    send_byte(8'h00);   // address = 0

    for (integer i = 0; i < 8; i++) begin
      send_byte(to_send[i]);
    end
    receive_byte(8'h01);     // 1-byte write confirmation

    // ---- Simulate a real gap between separate host program runs ----
    rx = 1;              // idle line
    repeat (500000) @(posedge clk);   // long idle period, mimics a fresh process starting

    // ---- READ: address 0 ----
    send_byte(8'h02);   // type = READ_REQUEST
    send_byte(8'h00);   // address = 0

    receive_byte(8'h02);     // status byte

    for (integer i = 0; i < 8; i++) begin
      receive_byte(to_send[i]);   // 8 value bytes
    end

    #1000;
    $finish;
  end
endmodule
