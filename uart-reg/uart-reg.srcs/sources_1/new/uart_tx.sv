module uart_tx import uart_helper::*;(
  input  logic                         clk_i,
  input  logic                         rst_n,

  output logic                         tx_o,

  // input from the baudrate tick generator
  input  logic                         tick_i,

  input  logic     [MSG_LENGTH-1:0]    word_i,
  input  logic                         we_i,
  output logic                         tx_done_o
);

  state_rx_tx_e     fsm_state;
  uart_indexer_e    msg_indexer;

  always_ff @(posedge clk_i) begin
    if (!rst_n) begin
      // set tx to high (not used)
      tx_o      <= 'b1;
      fsm_state <= IDLE;
      tx_done_o <= 'b0;

      msg_indexer.sample_count         <= 'b0;
      msg_indexer.word_index          <= 'b0;
    end else begin
      case (fsm_state)
        /*
        *     _____ _____  _      ______ 
        *    |_   _|  __ \| |    |  ____|
        *      | | | |  | | |    | |__   
        *      | | | |  | | |    |  __|  
        *     _| |_| |__| | |____| |____ 
        *    |_____|_____/|______|______|
        */
        IDLE: begin
          tx_o                         <= 'b1;

          msg_indexer.sample_count     <= 'b0;
          msg_indexer.word_index      <= 'b0;

          tx_done_o                    <= 'b0;

          if (we_i) begin
            // we want to start transmitting
            fsm_state <= START;
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
          // hold tx low for OVERSAMPLE time
          tx_o                         <= 'b0;
          msg_indexer.sample_count     <= msg_indexer.sample_count + tick_i;

          if (msg_indexer.sample_count == OVERSAMPLE - 1) begin
            msg_indexer.sample_count   <= 'b0;
            msg_indexer.word_index    <= 'b0;
            fsm_state                  <= DATA;
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
          tx_o                         <= word_i[msg_indexer.word_index];
          msg_indexer.sample_count     <= msg_indexer.sample_count + tick_i;

          if (msg_indexer.sample_count == OVERSAMPLE - 1) begin
            msg_indexer.word_index    <= (msg_indexer.word_index == MSG_LENGTH - 1) ? 0 : msg_indexer.word_index + 'b1;
            msg_indexer.sample_count   <= 'b0;

            fsm_state                  <= (msg_indexer.word_index == MSG_LENGTH - 1) ? STOP : DATA;
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
          // hold tx high for OVERSAMPLE time
          tx_o                         <= 'b1;
          msg_indexer.sample_count     <= msg_indexer.sample_count + tick_i;

          if (msg_indexer.sample_count == OVERSAMPLE - 1) begin
            msg_indexer.sample_count   <= 'b0;
            msg_indexer.word_index    <= 'b0;

            fsm_state                  <= IDLE;

            tx_done_o                  <= 'b1;
          end
        end
        default: begin
          fsm_state                    <= IDLE;
          tx_o                         <= 'b1;
          tx_done_o                    <= 'b0;
        end
      endcase
    end
  end
    
endmodule
