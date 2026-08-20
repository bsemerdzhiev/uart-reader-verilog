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

  typedef enum logic [2:0] {
    IDLE,
    START,
    DATA,
    END
  } state_tx_e;


  // bits used to address into the register
  parameter integer ADDRESS_WIDTH        = 8;

  // width of the words we store
  parameter integer REGISTER_VALUE_WIDTH = 64;

  // how many registers we have
  parameter integer MEMORY_ROWS          = 1024;

  typedef struct packed {
    logic [ADDRESS_WIDTH       -1:0] address;
    logic [REGISTER_VALUE_WIDTH-1:0] value;

    logic                            we_i;
  } register_st;

  typedef enum logic [MSG_BITS-1:0] {
      SUCCESS_WRITE = 'h01,
      SUCCESS_READ  = 'h02,

      FAIL          = 'h00
  } info_message_type_e;

  typedef struct packed {
    logic [REGISTER_VALUE_WIDTH-1:0] read_value;
    info_message_type_e              msg_type;
  } out_message_st;

endpackage
