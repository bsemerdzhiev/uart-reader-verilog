module protocol_logic (
  input  logic                         clk_i,
  input  logic                         rst_n,

  // signals for RX
  input  logic                         valid_rx_i,
  input  logic    [MSG_LENGTH-1:0]     read_byte_i,

  // signals for TX
  output logic    [MSG_LENGTH-1:0]     write_byte_o,
  output logic                         we_o,
  input logic                          tx_done_i
);
  
// this device's logic is passive - it only can respond to a message from the pc
// it never initiates a communication with it

typedef enum logic [MSG_BITS-1:0] {
    NONE          = 'h00,
    WRITE_REQUEST = 'h01,
    READ_REQUEST  = 'h02
  } message_type_e;

typedef enum logic [4:0] {
    IDLE,

    FETCH_ADDRESS,
    FETCH_VALUE,

    FETCH_REGISTER,
    STORE_REGISTER,

    REPORT_VALUE
  } operation_type_e;

  message_type_e           msg_type;
  operation_type_e         fsm_state;

  always_ff @(posedge clk_i) begin
    if (!rst_n) begin
      msg_type                  <= NONE;
      fsm_state                 <= IDLE;
    end else begin
      // gate by whether a byte has been read
      if (valid_rx) begin
        case (fsm_state) 
          IDLE: begin
            // determine message type by the read_byte
            case (read_byte_i) 
              NONE: begin
                msg_type        <= NONE;
                fsm_state       <= IDLE;
              end
              WRITE_REQUEST: begin
                msg_type        <= WRITE_REQUEST;
                fsm_state       <= FETCH_ADDRESS;
              end
              READ_REQUEST: begin
                msg_type        <= READ_REQUEST;
                fsm_state       <= FETCH_ADDRESS;
              end
              default: msg_type <= NONE;
            endcase
          end
          FETCH_ADDRESS: begin
            // we have read the address

          end
          FETCH_VALUE: begin

          end

          FETCH_REGISTER: begin

          end
          STORE_REGISTER: begin

          end
          REPORT_VALUE: begin

          end
          default: fsm_state    <= IDLE;
        endcase
      end
    end
  end

endmodule
