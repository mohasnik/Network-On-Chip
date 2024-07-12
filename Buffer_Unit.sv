`include "include/definitions.sv"


module Buffer_Unit #(
    parameter DATA_WIDTH = 18,
    parameter MAX_PACKET_SIZE = 64,
    parameter ADDRESS_SIZE = 4
) (
    clk, rst,
    in, 
    out, 
    swicth_allocator_io,
    dest
);
    

    input clk, rst;
    ReqAckIO in;
    ReqAckIO out;
    ReqGntIO swicth_allocator_io;
    output logic [ADDRESS_SIZE-1:0] dest;

    // checking net connections width compatiblity:
    initial begin
        if (in.DATA_WIDTH != DATA_WIDTH || out.DATA_WIDTH != DATA_WIDTH) begin
            $error("Data Width incompatiblity in module Buffer_Unit");
            $stop;
        end
    end


    // parameters
    localparam STATE_IDLE = 0, STATE_INPUT_ACK = 1, STATE_WRITE_FIFO = 2, STATE_REQ_PORT = 3,
                    STATE_TR_REQ = 4, STATE_TR_WAIT_ACK = 5, STATE_TR_SEND = 6;

    // internal wires/registers :
    logic [2:0] ns, ps;
    logic ld_dest;
    logic [1:0] in_flit_type;

    // FIFO :
    FifoIO #(.DATA_WIDTH(DATA_WIDTH), .ADDRESS_SIZE(ADDRESS_SIZE)) fifo_io();
    FIFO #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(MAX_PACKET_SIZE)) Fifo(.clk(clk), .rst(rst), .fifo_io(fifo_io.fifo));

    always_comb begin
        {in.ack, fifo_io.wr_en, fifo_io.rd_en, out.req, swicth_allocator_io.req, ld_dest} = 0;

        case (ps)
            STATE_IDLE : begin
                
            end

            STATE_INPUT_ACK :  begin
                in.ack = 1'b1;
            end

            STATE_WRITE_FIFO :  begin
                fifo_io.wr_en = 1'b1;
                ld_dest = (in_flit_type == `FLIT_HEADER) ? 1'b1 : 1'b0;
            end

            STATE_REQ_PORT :  begin
                swicth_allocator_io.req = 1'b1;
            end

            STATE_TR_REQ: begin
                out.req = 1'b1;
                swicth_allocator_io.req = 1'b1;
            end

            STATE_TR_WAIT_ACK :  begin
                out.req = 1'b0;
                swicth_allocator_io.req = 1'b1;
            end

            STATE_TR_SEND : begin       // There might be some problems over here!
                fifo_io.rd_en = 1'b1;
                swicth_allocator_io.req = 1'b1;
            end


            
        endcase
    end

    always_comb begin
        ns = STATE_IDLE;

        case (ps)
            STATE_IDLE : 
                ns = in.req ? STATE_INPUT_ACK : STATE_IDLE;
            STATE_INPUT_ACK :
                ns = in.req ? STATE_INPUT_ACK : STATE_WRITE_FIFO;
            STATE_WRITE_FIFO :
                ns = (in_flit_type == `FLIT_TAIL) ? STATE_REQ_PORT : STATE_WRITE_FIFO;
            STATE_REQ_PORT : 
                ns = swicth_allocator_io.grant ? STATE_TR_REQ : STATE_REQ_PORT;
            STATE_TR_REQ :
                ns = out.ack ? STATE_TR_SEND : STATE_TR_REQ;
            STATE_TR_WAIT_ACK :
                ns = out.ack ? STATE_TR_WAIT_ACK : STATE_TR_SEND;
            STATE_TR_SEND :
                ns = fifo_io.empty ? STATE_IDLE : STATE_TR_SEND;
        endcase
    end

    always_ff @(posedge clk, posedge rst) begin
        if(rst)
            ps <= STATE_IDLE;
        else begin
            ps <= ns;
        end
    end
    

    // storing destination of packet until transfer is completed
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            dest <= 0;
        end
        else if(ld_dest) begin
            // dest <= fifo_io.pkt_address;      //registering destination address
            dest <= in.data[3:0];      //registering destination address
        end
    end



    assign fifo_io.wr_data = in.data;
    assign out.data = fifo_io.rd_data;

    assign in_flit_type = in.data[17:16];
    
    
endmodule