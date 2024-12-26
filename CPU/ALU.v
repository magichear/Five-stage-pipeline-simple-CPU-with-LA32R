
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/27 18:43:29
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define ADD                 5'B00000    
`define SUB                 5'B00010   
`define SLT                 5'B00100
`define SLTU                5'B00101
`define AND                 5'B01001
`define OR                  5'B01010
`define XOR                 5'B01011
`define SLL                 5'B01110   
`define SRL                 5'B01111    
`define SRA                 5'B10000  
`define SRC0                5'B10001
`define SRC1                5'B10010


module ALU (
    input                   [31 : 0]            alu_src0,
    input                   [31 : 0]            alu_src1,
    input                   [ 4 : 0]            alu_op,

    output      reg         [31 : 0]            alu_res
);

// Temp register
wire [31:0] adder_out;
wire [31:0] sub_out;
wire [0 :0] stl_out;
wire [0 :0] stlu_out;

Adder adder(
    .a(alu_src0),
    .b(alu_src1),
    .ci(1'B0),
    .s(adder_out),
    .co()
);

AddSub sub(
    .a(alu_src0),
    .b(alu_src1),
    .out(sub_out),
    .co()
);

Comp comp(
    .a(alu_src0),
    .b(alu_src1),
    .ul(stlu_out),  // unsigned
    .sl(stl_out)
);

always @(*) begin
    case(alu_op)
        `ADD:
            alu_res = adder_out;
        `SUB: 
            alu_res = sub_out;
        `SLT:
            alu_res = {31'b0,stl_out};
        `SLTU:
            alu_res = {31'b0,stlu_out};
        `AND: 
            alu_res = alu_src0 & alu_src1;
        `OR:  
            alu_res = alu_src0 | alu_src1;
        `XOR: 
            alu_res = alu_src0 ^ alu_src1;
        `SLL: 
            alu_res = alu_src0 << alu_src1[4:0];
        `SRL: 
            alu_res = alu_src0 >> alu_src1[4:0];
        `SRA: 
            alu_res = ($signed(alu_src0)) >>> alu_src1[4:0];
        `SRC0:
            alu_res = alu_src0;
        `SRC1:
            alu_res = alu_src1;
        default :
            alu_res = 32'H0;
    endcase
end

endmodule

