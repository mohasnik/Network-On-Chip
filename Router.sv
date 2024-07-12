module Router #(
    parameter FLIT_SIZE = 18,
    parameter MAX_PACKET_SIZE = 64,
    parameter NOC_LENGTH = 4,
    parameter NOC_WIDTH = 4,
    parameter ROUTER_ID = 0

) (
    clk, rst,
    in_ports,
    out_ports
);
    input clk, rst;
    ReqAckIO in_ports[0:4];
    ReqAckIO out_ports[0:4];

    localparam  X_ADDRESS_WIDTH = $clog2(NOC_WIDTH);
    localparam  Y_ADDRESS_WIDTH = $clog2(NOC_LENGTH);
    localparam  TOTAL_ADDRESS_WIDTH = X_ADDRESS_WIDTH + Y_ADDRESS_WIDTH;


    wire [0:4][TOTAL_ADDRESS_WIDTH-1:0] buffer_dests;
    wire [0:4][2:0] buffer_port_out_dests;


    ReqAckIO buffer_out_rack[5]();
    ReqGntIO buf_switch_io[5]();
    generate
        genvar i;

        for(i = 0; i < 5; i++) begin : genearte_buffers
            
            Buffer_Unit  #(.DATA_WIDTH(FLIT_SIZE), .MAX_PACKET_SIZE(MAX_PACKET_SIZE), .ADDRESS_SIZE(TOTAL_ADDRESS_WIDTH))
                            buffer_unit (.clk(clk), .rst(rst), .in(in_ports[i]), .out(buffer_out_rack[i]), .swicth_allocator_io(buf_switch_io[i]), .dest(buffer_dests[i]));
        end
    endgenerate


    Routing_Unit #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID))
                    routing_unit (.dest_local(buffer_dests[0]), .dest_west(buffer_dests[1]), .dest_north(buffer_dests[2]), 
                                    .dest_east(buffer_dests[3]), .dest_south(buffer_dests[4]), .port_local(buffer_port_out_dests[0]),
                                    .port_west(buffer_port_out_dests[1]), .port_north(buffer_port_out_dests[2]),
                                    .port_east(buffer_port_out_dests[3]), .port_south(buffer_port_out_dests[4]));
    

    Switch_Allocator switch_allocator (.clk(clk), .rst(rst), 
                                        .buffers_rg({buf_switch_io[0], buf_switch_io[1], buf_switch_io[2], buf_switch_io[3], buf_switch_io[4]}),
                                        .buffers_dport(buffer_port_out_dests)); 


    Switch #(.DATA_WIDTH(FLIT_SIZE)) 
            switch (.buffer_grants({buf_switch_io[4].grant, buf_switch_io[3].grant, buf_switch_io[2].grant, buf_switch_io[1].grant, buf_switch_io[0].grant}), 
                    .dests(buffer_port_out_dests), .buffers_rack_io({buffer_out_rack[0], buffer_out_rack[1], buffer_out_rack[2], buffer_out_rack[3], buffer_out_rack[4]}),
                    .outs_rack_io(out_ports));

endmodule