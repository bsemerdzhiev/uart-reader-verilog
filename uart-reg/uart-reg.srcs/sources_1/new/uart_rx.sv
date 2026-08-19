module uart_rx import uart_package::*; #(
  parameter integer WORD_LENGTH    = 8,
  parameter integer BITS_FOR_INDEX = $clog2(WORD_LENGTH)
)(
  input  logic                         clk_i,
  input  logic                         rst_n,

  // input from UART
  input  logic                         rx_i,

  // input from the baudrate tick generator
  input  logic                         tick_i,

  // output for the registers
  output logic                         valid_o,
  output logic [WORD_LENGTH-1 : 0]     word_o
);

typedef enum logic [2:0] {
  IDLE,
  START,
  DATA,
  STOP
} uart_rx_state_e;

// current state in the FSM
uart_rx_state_e state;

logic [BITS_FOR_COUNTER-1 : 0]   sample_count;
logic [BITS_FOR_INDEX  -1 : 0]   word_index;

always_ff@(posedge clk_i) begin  
  if (!rst_n) begin
    state        <= IDLE;
    valid_o      <= 'b0;
    sample_count <= 'b0;
    word_index   <= 'b0;
  end else begin
    case (state)  
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
          sample_count <=  0;
          state        <=  START;
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
        sample_count   <=  sample_count + tick_i;
        if (sample_count == HALF_SAMPLE) begin
          word_index   <= 'b0;
          state        <=  (rx_i == 0) ? DATA : IDLE;
          sample_count <=  0;
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
        sample_count         <= sample_count + tick_i;
        
        if (sample_count == HALF_SAMPLE) begin
          // safe to read the current bit
          word_o[word_index] <= rx_i;
          word_index         <= (word_index == WORD_LENGTH - 1)? 0 : word_index + 'b1;
        end else if (sample_count == OVERSAMPLE - 1) begin
          if (word_index == 'b0) begin
            state            <= STOP;
          end
          sample_count       <= 'b0;
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
        sample_count <= sample_count + tick_i;
        if (sample_count == HALF_SAMPLE) begin
          /* 
          *  if rx_i is not 1, then there 
          *  was a problem with the 
          *  end of the message
          */
          if (rx_i == 'b1) begin
            valid_o  <= 'b1;
          end
          state      <= IDLE;
        end
      end
      default: state <= IDLE;
    endcase
  end
end

endmodule
