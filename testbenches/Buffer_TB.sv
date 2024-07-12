`define DATA_WIDTH 18
`define MAX_PACKET_NUM 64
`include "include/definitions.sv"

module Buffer_TB();
    
    logic clk = 0, rst = 0;

    ReqAckIO #(.DATA_WIDTH(`DATA_WIDTH)) buffer_in();
    ReqAckIO #(.DATA_WIDTH(`DATA_WIDTH)) buffer_out();
    ReqGntIO sw_all_io();

    Buffer_Unit #(.DATA_WIDTH(`DATA_WIDTH), .MAX_PACKET_SIZE(`MAX_PACKET_NUM)) 
                DUT(.clk(clk), .rst(rst), .in(buffer_in.slave), .out(buffer_out.master), .swicth_allocator_io(sw_all_io));
    


    `GENERATE_CLOCK(clk, 10);

    task automatic send_data_to_buffer(ref logic clk, ref logic req, ref logic[`DATA_WIDTH-1:0] data, ref logic ack);
        begin
            @(posedge clk);
            $display("yeee");
            req = 1'b1;
            data = 18'd347;

            wait(ack == 1'b1);
            req = 1'b0;
        end
    endtask

    initial begin
        #0 buffer_out.ack = 0;
        buffer_in.req = 0;
        buffer_in.data = 0;
        sw_all_io.grant = 0;
        rst = 1;

        #17 rst = 0;

        
        #54 
            send_data_to_buffer(clk, buffer_in.req, buffer_in.data, buffer_in.ack);
        #100 $stop;
    end

endmodule