`include "../include/test.sv"
`include "../include/Routing_Func.sv"



`define WIDTH  4
`define LENGTH  4
`define FLIT_SIZE  18
`define MAX_PACKET_SIZE  64
`define NODE_DELAY  100
`define TOTAL_UP_TIME  30000

module NOC_TB();
    
    logic clk = 0, rst = 0;
    mailbox #(packet) mail_boxes[`WIDTH * `LENGTH];

    `GENERATE_CLOCK(clk, 10);

    NOC #(.WIDTH(`WIDTH), .LENGTH(`LENGTH), 
    .FLIT_SIZE(`FLIT_SIZE), .MAX_PACKET_SIZE(`MAX_PACKET_SIZE),
    .NODE_DELAY(`NODE_DELAY), .TOTAL_UP_TIME(`TOTAL_UP_TIME)) 

    DUT (.clk(clk), .rst(rst), .mail_boxes(mail_boxes));

    int i;

    initial begin
        for(i = 0; i < `WIDTH * `LENGTH; i++) begin
            mail_boxes[i] = new(3);
        end
        #0 rst = 1;

        #40 rst = 0;


        #(`TOTAL_UP_TIME) $stop;
    end

endmodule
















module ROUTERS_TB();
    logic clk = 0, rst = 0;
    mailbox #(packet) mail_boxes[`WIDTH * `LENGTH];

    `GENERATE_CLOCK(clk, 10);

    ReqAckIO router1_io_in_lcoal();
    ReqAckIO router1_io_out_lcoal();

    ReqAckIO router1_io_in_west();
    ReqAckIO router1_io_out_west();

    ReqAckIO router1_io_in_north();
    ReqAckIO router1_io_out_north();
    
    ReqAckIO router1_io_in_east();
    ReqAckIO router1_io_out_east();
    
    ReqAckIO router1_io_in_south();
    ReqAckIO router1_io_out_south();




    ReqAckIO router2_io_in_lcoal();
    ReqAckIO router2_io_out_lcoal();

    ReqAckIO router2_io_in_west();
    ReqAckIO router2_io_out_west();

    ReqAckIO router2_io_in_north();
    ReqAckIO router2_io_out_north();
    
    ReqAckIO router2_io_in_east();
    ReqAckIO router2_io_out_east();
    
    ReqAckIO router2_io_in_south();
    ReqAckIO router2_io_out_south();



    ReqAckIO router3_io_in_lcoal();
    ReqAckIO router3_io_out_lcoal();

    ReqAckIO router3_io_in_west();
    ReqAckIO router3_io_out_west();

    ReqAckIO router3_io_in_north();
    ReqAckIO router3_io_out_north();
    
    ReqAckIO router3_io_in_east();
    ReqAckIO router3_io_out_east();
    
    ReqAckIO router3_io_in_south();
    ReqAckIO router3_io_out_south();

    Node #(.ROUTER_ID(`ID_FROM_COORDINATE(1, 1)), 
                            .TOTAL_UP_TIME(`TOTAL_UP_TIME), 
                            .WIDTH(`WIDTH), .LENGTH(`LENGTH), 
                            .DELAY(`NODE_DELAY)) 
                            
                            node1 (.clk(clk), .rst(rst), 
                                .in(router1_io_out_lcoal), .out(router1_io_in_lcoal),
                                .mail_boxes(mail_boxes));
                    
    Router #(.ROUTER_ID(`ID_FROM_COORDINATE(1, 1)),
            .FLIT_SIZE(18), .MAX_PACKET_SIZE(64),
            .NOC_LENGTH(`LENGTH), .NOC_WIDTH(`WIDTH))

            router1 (.clk(clk), .rst(rst), 
                .in_ports({router1_io_in_lcoal, router1_io_in_west, router1_io_in_north, router1_io_in_east, router1_io_in_south}),
                .out_ports({router1_io_out_lcoal, router1_io_out_west, router1_io_out_north, router1_io_out_east, router1_io_out_south}));


    Node #(.ROUTER_ID(`ID_FROM_COORDINATE(2, 1)), 
                            .TOTAL_UP_TIME(`TOTAL_UP_TIME), 
                            .WIDTH(`WIDTH), .LENGTH(`LENGTH), 
                            .DELAY(`NODE_DELAY)) 
                            
                            node2 (.clk(clk), .rst(rst), 
                                .in(router2_io_out_lcoal), .out(router2_io_in_lcoal),
                                .mail_boxes(mail_boxes));

    Router #(.ROUTER_ID(`ID_FROM_COORDINATE(2, 1)),
            .FLIT_SIZE(18), .MAX_PACKET_SIZE(64),
            .NOC_LENGTH(`LENGTH), .NOC_WIDTH(`WIDTH))

            router2 (.clk(clk), .rst(rst), 
                .in_ports({router2_io_in_lcoal, router1_io_out_east, router2_io_in_north, router2_io_in_east, router2_io_in_south}),
                .out_ports({router2_io_out_lcoal, router1_io_in_east, router2_io_out_north, router2_io_out_east, router2_io_out_south}));



    Node #(.ROUTER_ID(`ID_FROM_COORDINATE(2, 1)), 
                            .TOTAL_UP_TIME(`TOTAL_UP_TIME), 
                            .WIDTH(`WIDTH), .LENGTH(`LENGTH), 
                            .DELAY(`NODE_DELAY)) 
                            
                            node3 (.clk(clk), .rst(rst), 
                                .in(router3_io_out_lcoal), .out(router3_io_in_lcoal),
                                .mail_boxes(mail_boxes));

    Router #(.ROUTER_ID(`ID_FROM_COORDINATE(2, 1)),
            .FLIT_SIZE(18), .MAX_PACKET_SIZE(64),
            .NOC_LENGTH(`LENGTH), .NOC_WIDTH(`WIDTH))

            router3 (.clk(clk), .rst(rst), 
                .in_ports({router3_io_in_lcoal, router3_io_in_west, router3_io_in_north, router3_io_in_east, router1_io_out_north}),
                .out_ports({router3_io_out_lcoal, router3_io_out_west, router3_io_out_north, router3_io_out_east, router1_io_in_north}));


    
    



    int i;
    initial begin
        for(i = 0; i < `WIDTH * `LENGTH; i++) begin
            mail_boxes[i] = new(3);
        end
        #0 rst = 1;
        router1_io_out_west.ack = 0;

        #30 rst = 0;


        #800 router1_io_out_west.ack = 1;
        @(posedge clk);
        router1_io_out_west.ack = 0;


        #823 router1_io_out_west.ack = 1;
        @(posedge clk);
        router1_io_out_west.ack = 0;



        #5000 $stop;
    end


endmodule