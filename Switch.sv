`include "include/definitions.sv"

// single multiplexer on each out port:
module Switch_Multiplexer #(
    parameter DATA_WIDTH = 18
)(
    grants,
    buffers_rack_io,
    out_rack_io,
    buffers_ack
);
    input [4:0] grants;
    ReqAckIO buffers_rack_io[0:4];
    ReqAckIO out_rack_io;
    output wire[4:0] buffers_ack;

    logic [2:0] buffer_number;
    logic port_busy;

    // decoding one-hot grants to a single number
    always_comb begin

        casex (grants)
            5'bxxxx1 : begin
                buffer_number = 0;
            end
            
            5'bxxx1x : begin
                buffer_number = 1;
            end

            5'bxx1xx : begin
                buffer_number = 2;
            end

            5'bx1xxx : begin
                buffer_number = 3;
            end

            5'b1xxxx : begin
                buffer_number = 4;
            end

        endcase
    end

    assign port_busy = |{grants};

    
    
    assign out_rack_io.req = port_busy ? 
                        (
                            (buffer_number == 0) ? buffers_rack_io[0].req :
                            (buffer_number == 1) ? buffers_rack_io[1].req :
                            (buffer_number == 2) ? buffers_rack_io[2].req :
                            (buffer_number == 3) ? buffers_rack_io[3].req :
                            (buffer_number == 4) ? buffers_rack_io[4].req : 1'bz

                        ) : 1'bz;
    
    assign out_rack_io.data = port_busy ? 
                        (
                            (buffer_number == 0) ? buffers_rack_io[0].data :
                            (buffer_number == 1) ? buffers_rack_io[1].data :
                            (buffer_number == 2) ? buffers_rack_io[2].data :
                            (buffer_number == 3) ? buffers_rack_io[3].data :
                            (buffer_number == 4) ? buffers_rack_io[4].data : `BIT_EXTEND(1'bz, DATA_WIDTH)

                        ) : `BIT_EXTEND(1'bz, DATA_WIDTH);
    


    generate
        genvar i;
        for(i = 0; i < 5; i++) begin
            assign buffers_ack[i] = (port_busy & (buffer_number == i)) ? out_rack_io.ack : 1'bz;
        end
    endgenerate
    
    
endmodule

module Switch #(
    parameter DATA_WIDTH = 18
)(
    buffer_grants,
    dests,
    buffers_rack_io,
    outs_rack_io
);
    // input [2:0] dests [0:4];
    input [4:0] buffer_grants;  // specifies which of 5 buffers has the permission to start a data transfer
    input [0:4][2:0] dests;
    ReqAckIO buffers_rack_io[0:4];
    ReqAckIO outs_rack_io[0:4];



    typedef enum {LOCAL = 0, WEST = 1, NORTH = 2, EAST = 3, SOUTH = 4} ports;
    // wire [0:4][4:0] buffers_ack;
    wire [4:0] buffers_ack;

    generate 
        genvar i;
        for(i = 0; i < 5; i++) begin
            logic [4:0] grants_out;
            
            // assign grants_out = `BIT_EXTEND((dests[i] == i), 5) & buffer_grants;
            assign grants_out = {{dests[4] == i}, {dests[3] == i}, {dests[2] == i}, {dests[1] == i}, {dests[0] == i}} & buffer_grants;
            assign buffers_rack_io[i].ack = buffers_ack[i];

            // assign buffers_rack_io[i].ack = |{buffers_ack[0][i], buffers_ack[1][i], buffers_ack[2][i], buffers_ack[3][i], buffers_ack[4][i]};

            Switch_Multiplexer #(.DATA_WIDTH(DATA_WIDTH))
                    sw_mux_out (.grants(grants_out), .buffers_rack_io(buffers_rack_io), 
                                .out_rack_io(outs_rack_io[i]), .buffers_ack(buffers_ack));
        end

    endgenerate

    
    

    

    
endmodule