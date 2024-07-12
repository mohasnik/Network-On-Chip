
interface ReqAckIO #(
    parameter DATA_WIDTH = 18

)();
    logic [DATA_WIDTH-1:0] data;
    logic req;
    logic ack;

    // master mode :
    modport master (output data, req, input ack);

    // slave mode :
    modport slave (input data, req, output ack);

endinterface

interface ReqGntIO();

    logic req;
    logic grant;

    modport slave (input req, output grant);
    
    modport master (output req, input grant);


endinterface


interface FifoIO #(
    parameter DATA_WIDTH = 16,
    parameter ADDRESS_SIZE = 4
)();
    logic rd_en;
    logic wr_en;
    logic full;
    logic empty;

    logic [DATA_WIDTH-1:0] rd_data;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [ADDRESS_SIZE-1:0] pkt_address;

    
    
    modport fifo (input rd_en, wr_en, wr_data, output rd_data, full, empty, pkt_address);
    
    
    modport ctrl (output rd_en, wr_en, wr_data, input rd_data, full, empty, pkt_address);


endinterface

