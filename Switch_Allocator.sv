`include "include/definitions.sv"

module Out_Port_Arbiter #(
    parameter PORT_ADDRESS = 0
) (
    clk, rst,
    local_buffer_req, west_buffer_req, north_buffer_req, east_buffer_req, south_buffer_req,
    local_buffer_dport, west_buffer_dport, north_buffer_dport, east_buffer_dport, south_buffer_dport,
    local_buffer_grant, west_buffer_grant, north_buffer_grant, east_buffer_grant, south_buffer_grant
);

    input clk, rst;
    input local_buffer_req, west_buffer_req, north_buffer_req, east_buffer_req, south_buffer_req;
    input[2:0] local_buffer_dport, west_buffer_dport, north_buffer_dport, east_buffer_dport, south_buffer_dport;
    output logic local_buffer_grant, west_buffer_grant, north_buffer_grant, east_buffer_grant, south_buffer_grant;

    typedef enum {LOCAL = 0, WEST = 1, NORTH = 2, EAST = 3, SOUTH = 4} port;

    logic [2:0] port_address, select_current_request;
    logic local_dest_eq, west_dest_eq , north_dest_eq, east_dest_eq , south_dest_eq;
    logic current_request;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            {local_buffer_grant, west_buffer_grant, north_buffer_grant, east_buffer_grant, south_buffer_grant} = 5'b0;
            select_current_request = 3'b111;
        end

        else if(~current_request) begin     // if there is no request that is granted, continue to grant a new request
            {local_buffer_grant, west_buffer_grant, north_buffer_grant, east_buffer_grant, south_buffer_grant} = 5'b0;

            if(local_buffer_req & local_dest_eq) begin
                local_buffer_grant <= 1'b1;
                select_current_request <= LOCAL;
            end
            else if (west_buffer_req & west_dest_eq) begin
                west_buffer_grant <= 1'b1;
                select_current_request <= WEST;

            end
            else if (north_buffer_req & north_dest_eq) begin
                north_buffer_grant <= 1'b1;
                select_current_request <= NORTH;

            end
            else if (east_buffer_req & east_dest_eq) begin
                east_buffer_grant <= 1'b1;
                select_current_request <= EAST;

            end
            else if (south_buffer_req & south_dest_eq) begin
                south_buffer_grant <= 1'b1;
                select_current_request <= SOUTH;

            end
            else
                select_current_request <= 3'b111;
        end
    end


    assign port_address = PORT_ADDRESS;
    assign local_dest_eq = &{~(local_buffer_dport ^ port_address)};
    assign west_dest_eq = &{~(west_buffer_dport ^ port_address)};
    assign north_dest_eq = &{~(north_buffer_dport ^ port_address)};
    assign east_dest_eq = &{~(east_buffer_dport ^ port_address)};
    assign south_dest_eq = &{~(south_buffer_dport ^ port_address)};

    assign current_request = (select_current_request == LOCAL) ? local_buffer_req :
                                (select_current_request == WEST) ? west_buffer_req :
                                (select_current_request == NORTH) ? north_buffer_req :
                                (select_current_request == EAST) ? east_buffer_req :
                                (select_current_request == SOUTH) ? south_buffer_req : 1'b0;

    
endmodule


module Switch_Allocator 
(
    clk, rst, 
    buffers_rg,
    buffers_dport
);
    // IO :
    input clk, rst;
    ReqGntIO buffers_rg [0:4];
    input [0:4][2:0] buffers_dport;

    typedef enum {LOCAL = 0, WEST = 1, NORTH = 2, EAST = 3, SOUTH = 4} port;

    wire [0:4][0:4] grants; 

    generate;
        genvar i;

        for(i = 0; i < 5; i++) begin
            
            Out_Port_Arbiter #(.PORT_ADDRESS(i)) 
                            out_port_arb_ (.clk(clk), .rst(rst),
                                .local_buffer_req(buffers_rg[LOCAL].req), .west_buffer_req(buffers_rg[WEST].req), .north_buffer_req(buffers_rg[NORTH].req),
                                .east_buffer_req(buffers_rg[EAST].req), .south_buffer_req(buffers_rg[SOUTH].req),
                                .local_buffer_dport(buffers_dport[LOCAL]), .west_buffer_dport(buffers_dport[WEST]), .north_buffer_dport(buffers_dport[NORTH]),
                                .east_buffer_dport(buffers_dport[EAST]), .south_buffer_dport(buffers_dport[SOUTH]),
                                .local_buffer_grant(grants[LOCAL][i]), .west_buffer_grant(grants[WEST][i]), .north_buffer_grant(grants[NORTH][i]),
                                .east_buffer_grant(grants[EAST][i]), .south_buffer_grant(grants[SOUTH][i]));


            assign buffers_rg[i].grant = |{grants[i]};
        end

    endgenerate
    



endmodule

