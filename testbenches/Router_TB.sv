`include "../include/test.sv"
`include "../include/Routing_Func.sv"

`define ROUTER_ID 4'b1001


module Router_TB();
    logic clk = 0, rst = 0;

    reqAckVif vio_i_ports[5];
    reqAckVif vio_o_ports[5];

    ReqAckIO i_ports[5]();
    ReqAckIO o_ports[5]();

    semaphore in_keys [5];
    semaphore out_keys [5];

    generate
        genvar i;
        for(i = 0; i < 5; i++) begin
            initial begin
                vio_i_ports[i] = new(i_ports[i]);
                vio_o_ports[i] = new(o_ports[i]);
            end
        end
    endgenerate


    Router #(.ROUTER_ID(`ROUTER_ID))
            DUT (.clk(clk), .rst(rst),
                    .in_ports(i_ports),
                    .out_ports(o_ports));


    task automatic random_packet_trafficing(input int number_of_iters);
        begin
            for(int i = 0; i < number_of_iters; i++) begin
                
                int rand_port = $urandom_range(5);
                int packet_size = ($urandom_range(64) + 3) % 64;
                packet new_packet = generate_packet(4, 4, `ROUTER_ID, packet_size);
                
                string packet_info = packet_details(new_packet);

                $display("%d\n", rand_port);
                $display("%s", packet_info);

                
                vio_i_ports[rand_port].handshake_send_packet(clk, new_packet, packet_size);


            end
        end
    endtask


    task automatic send_packet_from_port(input int port_num);
        begin

            int packet_size = ($urandom_range(64) + 3) % 64;
            int dest;
            packet new_packet = generate_packet(4, 4, `ROUTER_ID, packet_size);
            packet recieved_packet;
            int err = 0;
            string packet_info = packet_details(new_packet);

            in_keys[port_num].get();
            

            dest = packet_routing_port(new_packet[0][3:0], `ROUTER_ID);
            $display("Source Port : %d\nDestination Port : %d\n%s", port_num, dest, packet_info);  

            fork
                begin
                    vio_i_ports[port_num].handshake_send_packet(clk, new_packet, packet_size);
                    in_keys[port_num].put();
                end

                begin
                    out_keys[dest].get();
                    vio_o_ports[dest].handshake_recieve_packet(clk, recieved_packet);
                    out_keys[dest].put();

                end

            join

            for(int i = 0; i < packet_size; i++) begin
                if(new_packet[i] != recieved_packet[i]) begin
                    $error("sent and recieved packages are not the same");
                    for(int j = 0; j < packet_size; j++)
                        $display("s : %b, r : %b", new_packet[j], recieved_packet[j]);
                    err = 1;
                    break;
                end
            end

            if(!err)
                $display("packet No. %d recieved succeesfully with no errors", new_packet[0][15:8]);
            
        end
    endtask
    
       

    int j;

    `GENERATE_CLOCK(clk, 10);

    

    initial begin
        
        for(j = 0; j < 5; j++)  begin
            in_keys[j] = new(1);
            out_keys[j] = new(1);
            vio_i_ports[j].io.req = 0;
            vio_i_ports[j].io.data = 0;
            vio_o_ports[j].io.ack = 0;

        end
    
        #0 rst = 1'b1;
        #20 rst = 1'b0;

        #50
            fork
                send_packet_from_port(3);
                send_packet_from_port(1);
                send_packet_from_port(2);
                send_packet_from_port(2);
                send_packet_from_port(4);
                send_packet_from_port(4);

            join
            
            

        #1000 $stop;

    end

endmodule