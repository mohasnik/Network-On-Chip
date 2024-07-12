`include "include/test.sv"
`include "include/Routing_Func.sv"

module Node #(
    parameter ROUTER_ID = 0,
    parameter TOTAL_UP_TIME = 3000,
    parameter WIDTH = 4,
    parameter LENGTH = 4,
    parameter DELAY = 100

)(
    clk, rst,
    in,
    out,
    mail_boxes
);
    localparam timeout = 2500;
    localparam node_x = (ROUTER_ID) & 2'b11;
    localparam node_y = (((ROUTER_ID) & 4'b1100) >> 2);
    localparam mail_box_size = WIDTH*LENGTH;

    input logic clk, rst;
    ReqAckIO in;
    ReqAckIO out;
    input mailbox #(packet) mail_boxes[mail_box_size];

    reqAckVif vio_in;
    reqAckVif vio_out;

    


    task automatic sendPacket();
        begin
            
            int packet_size = ($urandom_range(64) + 3) % 64;
            int dest_x, dest_y;
            packet new_packet = generate_packet(WIDTH, LENGTH, ROUTER_ID, packet_size);
            int err = 0;
            string packet_info = packet_details(new_packet);

            // creating random delays :

            dest_x = new_packet[0][1:0];
            dest_y = new_packet[0][3:2];
            $display("**Node (%d, %d) sending packet:\nDestination : (%d, %d)\nPacket Details : %s\n**********\n\n", node_x, node_y, dest_x, dest_y, packet_info);  // FILE_IO
            
            mail_boxes[dest_y * WIDTH + dest_x].put(new_packet);
            vio_out.handshake_send_packet(clk, new_packet, packet_size);

        end
    endtask

    
    task automatic recievePacket();
        begin
            packet recieved_packet, sent_packet;
            int done;
            int err = 0;
            int packet_size, packet_number;
            int equal;

            while($time < TOTAL_UP_TIME) begin
                @(posedge clk);

                done = 0;
                vio_in.handshake_try_recieve_packet(clk, recieved_packet, done);
                
                if(done) begin
                    packet_size = recieved_packet[1];
                    packet_number = recieved_packet[0][15:8];

                    equal = 0;

                    while(mail_boxes[node_y * WIDTH + node_x].try_get(sent_packet)) begin
                        equal = packets_cmp(sent_packet, recieved_packet, packet_size);
                        
                        if(equal) begin
                            $display("Packet No. %d arrived successfully", packet_number);
                            break;
                        end
                        else begin
                            mail_boxes[node_y * WIDTH + node_x].put(sent_packet);
                        end
                    end
                end
            end

            if(err)
                $display("recived packet does not exist in the list");
        end
    endtask


    // initializing virual intefaces :
    initial begin
        vio_in = new(in);
        vio_out = new(out);
    end

    always @(posedge rst) begin
        out.req = 0;
        out.data = 0;
        in.ack = 0;
    end


    initial begin

        #(DELAY);

        while ($time < TOTAL_UP_TIME) begin
            #($urandom_range(50 + $urandom_range(ROUTER_ID + 10)));
            sendPacket();
            #(TOTAL_UP_TIME/2);
        end
    end

    initial begin
        #(DELAY);

        while($time < TOTAL_UP_TIME) begin
            recievePacket();
        end
    end


endmodule