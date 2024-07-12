`include "include/definitions.sv"

module Port_Decoder #(
    parameter NOC_WIDTH = 4, 
    parameter NOC_LENGTH = 4,
    parameter ROUTER_ID = 0
) (
    dest_address, 
    port_address
);

    // parameters :
    localparam  X_ADDRESS_WIDTH = $clog2(NOC_WIDTH);
    localparam  Y_ADDRESS_WIDTH = $clog2(NOC_LENGTH);
    localparam  TOTAL_ADDRESS_WIDTH = X_ADDRESS_WIDTH + Y_ADDRESS_WIDTH;



    // IO :
    input [TOTAL_ADDRESS_WIDTH-1 : 0] dest_address;
    output logic[2:0] port_address;


    logic [X_ADDRESS_WIDTH-1:0] router_address_x, dest_address_x;
    logic [Y_ADDRESS_WIDTH-1:0] router_address_y, dest_address_y;


    always @(*) begin
        port_address = 0;

        if(dest_address == ROUTER_ID)
            port_address = `LOCAL_PORT_ID;
        
        else if (dest_address_x == router_address_x) begin      // dest_address_x == router_address_x

            if(dest_address_y > router_address_y)
                port_address = `NORTH_PORT_ID;
            else        // since the y of router and dest cannot be equal, it has to go to south port
                port_address = `SOUTH_PORT_ID;
        end

        else if(dest_address_x > router_address_x)
            port_address = `EAST_PORT_ID;

        else if (dest_address_x < router_address_x)
            port_address = `WEST_PORT_ID;

        
    end
    
    assign router_address_x = ROUTER_ID[X_ADDRESS_WIDTH-1:0];
    assign router_address_y = (ROUTER_ID >> X_ADDRESS_WIDTH);
    assign dest_address_x = dest_address[X_ADDRESS_WIDTH-1:0];
    assign dest_address_y = (dest_address >> X_ADDRESS_WIDTH);
    
endmodule



module Routing_Unit #(
    parameter NOC_WIDTH = 4, 
    parameter NOC_LENGTH = 4,
    parameter ROUTER_ID = 0

) (
    dest_local, dest_west,  dest_north,  dest_east, dest_south,
    port_local, port_west, port_north, port_east, port_south
);
    localparam  X_ADDRESS_WIDTH = $clog2(NOC_WIDTH);
    localparam  Y_ADDRESS_WIDTH = $clog2(NOC_LENGTH);
    localparam  TOTAL_ADDRESS_WIDTH = X_ADDRESS_WIDTH + Y_ADDRESS_WIDTH;

    // IO :
    input [TOTAL_ADDRESS_WIDTH-1 : 0] dest_local, dest_west,  dest_north,  dest_east, dest_south;
    output [2:0] port_local, port_west, port_north, port_east, port_south;

    
    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID)) 
                    lcoal_port_decoder (.dest_address(dest_local), .port_address(port_local));
    
    
    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID)) 
                    west_port_decoder (.dest_address(dest_west), .port_address(port_west));

    
    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID)) 
                    north_port_decoder (.dest_address(dest_north), .port_address(port_north));
    
    
    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID)) 
                    east_port_decoder (.dest_address(dest_east), .port_address(port_east));

    
    Port_Decoder #(.NOC_LENGTH(NOC_LENGTH), .NOC_WIDTH(NOC_WIDTH), .ROUTER_ID(ROUTER_ID)) 
                    south_port_decoder (.dest_address(dest_south), .port_address(port_south));


    
endmodule
