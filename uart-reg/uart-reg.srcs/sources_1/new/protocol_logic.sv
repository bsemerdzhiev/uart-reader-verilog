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

    REPORT_TYPE,
    REPORT_VALUE
  } operation_type_e;


  register_st                        register;
  out_message_st                     out_msg;

  logic [REGISTER_VALUE_WIDTH-1:0]   counter;

  message_type_e                     msg_type;
  operation_type_e                   fsm_state;

  registry                           mem_registry_i(.clk_i(clk_i), 
    .rst_n(rst_n), .reg_address_i(register.address),
    .reg_value_write_i(register.value), .reg_value_read_o(out_msg.read_value), 
    .we_i(register.we_i));

  always_ff @(posedge clk_i) begin
    if (!rst_n) begin
      msg_type                  <= NONE;
      fsm_state                 <= IDLE;
    end else begin
      // gate by whether a byte has been read
      case (fsm_state) 
        IDLE: begin
          if (valid_rx_i) begin
            we_o                <= 'b0;
            // determine message type by the read_byte
            case (read_byte_i) 
              NONE: begin
                msg_type        <= NONE;
                fsm_state       <= IDLE;
              end
              WRITE_REQUEST: begin
                msg_type        <= WRITE_REQUEST;
                fsm_state       <= FETCH_ADDRESS;

                out_msg.msg_type<= SUCCESS_WRITE;
              end
              READ_REQUEST: begin
                msg_type        <= READ_REQUEST;
                fsm_state       <= FETCH_ADDRESS;

                out_msg.msg_type<= SUCCESS_READ;
              end
              default: msg_type <= NONE;
            endcase
          end
        end
        FETCH_ADDRESS: begin
          if (valid_rx_i) begin
            register.address[counter+:MSG_LENGTH] <= read_byte_i;
            // reset the read counter if we are at the end of the msg
            counter                               <= (counter == ADDRESS_WIDTH - MSG_LENGTH) ? 'b0 : counter + MSG_LENGTH;

            if (counter == ADDRESS_WIDTH - MSG_LENGTH) begin
              case (msg_type) 
                WRITE_REQUEST: begin
                  fsm_state <= FETCH_VALUE;
                end
                READ_REQUEST: begin
                  fsm_state <= FETCH_REGISTER;
                end
                default: begin
                  // this shouldnt happen, so perhaps raise a flag
                end
              endcase
            end
          end
        end
        FETCH_VALUE: begin
          if (valid_rx_i) begin
            register.value[counter+:MSG_LENGTH]   <= read_byte_i;
            // reset the read counter if we are at the end of the msg
            counter                               <= (counter == REGISTER_VALUE_WIDTH - MSG_LENGTH) ? 'b0 : counter + MSG_LENGTH;

            if (counter == REGISTER_VALUE_WIDTH - MSG_LENGTH) begin
              case (msg_type) 
                WRITE_REQUEST: begin
                  fsm_state              <= STORE_REGISTER;

                  register.we_i          <= 'b1;
                end
                default: begin
                  // this shouldnt happen, so perhaps raise a flag
                end
              endcase
            end
          end
        end

        FETCH_REGISTER: begin
          // read register value from the registry
          fsm_state        <= REPORT_TYPE;
        end
        STORE_REGISTER: begin
          // write value into the registry
          register.we_i    <= 'b0;
          fsm_state        <= REPORT_TYPE;
        end
        REPORT_TYPE: begin
          write_byte_o     <= out_msg.msg_type;
          we_o             <= 'b1;

          if (tx_done_i) begin
            fsm_state      <= REPORT_VALUE;
          end
        end
        REPORT_VALUE: begin
          we_o             <= 'b1;
          write_byte_o     <= out_msg.read_value[counter+:MSG_LENGTH];

          if (tx_done_i) begin
            counter        <= (counter == REGISTER_VALUE_WIDTH - MSG_LENGTH) ? 'b0 : counter + MSG_LENGTH;
            
            if (counter == REGISTER_VALUE_WIDTH - MSG_LENGTH) begin
              we_o         <= 'b0;
              fsm_state    <= IDLE;
            end
          end
        end
        default: begin
          we_o             <= 'b0;
          fsm_state        <= IDLE;
        end
      endcase
    end
  end

endmodule
