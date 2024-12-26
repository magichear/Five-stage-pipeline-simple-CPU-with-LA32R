
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/27 19:00:59
// Design Name: 
// Module Name: Adder
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


module Adder(
    input                   [31 : 0]            a, b,
    input                   [ 0 : 0]            ci,         // 来自低位的进位
    output                  [31 : 0]            s,          // 和
    output                  [ 0 : 0]            co          // 向高位的进位
);
    wire [ 2 : 0] cmid;
    Adder_LookAhead8 add0 (
        .a      (a[7:0]),
        .b      (b[7:0]),
        .ci     (ci),
        .s      (s[7:0]),
        .co     (cmid[0])
    );
    Adder_LookAhead8 add1 (
        .a      (a[15:8]),
        .b      (b[15:8]),
        .ci     (cmid[0]),
        .s      (s[15:8]),
        .co     (cmid[1])
    );
    Adder_LookAhead8 add2 (
        .a      (a[23:16]),
        .b      (b[23:16]),
        .ci     (cmid[1]),
        .s      (s[23:16]),
        .co     (cmid[2])
    );
    Adder_LookAhead8 add3 (
        .a      (a[31:24]),
        .b      (b[31:24]),
        .ci     (cmid[2]),
        .s      (s[31:24]),
        .co     (co)
    );
endmodule
