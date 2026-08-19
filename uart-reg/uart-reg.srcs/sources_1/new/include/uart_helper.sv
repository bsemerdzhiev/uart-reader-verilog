package uart_helper;
typedef struct packed {
  logic [COUNTER_BITS -1 : 0]   sample_count;
  logic [MSG_BITS     -1 : 0]   word_index;
} uart_indexer_e;
  
typedef enum logic [2:0] {
  IDLE,
  START,
  DATA,
  STOP
} state_rx_e;

typedef enum logic[2:0] {
  IDLE,
  START,
  DATA,
  END
} state_tx_e;
endpackage
