`ifndef __TEST__
`define __TEST__

`include "../interfaces.sv"
`include "definitions.sv"

`define GENERATE_CLOCK(CLOCK, PERIOD) always begin #(PERIOD/2) CLOCK = 1'b1; #(PERIOD/2) CLOCK = 1'b0; end



class reqAckVif;
    virtual ReqAckIO io;

    function new(virtual ReqAckIO io);
        this.io = io;
    endfunction

    task handshake_send_packet(ref logic clk, ref packet sending_packet, int packet_size);
        begin
            io.req = 1'b1;
            io.data = sending_packet[0];
            
            wait(io.ack == 1'b1);
            @(posedge clk);
            io.req = 1'b0;
            
            while(io.ack == 1'b1) begin
                @(posedge clk);
            end
            
            for(int i = 0; i < packet_size-1; i++) begin
                io.data <= sending_packet[i+1];
                @(posedge clk);
            end
        end
        
    endtask

    task handshake_recieve_packet(ref logic clk, output packet pkt);
        begin
            while(1) begin
                @(posedge clk);

                if(io.req == 1'b1) begin
                    // $display("saw request");
                    @(posedge clk);
                    io.ack = 1'b1;

                    while(io.req == 1'b1)
                        @(posedge clk);
                        
                    io.ack = 1'b0;
                    @(posedge clk);

                    for(int i = 0; i < 64; i++) begin
                        if(i == 0) begin
                            if(io.data[17:16] != `FLIT_HEADER)
                                $error("Recived Data does not have a proper header");
                        end

                        pkt[i] = io.data;
                        if(io.data[17:16] == `FLIT_TAIL)
                            break;
                        @(posedge clk);
                            
                    end

                    $display("packet recieved successfully!");
                    break;
                end
            end

            $display("Done!");

        end
    endtask
    
    

    task handshake_recieve_packet_timeout(ref logic clk, input int timeout, output packet pkt);
        begin
            int current_time = $time;
            int recieved_data = 0;
            while($time - current_time < timeout) begin
                @(posedge clk);

                if(io.req == 1'b1) begin
                    // $display("saw request");
                    @(posedge clk);
                    io.ack = 1'b1;

                    while(io.req == 1'b1)
                        @(posedge clk);
                        
                    io.ack = 1'b0;
                    @(posedge clk);

                    for(int i = 0; i < 64; i++) begin
                        if(i == 0) begin
                            if(io.data[17:16] != `FLIT_HEADER)
                                $error("Recived Data does not have a proper header");
                        end

                        pkt[i] = io.data;
                        if(io.data[17:16] == `FLIT_TAIL)
                            break;
                        @(posedge clk);
                            
                    end

                    $display("packet recieved successfully!");
                    recieved_data = 1;
                    break;
                end
            end

            if(!recieved_data)
                $error("Timeout Error : Data did not Arrived at the expected time");


        end
    endtask


    task handshake_try_recieve_packet(ref logic clk, output packet pkt, ref int done);
        begin

                if(io.req == 1'b1) begin
                    done = 1;
                    // $display("saw request");
                    @(posedge clk);
                    io.ack = 1'b1;

                    while(io.req == 1'b1)
                        @(posedge clk);
                        
                    io.ack = 1'b0;
                    @(posedge clk);

                    for(int i = 0; i < 64; i++) begin
                        if(i == 0) begin
                            if(io.data[17:16] != `FLIT_HEADER)
                                $error("Recived Data does not have a proper header");
                        end

                        pkt[i] = io.data;
                        if(io.data[17:16] == `FLIT_TAIL)
                            break;
                        @(posedge clk);
                            
                    end

                    // $display("packet recieved successfully!");
                end
                else
                    done = 0;

        end
    endtask


endclass





`endif