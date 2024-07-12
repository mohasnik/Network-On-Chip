`include "include/definitions.sv"

module FIFO #(
    parameter DATA_WIDTH = 18,
    parameter FIFO_SIZE = 64

)(
    input clk,
    input rst,
    FifoIO fifo_io
    
);
    localparam buffer_bit_width = $clog2(FIFO_SIZE);
    localparam counter_bit_width = $clog2(FIFO_SIZE + 1);


    // Internal signals
    logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_SIZE-1];

    logic full, empty;
    logic [buffer_bit_width-1 : 0] wr_ptr, rd_ptr;
    logic [counter_bit_width-1 : 0] count;

      // Write operation
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            
            for(int i = 0; i < FIFO_SIZE; i++)
                fifo_mem[i] <= 0;
        end
        else if (fifo_io.wr_en & !full) begin
            fifo_mem[wr_ptr] <= fifo_io.wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read operation
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            fifo_io.rd_data <= `BIT_EXTEND(1'bz, DATA_WIDTH);
        end
        else if (fifo_io.rd_en & !fifo_io.empty) begin
            fifo_io.rd_data <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end

    end

    // Count management
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
        end 
        else begin
            casex ({fifo_io.wr_en, full,  fifo_io.rd_en, empty})
                4'b1010: count <= count;
                4'b10xx: count <= count + 1'b1;
                4'bxx10: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

    // Full and empty flags

    assign full = (count == FIFO_SIZE);
    assign empty = (count == `ZERO_EXTEND(buffer_bit_width));

    assign fifo_io.full = full;
    assign fifo_io.empty = empty;
    assign fifo_io.pkt_address = fifo_mem[0][3:0];

endmodule
