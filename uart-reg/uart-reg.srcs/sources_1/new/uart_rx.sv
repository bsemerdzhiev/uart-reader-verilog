module uart_rx import uart_package::*; #(
  parameter integer WORD_LENGTH    = 8,
  parameter integer BITS_FOR_INDEX = $clog2(WORD_LENGTH)
)
(
  input  logic                         clk_i,
  input  logic                         rst_n,
  input  logic                         rx_i,

  input  logic                         tick_i,

  output logic                         valid_o,
  logic [WORD_LENGTH-1   :0]           word_o
);

typedef enum logic [3:0] {
  IDLE,
  START,
  DATA,
  STOP
} uart_rx_state_e;

// state in the FSM
uart_rx_state_e state;

logic [BITS_FOR_COUNTER-1:0] sample_count;
logic [BITS_FOR_INDEX-1:0]   word_index;

always_ff@(posedge clk_i) begin  
  if (!rst_n) begin
    state   <= IDLE;
    valid_o <= 'b0;
  end else begin
    case (state)  
      // we are currently in IDLE
      IDLE: begin
        valid_o  <= 'b0;
        if (rx_i == 'b0) begin
          // need to restart the baud rate tick generator
          sample_count   <=  0;
          state          <=  START;
        end
      end
      // we are currently in START
      START: begin
        sample_count   <=  sample_count + tick_i;
        if (sample_count == HALF_SAMPLE) begin
          state        <=  (rx_i == 0) ? DATA : IDLE;
          sample_count <=  0;
        end 
      end
      DATA: begin
        sample_count <= sample_count + tick_i;
        
        if (sample_count == HALF_SAMPLE) begin
          // safe to read the current bit
          word_o[word_index]        <= rx_i;
          word_index                <= word_index + 'b1;

          if (word_index == WORD_LENGTH) begin
            state                   <= STOP;
            sample_count            <= 'b0;
          end
        end
      end
      STOP: begin
        sample_count <=  sample_count + tick_i;
        if (sample_count == HALF_SAMPLE) begin
          /* if rx_i is not 1, then there 
             was a problem with the 
             end of the message
          */
          if (rx_i == 'b1) begin
            valid_o <= 'b1;
          end
          state <= IDLE;
        end
      end
      default: state <= IDLE;
    endcase
  end
end

endmodule
