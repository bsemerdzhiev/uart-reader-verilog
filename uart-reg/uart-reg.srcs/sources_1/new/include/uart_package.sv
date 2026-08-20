package uart_package;
  parameter integer CLK_FREQ         = 1_000_000;
  parameter integer BAUD_RATE        = 9_600;

  parameter integer OVERSAMPLE       = 16;
  parameter integer HALF_SAMPLE      = OVERSAMPLE / 2;
  parameter integer COUNTER_BITS     = $clog2(OVERSAMPLE);

  parameter integer TICKS_PER_SAMPLE = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);

  parameter integer MSG_LENGTH       = 8;
  parameter integer MSG_BITS         = $clog2(MSG_RX_LENGTH);
endpackage
