`ifndef DEFINITIONS
`define DEFINITIONS

// CONSTANTS :
`define FLIT_HEADER 2'b01
`define FLIT_PAYLOAD 2'b00
`define FLIT_TAIL 2'b10

`define LOCAL_PORT_ID  0
`define WEST_PORT_ID  1
`define NORTH_PORT_ID  2
`define EAST_PORT_ID  3
`define SOUTH_PORT_ID 4



// USEFUL MACROS :
`define ZERO_EXTEND(DATA_WIDTH) {{DATA_WIDTH}{1'b0}}
`define SIGN_EXTEND(DATA, DATA_WIDTH, EXT_WIDTH) {{{EXT_WIDTH}{DATA[DATA_WIDTH-1]}}, DATA}
`define BIT_EXTEND(BIT, WIDTH) {{WIDTH}{BIT}}
`define ID_FROM_COORDINATE(X, Y) (X & 2'b11) | ((Y & 2'b11) << 2)

typedef logic[0:63][17:0] packet;

`endif 