package uart_package;
  parameter integer CLK_FREQ         = 1_000_000;
  parameter integer BAUD_RATE        = 9_600;
  parameter integer OVERSAMPLE       = 16;
  parameter integer BITS_FOR_COUNTER = $clog2(OVERSAMPLE);

  parameter integer TICKS_PER_SAMPLE = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);
endpackage
