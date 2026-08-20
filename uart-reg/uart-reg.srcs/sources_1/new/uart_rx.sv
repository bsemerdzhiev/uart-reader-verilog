module uart_rx import uart_helper::*;#(
)(
  input  logic                         clk_i,
  input  logic                         rst_n,

  // input from UART
  input  logic                         rx_i,

  // input from the baudrate tick generator
  input  logic                         tick_i,

  // output for the registers
  output logic                         valid_o,
  output logic [MSG_LENGTH-1 : 0]      word_o
);

  // current state in the FSM
  state_rx_tx_e     fsm_state;
  uart_indexer_e    msg_indexer;

  always_ff@(posedge clk_i) begin  
    if (!rst_n) begin
      fsm_state                            <= IDLE;
      valid_o                              <= 'b0;
      msg_indexer.sample_count             <= 'b0;
      msg_indexer.word_index               <= 'b0;
    end else begin
      case (fsm_state)  
        // we are currently in IDLE
        /*
        *     _____ _____  _      ______ 
        *    |_   _|  __ \| |    |  ____|
        *      | | | |  | | |    | |__   
        *      | | | |  | | |    |  __|  
        *     _| |_| |__| | |____| |____ 
        *    |_____|_____/|______|______|
        */
        IDLE: begin
          valid_o  <= 'b0;

          if (rx_i == 'b0) begin
            msg_indexer.sample_count       <= 0;
            fsm_state                      <= START;
          end
        end
        /*
        *     _____ _______       _____ _______ 
        *    / ____|__   __|/\   |  __ \__   __|
        *   | (___    | |  /  \  | |__) | | |   
        *    \___ \   | | / /\ \ |  _  /  | |   
        *    ____) |  | |/ ____ \| | \ \  | |   
        *   |_____/   |_/_/    \_\_|  \_\ |_|   
        */
        START: begin
          msg_indexer.sample_count         <=  msg_indexer.sample_count + tick_i;

          if (msg_indexer.sample_count == HALF_SAMPLE) begin
            msg_indexer.word_index         <= 'b0;
            fsm_state                      <=  (rx_i == 0) ? DATA : IDLE;
            msg_indexer.sample_count       <= 0;
          end 
        end
        /*
        *   _____       _______       
        *  |  __ \   /\|__   __|/\    
        *  | |  | | /  \  | |  /  \   
        *  | |  | |/ /\ \ | | / /\ \  
        *  | |__| / ____ \| |/ ____ \ 
        *  |_____/_/    \_\_/_/    \_\
        */
        DATA: begin
          msg_indexer.sample_count         <= msg_indexer.sample_count + tick_i;
          
          if (msg_indexer.sample_count == HALF_SAMPLE) begin
            // safe to read the current bit
            word_o[msg_indexer.word_index] <= rx_i;
            msg_indexer.word_index         <= (msg_indexer.word_index == MSG_LENGTH - 1)? 0 : msg_indexer.word_index + 'b1;
          end else if (msg_indexer.sample_count == OVERSAMPLE - 1) begin
            if (msg_indexer.word_index == 'b0) begin
              fsm_state                    <= STOP;
            end
            msg_indexer.sample_count       <= 'b0;
          end
        end
        /*
        *    _____ _______ ____  _____  
        *   / ____|__   __/ __ \|  __ \ 
        *  | (___    | | | |  | | |__) |
        *   \___ \   | | | |  | |  ___/ 
        *   ____) |  | | | |__| | |     
        *  |_____/   |_|  \____/|_|     
        */
        STOP: begin
          msg_indexer.sample_count         <= msg_indexer.sample_count + tick_i;

          if (msg_indexer.sample_count == HALF_SAMPLE) begin
            /* 
            *  if rx_i is not 1, then there 
            *  was a problem with the 
            *  end of the message
            */
            if (rx_i == 'b1) begin
              valid_o                      <= 'b1;
            end
            fsm_state                      <= IDLE;
          end
        end
        default: fsm_state                 <= IDLE;
      endcase
    end
  end

endmodule
