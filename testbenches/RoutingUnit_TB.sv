`include "../include/definitions.sv"
`include "../include/Routing_Func.sv"

module RoutingUnit_TB();

    logic clk = 0;
    logic rst = 0;

    typedef enum {LOCAL, WEST, NORTH, EAST, SOUTH} port_type;

    logic [3:0] dest [0:4];

    wire [2:0] port_out [4:0];

    Routing_Unit #(.NOC_WIDTH(4), .NOC_LENGTH(4), .ROUTER_ID(4'b1001)) 
                    DUT(
                    .dest_local(dest[LOCAL]), .dest_west(dest[WEST]),  .dest_north(dest[NORTH]), .dest_east(dest[EAST]), .dest_south(dest[SOUTH]), 
                    .port_local(port_out[LOCAL]), .port_west(port_out[WEST]), .port_north(port_out[NORTH]), .port_east(port_out[EAST]), .port_south(port_out[SOUTH]));
    

    `GENERATE_CLOCK(clk, 10);

    integer i, j;
    logic [3:0] dummy_address;

    initial begin
        #0 
        for(i = 0; i < 5; i++)
            dest[i] = 0;


        // for(i=0; i < 100; i++) begin
        //     @(posedge clk);

        //     for(j = 0 ; j < 5; j++) begin
        //         dest[j] = $random & 4'b1111;
        //     end

        //     #37;
        // end

        for(i = 0; i < 100; i++) begin
            j = $random % 5;
            dest[j] = $random & 4'b1111;
            #4
            if(port_out[j] != routing_address(dest[j], 4'b1001))
                $display("Port address is not valid");
            
            #37;
        end


        #300 $stop;
    end

    
    
endmodule