module FIFO_TB();
    
    logic clk = 0;
    logic rst = 0;
    localparam data_size = 16;


    FifoIO #(.DATA_WIDTH(data_size)) fifo_io();

    FIFO #(.DATA_WIDTH(data_size), .FIFO_SIZE(4)) 
            DUT(.clk(clk), .rst(rst), .fifo_io(fifo_io.fifo));


    always #5 clk = ~clk;

    integer i;

    initial begin
        #0 rst = 1;
        fifo_io.wr_en = 0;
        fifo_io.wr_data = 0;
        fifo_io.rd_en = 0;
        fifo_io.rd_data = 0;

        #31 rst =0;

        #17 ;
        
        for(i=0; i < 100; i++) begin
            @(posedge clk);
                #1 fifo_io.wr_en = 1'b1;
                fifo_io.wr_data = i;
            @(posedge clk);
                fifo_io.wr_en = 0;
            
            #17 ;
        end


        #1000 $stop();
    end

    integer delay = 0;
    integer j = 0;
    // read instructions :
    initial begin
        #0 fifo_io.rd_en = 0;

        #190;
        repeat(20) begin
            fifo_io.rd_en = 1;
            delay = $urandom_range(50);
            @(posedge clk) $display("Data read on read port : %d", fifo_io.rd_data);
            #1 fifo_io.rd_en = 0;
            #(delay);
        end

        for(j = 0; j < 100; j++) begin
            @(posedge clk);
            fifo_io.rd_en = 1;
            
        end

    end



endmodule