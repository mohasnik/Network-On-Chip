`include "include/definitions.sv"

module NOC #(
    parameter WIDTH = 4,
    parameter LENGTH = 4,
    parameter FLIT_SIZE = 18,
    parameter MAX_PACKET_SIZE = 64,
    parameter NODE_DELAY = 100,
    parameter TOTAL_UP_TIME = 3000
)(
    clk, rst,
    mail_boxes
);
    input clk, rst;
    localparam mail_box_size = WIDTH * LENGTH;
    input mailbox #(packet) mail_boxes[mail_box_size];

    
    generate;
        genvar i, j;

        for(i = 0; i < WIDTH + 1; i++) begin : if_x
            for(j = 0; j < LENGTH + 1; j++) begin : if_y
                ReqAckIO router_io_in_east();
                ReqAckIO router_io_out_east();
                ReqAckIO router_io_in_north();
                ReqAckIO router_io_out_north();

            end
        end
    endgenerate

    generate;
        // genvar i, j;
        for(i = 0; i < WIDTH; i++) begin : Nodes_x
            for(j= 0; j < LENGTH; j++) begin : Nodes_y

                    ReqAckIO node_io_in();
                    ReqAckIO node_io_out();

                    Node #(.ROUTER_ID(`ID_FROM_COORDINATE(i, j)), 
                            .TOTAL_UP_TIME(TOTAL_UP_TIME), 
                            .WIDTH(WIDTH), .LENGTH(LENGTH), 
                            .DELAY(NODE_DELAY)) 
                            
                            node (.clk(clk), .rst(rst), 
                                    .in(node_io_in), .out(node_io_out),
                                    .mail_boxes(mail_boxes));
                    

                    Router #(.ROUTER_ID(`ID_FROM_COORDINATE(i, j)),
                            .FLIT_SIZE(FLIT_SIZE), .MAX_PACKET_SIZE(MAX_PACKET_SIZE),
                            .NOC_LENGTH(LENGTH), .NOC_WIDTH(WIDTH))

                            router (.clk(clk), .rst(rst), 
                            .in_ports({node_io_out, if_x[i].if_y[j + 1].router_io_out_east, if_x[i + 1].if_y[j + 1].router_io_out_north, if_x[i + 1].if_y[j + 1].router_io_in_east, if_x[i + 1].if_y[j].router_io_in_north}),
                            .out_ports({node_io_in, if_x[i].if_y[j + 1].router_io_in_east, if_x[i + 1].if_y[j + 1].router_io_in_north, if_x[i + 1].if_y[j + 1].router_io_out_east, if_x[i + 1].if_y[j].router_io_out_north}));
            end
        end

    endgenerate    
endmodule