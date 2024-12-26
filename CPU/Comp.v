
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/27 19:02:20
// Design Name: 
// Module Name: Comp
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


module Comp(
    input                   [31 : 0]        a, b,
    output     reg          [ 0 : 0]        ul,
    output     reg          [ 0 : 0]        sl
    );

    wire [31:0]temp_out;
    AddSub SignComp (
        .a      (a),
        .b      (b),
        .out    (temp_out),
        .co     ()
    );

    // Signed
    always @(*) begin
        if ((a[31] == 0) && (b[31] == 1)) begin 
            sl = 0;      // a为正，b为负
        end
        else if ((a[31] == 1) && (b[31] == 0)) begin
            sl = 1;      // a 为负，b为正
        end
        else begin  // 都为正数
            if (temp_out[31] == 1) begin   // 相减得负数
                sl = 1;
            end
            else begin                     // 相减得正数
                sl = 0;
            end
        end
        
    end

    // Unsigned
    always @(*) begin
        if ((a[31] == 0) && (b[31] == 1)) begin 
            ul = 1;      // 最高位a < b
        end
        else if ((a[31] == 1) && (b[31] == 0)) begin
            ul = 0;      // 最高位a > b
        end
        else begin   
            if (temp_out[31] == 0) begin         // 相减得正数
                ul = 0;     // 相减还是正数，a > b
            end
            else begin
                ul = 1;     // 发生下溢，a < b
            end
        end
    end   

endmodule
